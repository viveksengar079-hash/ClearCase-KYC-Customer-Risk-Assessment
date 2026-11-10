-- CLEARCASE KYC | CASE 03 — OWEN ASHFORD | SANCTIONS CANDIDATE
-- This file contains READ-ONLY verification queries. No INSERT, UPDATE or DELETE.
-- Run with MySQL connected to your local project. Select each whole statement
-- through the semicolon in VS Code before running it.
-- Current Streamlit/MySQL rows may differ from the original synthetic CSV snapshot.
USE clearcase_kyc;

-- QUERY 01 — Customer and onboarding details
SELECT
    c.customer_id, c.legal_name, c.customer_type,
    c.country_code, c.nationality_code, c.date_of_birth,
    c.occupation, c.channel, c.product_type,
    c.expected_monthly_volume_usd, c.expected_monthly_tx_count,
    c.source_of_funds, c.source_of_wealth,
    k.case_id, k.review_type, k.trigger_event, k.opened_at,
    k.due_at, k.case_status, k.priority, k.assigned_analyst_id
FROM customers AS c
JOIN kyc_cases AS k ON k.customer_id = c.customer_id
WHERE c.customer_id = 'CUS00001'
  AND k.case_id = 'KYC000001';
-- Analyst comment: Start by confirming you have Owen's correct onboarding case.
-- The source-of-funds/wealth values are declarations, not independently verified evidence.

-- QUERY 02 — Missing customer documents
SELECT
    document_id, document_type, verification_status,
    exception_code, received_at, verified_at
FROM customer_documents
WHERE case_id = 'KYC000001'
ORDER BY document_id;
-- Analyst comment: Check whether mandatory identity/address proofs are available.
-- A confirmed screening identity is not a substitute for collecting KYC documents.

-- QUERY 03 — Link screening run, hit, watchlist entity, and reference source
SELECT
    r.case_id, r.screening_run_id, r.screened_at,
    r.source_snapshot_at, r.run_status,
    r.screening_method, r.potential_hit_count,
    h.screening_hit_id, h.match_score, h.match_basis,
    h.identity_assessment, h.analyst_disposition,
    h.analyst_rationale, h.reviewed_at,
    w.watchlist_entity_id, w.primary_name,
    w.country_code AS list_country, w.date_of_birth AS list_dob,
    w.record_category, w.record_status,
    w.last_updated AS list_last_updated,
    s.source_id, s.source_name, s.source_category,
    s.region, s.dataset_is_synthetic, s.snapshot_date
FROM screening_runs AS r
LEFT JOIN screening_hits AS h
    ON h.screening_run_id = r.screening_run_id
LEFT JOIN watchlist_entities AS w
    ON w.watchlist_entity_id = h.watchlist_entity_id
LEFT JOIN screening_sources AS s
    ON s.source_id = w.source_id
WHERE r.case_id = 'KYC000001'
ORDER BY r.screened_at, h.screening_hit_id;
-- Analyst comment: Look for RUN0000001 / HIT0000001 and synthetic WL00001.
-- Screening run COMPLETED is not proof the escalation or KYC case was cleared.
-- The reference source is synthetic, and its date needs separate scrutiny.

-- QUERY 04 — Directly compare customer and list identifiers
SELECT
    c.legal_name AS customer_name,
    c.date_of_birth AS customer_dob,
    c.country_code AS customer_country,
    w.primary_name AS list_name,
    w.date_of_birth AS list_dob,
    w.country_code AS list_country,
    h.match_score, h.match_basis, h.identity_assessment
FROM kyc_cases AS k
JOIN customers AS c ON c.customer_id = k.customer_id
JOIN screening_runs AS r ON r.case_id = k.case_id
JOIN screening_hits AS h ON h.screening_run_id = r.screening_run_id
JOIN watchlist_entities AS w
    ON w.watchlist_entity_id = h.watchlist_entity_id
WHERE k.case_id = 'KYC000001'
  AND h.screening_hit_id = 'HIT0000001';
-- Analyst comment: Verify exact name, DOB and country from both stored records.
-- Do not interpret the screening score as a probability of criminal activity.

-- QUERY 05 — Fictional sanctions designation linked to the matched entity
SELECT
    w.watchlist_entity_id, w.primary_name,
    w.record_category, w.record_status,
    d.designation_id, d.training_program, d.designated_at,
    d.designation_status, d.restriction_type, d.designation_reason
FROM screening_hits AS h
JOIN watchlist_entities AS w
    ON w.watchlist_entity_id = h.watchlist_entity_id
LEFT JOIN sanctions_designations AS d
    ON d.watchlist_entity_id = w.watchlist_entity_id
WHERE h.screening_hit_id = 'HIT0000001';
-- Analyst comment: The training reference has ACTIVE designation SAN00001.
-- Its restriction_type is a fictional example, NOT a verified official US sanction.

-- QUERY 06 — Confirm case-level escalation and the specialist queue
SELECT
    escalation_id, case_id, escalation_type, raised_at,
    raised_by, assigned_to, escalation_status,
    resolved_at, decision_summary
FROM escalations
WHERE case_id = 'KYC000001'
ORDER BY raised_at, escalation_id;
-- Analyst comment: Expect ESC000001 OPEN and pending compliance review.
-- Identify the assigned reviewer; never treat an OPEN escalation as clearance.

-- QUERY 07 — Check mandatory controls for onboarding
SELECT
    check_id, case_id, control_name,
    mandatory, step_status, completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC000001'
ORDER BY check_id;
-- Analyst comment: Identity, documents, screening, risk and QC remain OPEN
-- in the source snapshot. Note the EDD_REVIEW COMPLETE control anomaly.

-- QUERY 08 — Inspect overall risk assessment and draft status
SELECT
    assessment_id, case_id, assessment_score,
    risk_rating, edd_required, assessment_status,
    methodology, decision_rationale, assessed_at
FROM customer_risk_assessments
WHERE case_id = 'KYC000001';
-- Analyst comment: This synthetic model says MEDIUM / EDD NO / DRAFT.
-- Never use a numerical CRA score to override a sanctions review/hold policy.

-- QUERY 09 — Inspect the five weighted CRA factors
SELECT
    factor_name, factor_value, weight,
    weighted_value, evidence_note
FROM case_risk_factors
WHERE case_id = 'KYC000001'
ORDER BY factor_id;
-- Analyst comment: Screening exposure contributes 1.25 to a total 3.296.
-- Weight is a MODEL parameter, not a compliance approval threshold.

-- QUERY 10 — Reconcile numerical risk score with saved factors
SELECT
    r.case_id, r.assessment_score AS recorded_score,
    ROUND(SUM(f.weighted_value), 4) AS calculated_score,
    ROUND(SUM(f.weight), 4) AS total_weight,
    ROUND(r.assessment_score-SUM(f.weighted_value), 4) AS difference
FROM customer_risk_assessments AS r
JOIN case_risk_factors AS f ON f.case_id = r.case_id
WHERE r.case_id = 'KYC000001'
GROUP BY r.case_id, r.assessment_score;
-- Analyst comment: Expected recorded and calculated scores are 3.2960,
-- difference zero, and total weight 1.0000 in the source snapshot.

-- QUERY 11 — Investigative notes and audit log
SELECT
    note_id, case_id, author_id, created_at,
    note_type, note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC000001'
ORDER BY created_at, note_id;
-- Analyst comment: Read existing analyst rationale before adding your own.
-- Don't overwrite or misrepresent the original simulated record.

SELECT
    event_id, event_at, actor_id, event_type,
    related_table, related_record_id,
    old_value, new_value, event_comment
FROM case_audit_log
WHERE case_id = 'KYC000001'
ORDER BY event_at, event_id;
-- Analyst comment: Verify that screening, review and escalation events exist.
-- This is a second standalone SELECT; run its entire statement.

-- QUERY 12 — Independent QC and case approval, if any
SELECT *
FROM qc_reviews
WHERE case_id = 'KYC000001';
-- Analyst comment: Empty result in the source snapshot means no QC record
-- was stored there. Do not interpret a missing row as a PASS.

SELECT *
FROM case_approvals
WHERE case_id = 'KYC000001';
-- Analyst comment: Empty approval result in the source snapshot means
-- the case has no recorded acceptance/approval in that version.

-- QUERY 13 — Check for formal case disposition or outstanding requests
SELECT *
FROM case_dispositions
WHERE case_id = 'KYC000001';
-- Analyst comment: If this is empty, no formal case disposition was recorded.
-- A screening hit disposition is a DIFFERENT field and process.

SELECT *
FROM information_requests
WHERE case_id = 'KYC000001';
-- Analyst comment: Check whether missing documents have formal requests.
-- Never claim an information request exists unless a row supports it.

-- QUERY 14 — Verify list version/freshness evidence
SELECT
    r.screening_run_id, r.screened_at, r.source_snapshot_at,
    w.watchlist_entity_id, w.last_updated AS list_updated_at,
    s.source_name, s.snapshot_date AS current_source_snapshot
FROM screening_runs AS r
JOIN screening_hits AS h
    ON h.screening_run_id = r.screening_run_id
JOIN watchlist_entities AS w
    ON w.watchlist_entity_id = h.watchlist_entity_id
JOIN screening_sources AS s
    ON s.source_id = w.source_id
WHERE r.case_id = 'KYC000001';
-- Analyst comment: Source snapshot for run is 2026-10-06, but current
-- synthetic source/list has update 2026-10-31. Historical provenance
-- must be corroborated rather than silently inferred.
