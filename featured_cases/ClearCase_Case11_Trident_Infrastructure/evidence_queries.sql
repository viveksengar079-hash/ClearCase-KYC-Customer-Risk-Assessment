-- CLEARCASE KYC | CASE 11 — TRIDENT INFRASTRUCTURE | EDD / SOURCE OF WEALTH
-- Source: fictional ClearCase CSV snapshot dated 05 November 2026.
-- Read-only investigation workbook: NO INSERT, UPDATE, DELETE, DROP or ALTER.
-- In VS Code, highlight each COMPLETE query through the semicolon before running.
-- Your local MySQL may differ from the snapshot after prior training updates.
USE clearcase_kyc;

-- QUERY 01 — Confirm the target customer and high-risk case.
SELECT c.customer_id, c.legal_name, c.customer_type, c.country_code,
       c.industry, c.customer_status, c.relationship_manager_id,
       k.case_id, k.review_type, k.trigger_event, k.opened_at,
       k.due_at, k.priority, k.complexity, k.assigned_analyst_id,
       k.case_status, k.scenario_id
FROM customers AS c
JOIN kyc_cases AS k ON c.customer_id = k.customer_id
WHERE c.customer_id = 'CUS00011' AND k.case_id = 'KYC001207';
-- Analyst note: Ensure you are investigating the EVENT_DRIVEN HIGH_RISK_REVIEW,
-- not an earlier onboarding case. Expected current status: ESCALATED.

-- QUERY 02 — Check the customer's historical case IDs separately.
SELECT case_id, customer_id, review_type, trigger_event,
       opened_at, due_at, priority, case_status, assigned_analyst_id
FROM kyc_cases
WHERE customer_id = 'CUS00011'
ORDER BY opened_at, case_id;
-- Analyst note: A previous completed onboarding case is not an approval
-- of this event-driven review. Record any differing local-case statuses.

-- QUERY 03 — Direct ownership, verification status and party names.
SELECT o.ownership_id, o.owner_party_id, p.legal_name AS direct_owner,
       p.party_type, o.share_pct, o.voting_pct,
       o.effective_date, o.verification_status
FROM corporate_ownership AS o
LEFT JOIN related_parties AS p ON o.owner_party_id = p.party_id
WHERE o.owned_entity_type = 'CUSTOMER'
  AND o.owned_entity_id = 'CUS00011'
ORDER BY o.share_pct DESC;
-- Expected: intermediary PTY00012 55%, Bianca PTY00015 30%,
-- Felix PTY00016 15%. All three recorded edges VERIFIED.

-- QUERY 04 — Trace intermediate holdings to natural persons.
SELECT d.owner_party_id AS direct_owner_party_id,
       p1.legal_name AS direct_owner_name,
       p1.party_type AS direct_owner_type,
       d.share_pct AS direct_share_pct,
       d.verification_status AS direct_edge_status,
       COALESCE(i.owner_party_id, d.owner_party_id) AS final_party_id,
       COALESCE(p2.legal_name, p1.legal_name) AS final_owner_name,
       COALESCE(p2.party_type, p1.party_type) AS final_owner_type,
       i.share_pct AS second_level_share_pct,
       i.verification_status AS second_level_status,
       CASE WHEN i.owner_party_id IS NULL THEN d.share_pct
            ELSE ROUND(d.share_pct * i.share_pct / 100.0, 2)
       END AS effective_ownership_pct
FROM corporate_ownership AS d
LEFT JOIN related_parties AS p1 ON d.owner_party_id = p1.party_id
LEFT JOIN corporate_ownership AS i
  ON i.owned_entity_type = 'PARTY'
 AND i.owned_entity_id = d.owner_party_id
LEFT JOIN related_parties AS p2 ON i.owner_party_id = p2.party_id
WHERE d.owned_entity_type = 'CUSTOMER'
  AND d.owned_entity_id = 'CUS00011'
ORDER BY effective_ownership_pct DESC;
-- Expected 4 natural-person interests: Ryan 35.75%, Bianca 30%,
-- Arjun 19.25%, Felix 15%. Calculate economics; don't assume UBO approval.

-- QUERY 05 — Reconcile effective ownership to 100%.
SELECT ROUND(SUM(
       CASE WHEN i.owner_party_id IS NULL THEN d.share_pct
            ELSE d.share_pct * i.share_pct / 100.0 END
       ), 2) AS total_effective_ownership_pct,
       COUNT(*) AS recorded_ownership_paths
FROM corporate_ownership AS d
LEFT JOIN corporate_ownership AS i
  ON i.owned_entity_type = 'PARTY'
 AND i.owned_entity_id = d.owner_party_id
WHERE d.owned_entity_type = 'CUSTOMER'
  AND d.owned_entity_id = 'CUS00011';
-- Expected: 100.00 across 4 paths, provided each intermediary's child
-- ownership fully sums to 100%. Percent reconciliation is not identity proof.

-- QUERY 06 — Identify directors and independently recorded verification.
SELECT d.director_id, d.party_id, p.legal_name,
       d.position_title, d.appointed_date, d.verification_status
FROM customer_directors AS d
LEFT JOIN related_parties AS p ON d.party_id = p.party_id
WHERE d.customer_id = 'CUS00011'
ORDER BY d.director_id;
-- Expected Bianca Harris (Managing Director) and Felix Winters
-- (Director), both VERIFIED. Director verification != all KYC controls done.

-- QUERY 07 — Check document evidence and the two missing items.
SELECT document_id, case_id, subject_type, subject_id,
       document_type, verification_status, exception_code,
       received_at, verified_at, verified_by
FROM customer_documents
WHERE case_id = 'KYC001207'
ORDER BY document_id;
-- Expected: 3 VERIFIED; OWNERSHIP_DECLARATION and
-- SOURCE_OF_FUNDS_EVIDENCE are MISSING / NOT_RECEIVED.

-- QUERY 08 — Summarize missing vs verified document records.
SELECT verification_status, COUNT(*) AS document_count
FROM customer_documents
WHERE case_id = 'KYC001207'
GROUP BY verification_status
ORDER BY verification_status;
-- Expected: VERIFIED = 3, MISSING = 2. Do not call all documents verified.

-- QUERY 09 — Review the OPEN source-of-wealth information request.
SELECT request_id, case_id, requested_item, relationship_manager_id,
       requested_at, due_at, responded_at, request_status,
       request_detail, closure_note
FROM information_requests
WHERE case_id = 'KYC001207'
ORDER BY requested_at, request_id;
-- Expected: REQ000074 SOURCE_OF_WEALTH OPEN, 23 Oct requested,
-- 30 Oct due. No actual response/closure recorded in source snapshot.

-- QUERY 10 — Inspect screening RUN, separate from case sign-off.
SELECT screening_run_id, case_id, screened_at, screening_scope,
       run_status, potential_hit_count, run_by, source_snapshot_at
FROM screening_runs
WHERE case_id = 'KYC001207';
-- Expected: RUN0001207 COMPLETED, potential_hit_count = 0.
-- This does not make an open checklist step automatically complete.

-- QUERY 11 — Validate screening has no linked hit rows.
SELECT r.screening_run_id, r.run_status, r.potential_hit_count,
       COUNT(h.screening_hit_id) AS actual_hit_rows
FROM screening_runs AS r
LEFT JOIN screening_hits AS h
  ON h.screening_run_id = r.screening_run_id
WHERE r.case_id = 'KYC001207'
GROUP BY r.screening_run_id, r.run_status, r.potential_hit_count;
-- Expected: actual_hit_rows = 0. Zero identified screening hits
-- does not equal zero customer risk or absence of financial crime.

-- QUERY 12 — Examine factor-level synthetic risk contributions.
SELECT f.factor_id, f.factor_name, f.factor_value, f.weight,
       f.weighted_value, f.evidence_note,
       a.assessment_score, a.risk_rating,
       a.edd_required, a.assessment_status
FROM case_risk_factors AS f
JOIN customer_risk_assessments AS a ON f.case_id = a.case_id
WHERE f.case_id = 'KYC001207'
ORDER BY f.factor_id;
-- Expected: five rows; geographic weighted_value = 0.900;
-- total should be 3.714. Values are illustrative, not Citi policy.

-- QUERY 13 — Reconcile assessment score and factor weights.
SELECT a.case_id, a.assessment_score,
       ROUND(SUM(f.weighted_value), 4) AS calculated_score,
       ROUND(SUM(f.weight), 4) AS weight_total,
       ROUND(a.assessment_score - SUM(f.weighted_value), 4)
           AS score_difference,
       a.risk_rating, a.edd_required, a.assessment_status,
       a.methodology
FROM customer_risk_assessments AS a
JOIN case_risk_factors AS f ON a.case_id = f.case_id
WHERE a.case_id = 'KYC001207'
GROUP BY a.case_id, a.assessment_score,
         a.risk_rating, a.edd_required,
         a.assessment_status, a.methodology;
-- Expected: score = 3.714, calculated_score = 3.714,
-- weights = 1.0000, difference = 0, HIGH / YES / DRAFT.

-- QUERY 14 — Identify OPEN mandatory workflow controls.
SELECT check_id, control_name, mandatory, step_status,
       completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC001207'
ORDER BY check_id;
-- Expected: seven OPEN mandatory controls; ANALYST_NOTES COMPLETE.
-- Do not infer technical screening run never occurred.

-- QUERY 15 — Inspect open EDD escalation and assigned role.
SELECT e.escalation_id, e.case_id, e.escalation_type,
       e.raised_at, e.raised_by, e.assigned_to,
       u.role AS assignee_role, e.escalation_status,
       e.resolved_at, e.decision_summary
FROM escalations AS e
LEFT JOIN users AS u ON e.assigned_to = u.user_id
WHERE e.case_id = 'KYC001207';
-- Expected: ESC000050 HIGH_RISK_EDD, 24 Oct, OPEN,
-- assigned to USR026 COMPLIANCE_SPECIALIST; decision pending.

-- QUERY 16 — Inspect existing notes and evidence quality.
SELECT note_id, created_at, author_id, note_type,
       note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC001207'
ORDER BY created_at, note_id;
-- Expected: one INTAKE and one generic INVESTIGATION note.
-- Verify specifics instead of copying generic 'incomplete screening'.

-- QUERY 17 — Read original case audit history in time order.
SELECT event_id, event_at, actor_id, event_type,
       related_table, related_record_id, old_value,
       new_value, event_comment
FROM case_audit_log
WHERE case_id = 'KYC001207'
ORDER BY event_at, event_id;
-- Expected: five original synthetic events. Training edits may append more.
-- Note: status transition 23 Oct precedes escalation raised 24 Oct.

-- QUERY 18 — Confirm QC, approval, disposition remain absent.
SELECT k.case_id,
       (SELECT COUNT(*) FROM qc_reviews AS q
        WHERE q.case_id = k.case_id) AS qc_review_count,
       (SELECT COUNT(*) FROM case_approvals AS a
        WHERE a.case_id = k.case_id) AS approval_count,
       (SELECT COUNT(*) FROM case_dispositions AS d
        WHERE d.case_id = k.case_id) AS disposition_count
FROM kyc_cases AS k
WHERE k.case_id = 'KYC001207';
-- Expected: 0 QC reviews, 0 approvals, 0 final dispositions
-- for this case. Never say compliance approved it.

-- QUERY 19 — Compare declared source narratives with expectations.
SELECT customer_id, legal_name, industry,
       source_of_funds, source_of_wealth,
       expected_monthly_volume_usd, expected_monthly_tx_count,
       product_type, channel
FROM customers
WHERE customer_id = 'CUS00011';
-- Expected: Rental income, Investments, $206,000 expected monthly,
-- 14 expected monthly transactions. These are NOT observed flows.

-- QUERY 20 — Examine the fictional geographic-risk label.
SELECT c.customer_id, c.legal_name, c.country_code,
       g.country_name, g.example_geo_risk,
       g.is_synthetic_risk_label
FROM customers AS c
LEFT JOIN countries AS g ON c.country_code = g.country_code
WHERE c.customer_id = 'CUS00011';
-- Expected: AE, United Arab Emirates, label HIGH, synthetic flag YES.
-- Do not claim the model reflects a real jurisdiction's official risk.

-- QUERY 21 — Reconcile two different outstanding evidence gaps.
SELECT c.case_id,
       COUNT(DISTINCT CASE WHEN d.document_type = 'SOURCE_OF_FUNDS_EVIDENCE'
                              AND d.verification_status = 'MISSING'
                           THEN d.document_id END) AS missing_sof_documents,
       COUNT(DISTINCT CASE WHEN d.document_type = 'OWNERSHIP_DECLARATION'
                              AND d.verification_status = 'MISSING'
                           THEN d.document_id END) AS missing_ownership_declarations,
       (SELECT COUNT(*) FROM information_requests AS r
        WHERE r.case_id = c.case_id
          AND r.requested_item = 'SOURCE_OF_WEALTH'
          AND r.request_status = 'OPEN') AS open_sow_requests
FROM kyc_cases AS c
LEFT JOIN customer_documents AS d ON c.case_id = d.case_id
WHERE c.case_id = 'KYC001207'
GROUP BY c.case_id;
-- Expected 1 missing SoF document, 1 missing ownership declaration,
-- 1 open SoW request; do not conflate SoF evidence and SoW request.

-- QUERY 22 — Flag the chronology discrepancy without rewriting records.
SELECT k.case_id, e.event_id,
       e.event_at AS case_status_event_at, e.new_value AS status_to,
       s.escalation_id, s.raised_at AS escalation_raised_at,
       CASE WHEN e.event_at < s.raised_at
            THEN 'STATUS_EVENT_PRECEDES_ESCALATION_RECORD'
            ELSE 'NO_EARLIER_STATUS_EVENT'
       END AS chronology_check
FROM kyc_cases AS k
JOIN case_audit_log AS e
  ON e.case_id = k.case_id AND e.event_type = 'CASE_STATUS'
JOIN escalations AS s ON s.case_id = k.case_id
WHERE k.case_id = 'KYC001207';
-- Expected: CASE_STATUS event 23 Oct; escalation record 24 Oct.
-- Flag for source/process clarification, not a proven real control breach.
