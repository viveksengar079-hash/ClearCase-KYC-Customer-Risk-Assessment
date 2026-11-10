-- CLEARCASE KYC | CASE 04 — NORTHGATE IMPORTS | LAYERED OWNERSHIP / UBO
-- READ ONLY: No INSERT, UPDATE, DELETE, DROP, or ALTER in this file.
-- MySQL Workbench / VS Code: highlight an entire statement through ; before Run.
-- Queries 01-14 reproduce the supplied CSV source-snapshot investigation.
-- Your live database may contain later user-entered training records.
USE clearcase_kyc;

-- QUERY 01 — Identify the exact event-driven case and customer
SELECT
    c.customer_id, c.legal_name, c.customer_type,
    c.country_code, c.industry, c.customer_status,
    c.relationship_manager_id,
    k.case_id, k.scenario_id, k.review_type, k.trigger_event,
    k.opened_at, k.due_at, k.case_status, k.priority,
    k.complexity, k.assigned_analyst_id
FROM customers AS c
JOIN kyc_cases AS k ON k.customer_id = c.customer_id
WHERE c.customer_id = 'CUS00004'
  AND k.case_id = 'KYC001201';
-- Analyst comment: Confirm Northgate's correct review, not its earlier
-- completed onboarding case KYC000004. Expected case PENDING_INFORMATION.

-- QUERY 02 — Direct owners of Northgate and documentary status
SELECT
    d.ownership_id, d.owner_party_id,
    p.legal_name AS owner_name, p.party_type,
    d.share_pct, d.voting_pct, d.effective_date,
    d.verification_status
FROM corporate_ownership AS d
LEFT JOIN related_parties AS p ON p.party_id = d.owner_party_id
WHERE d.owned_entity_type = 'CUSTOMER'
  AND d.owned_entity_id = 'CUS00004'
ORDER BY d.share_pct DESC;
-- Analyst comment: Expect intermediary PTY00001 55% PENDING,
-- Priya PTY00004 30% VERIFIED, Marcus PTY00005 15% VERIFIED.
-- One major unverified link is enough to keep the ownership conclusion provisional.

-- QUERY 03 — Who owns the 55% intermediary?
SELECT
    i.ownership_id, i.owned_entity_id AS intermediary_id,
    company.legal_name AS intermediary_name,
    i.owner_party_id, person.legal_name AS owner_name,
    person.party_type, i.share_pct, i.voting_pct,
    i.effective_date, i.verification_status
FROM corporate_ownership AS i
LEFT JOIN related_parties AS company
    ON company.party_id = i.owned_entity_id
LEFT JOIN related_parties AS person
    ON person.party_id = i.owner_party_id
WHERE i.owned_entity_type = 'PARTY'
  AND i.owned_entity_id = 'PTY00001'
ORDER BY i.share_pct DESC;
-- Analyst comment: Jonah PTY00002 65% and Oscar PTY00003 35%.
-- Verify these are natural persons, not another layer of corporations.

-- QUERY 04 — Full two-level ownership and effective percentages
SELECT
    d.ownership_id AS northgate_link_id,
    p1.legal_name AS direct_owner,
    p1.party_type AS direct_owner_type,
    d.share_pct AS direct_share_pct,
    d.verification_status AS northgate_link_status,
    i.ownership_id AS intermediary_link_id,
    p2.legal_name AS final_natural_person,
    COALESCE(p2.party_type, p1.party_type) AS identified_owner_type,
    COALESCE(p2.legal_name, p1.legal_name) AS identified_owner,
    i.share_pct AS second_level_share_pct,
    i.verification_status AS second_level_status,
    CASE
        WHEN i.ownership_id IS NULL THEN d.share_pct
        ELSE ROUND(d.share_pct * i.share_pct / 100.0, 2)
    END AS effective_ownership_pct
FROM corporate_ownership AS d
LEFT JOIN related_parties AS p1
    ON d.owner_party_id = p1.party_id
LEFT JOIN corporate_ownership AS i
    ON i.owned_entity_type = 'PARTY'
   AND i.owned_entity_id = d.owner_party_id
LEFT JOIN related_parties AS p2
    ON i.owner_party_id = p2.party_id
WHERE d.owned_entity_type = 'CUSTOMER'
  AND d.owned_entity_id = 'CUS00004'
ORDER BY effective_ownership_pct DESC;
-- Analyst comment: Expected Jonah 35.75, Priya 30, Oscar 19.25,
-- Marcus 15. These are computed economic interests, not verified UBO decisions.
-- The same PENDING 55% parent link underlies both Jonah and Oscar's paths.

-- QUERY 05 — Reconcile total recorded equity; detect mathematical gaps
SELECT
    ROUND(SUM(effective_ownership_pct), 2) AS recorded_effective_total_pct
FROM (
    SELECT
        CASE
            WHEN i.ownership_id IS NULL THEN d.share_pct
            ELSE d.share_pct * i.share_pct / 100.0
        END AS effective_ownership_pct
    FROM corporate_ownership AS d
    LEFT JOIN corporate_ownership AS i
        ON i.owned_entity_type = 'PARTY'
       AND i.owned_entity_id = d.owner_party_id
    WHERE d.owned_entity_type = 'CUSTOMER'
      AND d.owned_entity_id = 'CUS00004'
) AS ownership_paths;
-- Analyst comment: Expect 100.00%. This proves arithmetic coverage only.
-- Missing branches or unverified links might still invalidate a UBO conclusion.

-- QUERY 06 — Show verification gaps and relevant dates on ownership links
SELECT
    ownership_id, owned_entity_type, owned_entity_id,
    owner_party_id, share_pct, voting_pct,
    effective_date, verification_status
FROM corporate_ownership
WHERE (owned_entity_type = 'CUSTOMER'
       AND owned_entity_id = 'CUS00004')
   OR (owned_entity_type = 'PARTY'
       AND owned_entity_id = 'PTY00001')
ORDER BY owned_entity_type, ownership_id;
-- Analyst comment: OWN000003 is PENDING; check whether the stated
-- OWNERSHIP_CHANGE trigger has dated before/after ownership evidence.

-- QUERY 07 — Document verification for THIS review, not previous onboarding
SELECT
    document_id, case_id, subject_type, subject_id,
    document_type, verification_status,
    exception_code, received_at, verified_at
FROM customer_documents
WHERE case_id = 'KYC001201'
ORDER BY document_id;
-- Analyst comment: Expect one VERIFIED incorporation certificate and four
-- MISSING: registered address, director ID, ownership declaration, SOF evidence.
-- Previous completed case KYC000004 documents don't close current case gaps.

-- QUERY 08 — Open request for ownership declaration
SELECT
    request_id, case_id, relationship_manager_id,
    requested_item, requested_at, due_at,
    responded_at, request_status, request_detail, closure_note
FROM information_requests
WHERE case_id = 'KYC001201'
ORDER BY requested_at, request_id;
-- Analyst comment: REQ000071 UBO_DECLARATION should be OPEN, due 2026-11-12.
-- Do not close the original request without actual evidence and authorization.

-- QUERY 09 — Check mandatory control workflow
SELECT
    check_id, control_name, mandatory,
    step_status, completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC001201'
ORDER BY check_id;
-- Analyst comment: OWNERSHIP_UBO, CUSTOMER_IDENTITY, DOCUMENT_VERIFICATION,
-- CUSTOMER_RISK_ASSESSMENT and QC_APPROVAL are OPEN in source data.
-- A COMPLETE customer-level screening step doesn't prove all owners screened.

-- QUERY 10 — Verify risk assessment is HIGH / DRAFT / EDD YES
SELECT
    assessment_id, case_id, assessment_score,
    risk_rating, edd_required, assessment_status,
    assessed_at, assessed_by, methodology, decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC001201';
-- Analyst comment: Expected 3.545 HIGH, EDD YES, DRAFT. Synthetic methodology,
-- not a bank's actual thresholds; risk rating is not a final acceptance decision.

-- QUERY 11 — Recalculate 5-factor weighted score
SELECT
    f.case_id, COUNT(*) AS factor_count,
    ROUND(SUM(f.weight), 4) AS total_weight,
    ROUND(SUM(f.weighted_value), 4) AS calculated_score,
    MAX(a.assessment_score) AS stored_score,
    ROUND(MAX(a.assessment_score) - SUM(f.weighted_value), 4)
        AS reconciliation_difference
FROM case_risk_factors AS f
JOIN customer_risk_assessments AS a
    ON a.case_id = f.case_id
WHERE f.case_id = 'KYC001201'
GROUP BY f.case_id;
-- Analyst comment: Expect five factors, weights total 1.0000,
-- calculated score 3.5450 and difference 0.0000.

-- QUERY 12 — Examine exact scope of recorded screening run
SELECT
    screening_run_id, case_id, customer_id,
    screened_subject_type, screened_subject_id,
    screened_at, run_status, potential_hit_count,
    screening_scope, screening_method
FROM screening_runs
WHERE case_id = 'KYC001201'
ORDER BY screening_run_id;
-- Analyst comment: Corporate CUSTOMER run RUN0001201 has zero potential hits.
-- This doesn't prove screening of every related party and individual owner.

-- QUERY 13 — Check previous case notes, QC, approvals and escalations
SELECT note_id, created_at, author_id, note_type,
       note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC001201'
ORDER BY created_at, note_id;
-- Analyst comment: Review actual analyst notes, but don't confuse intake
-- template wording with evidence that all screening/checklist controls are open.

-- QUERY 14 — Separate independent QC/approval/escalation checks
SELECT 'QC' AS record_type, COUNT(*) AS record_count
FROM qc_reviews WHERE case_id = 'KYC001201'
UNION ALL
SELECT 'APPROVAL', COUNT(*)
FROM case_approvals WHERE case_id = 'KYC001201'
UNION ALL
SELECT 'ESCALATION', COUNT(*)
FROM escalations WHERE case_id = 'KYC001201';
-- Analyst comment: Source snapshot has zero QC, approval and escalation rows.
-- This is not permission to approve the still-pending UBO review.

-- QUERY 15 — Optional: inspect full case audit history
SELECT *
FROM case_audit_log
WHERE case_id = 'KYC001201'
ORDER BY event_id DESC;
-- Analyst comment: Look for any later work, new evidence or altered status.
-- Compare current database records against the source snapshot before GitHub.
