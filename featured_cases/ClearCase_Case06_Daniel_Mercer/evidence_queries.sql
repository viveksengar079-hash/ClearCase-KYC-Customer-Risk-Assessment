-- CLEARCASE KYC | CASE 06 — DANIEL MERCER | FALSE-POSITIVE SCREENING
-- READ ONLY. All names / sanctions records are fictional and educational.
-- Each query is an independent SELECT. Run a complete statement through its semicolon.
-- Original CSV baseline; verify current MySQL results before publishing.
USE clearcase_kyc;

-- QUERY 01 — Identify the customer, case and current onboarding stage.
SELECT c.customer_id, c.legal_name, c.customer_type,
       c.country_code, c.date_of_birth, c.customer_status,
       c.product_type, c.source_of_funds, c.source_of_wealth,
       k.case_id, k.scenario_id, k.review_type, k.trigger_event,
       k.case_status, k.priority, k.opened_at, k.due_at,
       k.assigned_analyst_id
FROM customers AS c
JOIN kyc_cases AS k ON k.customer_id = c.customer_id
WHERE c.customer_id = 'CUS00002' AND k.case_id = 'KYC000002';
-- Analyst note: Daniel Mercer, DOB 1967-08-22, GB, PROSPECT;
-- onboarding IN_REVIEW, HIGH priority, due 2026-10-23.

-- QUERY 02 — Read screening execution separately from hit review.
SELECT screening_run_id, case_id, customer_id, screened_at,
       screening_method, screening_scope, run_status, run_by,
       source_snapshot_at, potential_hit_count
FROM screening_runs
WHERE case_id = 'KYC000002';
-- Analyst note: RUN0000002, screened 2026-10-10, run COMPLETED,
-- one potential hit. A completed run does NOT settle the KYC case.

-- QUERY 03 — Compare customer and candidate's name, DOB and country.
SELECT c.customer_id,
       c.legal_name AS customer_name,
       c.date_of_birth AS customer_dob,
       c.country_code AS customer_country,
       w.watchlist_entity_id,
       w.primary_name AS watchlist_name,
       w.date_of_birth AS watchlist_dob,
       w.country_code AS watchlist_country,
       w.record_category, w.record_status,
       h.screening_hit_id, h.match_score, h.match_basis,
       h.identity_assessment, h.analyst_disposition,
       h.analyst_rationale,
       CASE WHEN c.date_of_birth = w.date_of_birth
            THEN 'DOB_MATCH' ELSE 'DOB_DIFFERENT' END AS dob_comparison,
       CASE WHEN c.country_code = w.country_code
            THEN 'COUNTRY_MATCH' ELSE 'COUNTRY_DIFFERENT' END AS country_comparison
FROM screening_hits AS h
JOIN screening_runs AS r ON h.screening_run_id = r.screening_run_id
JOIN customers AS c ON r.customer_id = c.customer_id
JOIN watchlist_entities AS w ON h.watchlist_entity_id = w.watchlist_entity_id
WHERE r.case_id = 'KYC000002';
-- Analyst note: Exact name, matching country, DIFFERENT DOB: 1967-08-22
-- vs 1955-05-09. Identity FALSE_POSITIVE, disposition CLEARED_FALSE_POSITIVE.
-- High screening match score 91 is not 91% probability of sanctions guilt.

-- QUERY 04 — Confirm the hit's reviewer, disposition and rationale.
SELECT h.screening_hit_id, r.screening_run_id,
       h.watchlist_entity_id, h.match_score, h.match_basis,
       h.identity_assessment, h.analyst_disposition,
       h.reviewed_at, h.reviewed_by, h.analyst_rationale
FROM screening_hits AS h
JOIN screening_runs AS r ON r.screening_run_id = h.screening_run_id
WHERE r.case_id = 'KYC000002';
-- Analyst note: HIT0000002 reviewed 2026-10-12 by USR004.
-- Existing reason: name alone is insufficient; identifiers conflict.

-- QUERY 05 — Identify the fictional training sanctions source and designation.
SELECT w.watchlist_entity_id, w.primary_name, w.date_of_birth,
       w.country_code, w.record_category, w.record_status, w.is_synthetic,
       s.source_id, s.source_name, s.source_category,
       s.dataset_is_synthetic,
       d.designation_id, d.training_program, d.designation_status,
       d.restriction_type, d.designation_reason
FROM watchlist_entities AS w
JOIN screening_sources AS s ON w.source_id = s.source_id
LEFT JOIN sanctions_designations AS d
  ON d.watchlist_entity_id = w.watchlist_entity_id
WHERE w.watchlist_entity_id = 'WL00002';
-- Analyst note: This is a FICTIONAL active sanctions candidate and training
-- designation. It is NOT evidence that customer Daniel Mercer is designated.

-- QUERY 06 — Check documentation status before relying on DOB evidence.
SELECT document_id, case_id, customer_id, document_type,
       issued_at, expires_at, received_at, verification_status,
       verified_at, verified_by, exception_code
FROM customer_documents
WHERE case_id = 'KYC000002'
ORDER BY document_type;
-- Analyst note: Identity proof and address proof both VERIFIED in snapshot.
-- Review the underlying identity evidence where accessible and authorized.

-- QUERY 07 — Identify incomplete mandatory controls beyond the screening hit.
SELECT control_name, mandatory, step_status,
       completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC000002'
ORDER BY control_name;
-- Analyst note: CUSTOMER_RISK_ASSESSMENT and QC_APPROVAL OPEN;
-- SANCTIONS_PEP_SCREENING COMPLETE, EDD_REVIEW COMPLETE.
-- EDD checklist complete does not necessarily mean EDD was required.

-- QUERY 08 — Examine overall assessment (not the sanctions-hit disposition).
SELECT assessment_id, case_id, assessment_score, risk_rating,
       edd_required, assessment_status, assessed_at,
       assessed_by, methodology, decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC000002';
-- Analyst note: MEDIUM 2.8955; EDD NO; assessment DRAFT.
-- The risk model is synthetic and cannot override mandatory sanctions controls.

-- QUERY 09 — Recalculate each of the five risk contributions.
SELECT factor_id, factor_name, factor_value, weight,
       weighted_value, ROUND(factor_value * weight, 4) AS calculated_value,
       ROUND(weighted_value - factor_value * weight, 4) AS difference
FROM case_risk_factors
WHERE case_id = 'KYC000002'
ORDER BY factor_id;
-- Analyst note: Contributions expected: 0.7100, 0.2000, 0.4395,
-- 0.7960, 0.7500. Examine any non-zero difference.

-- QUERY 10 — Reconcile total weights and assessment score.
SELECT a.case_id, a.assessment_score,
       ROUND(SUM(f.weighted_value), 4) AS calculated_total,
       ROUND(SUM(f.weight), 4) AS total_weight,
       ROUND(a.assessment_score - SUM(f.weighted_value), 4) AS score_difference
FROM customer_risk_assessments AS a
JOIN case_risk_factors AS f ON f.case_id = a.case_id
WHERE a.case_id = 'KYC000002'
GROUP BY a.case_id, a.assessment_score;
-- Analyst note: Expected calculated_total 2.8955, total_weight 1.0000,
-- score_difference 0.0000.

-- QUERY 11 — Check existing investigation notes and their actual dates.
SELECT note_id, case_id, author_id, created_at,
       note_type, note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC000002'
ORDER BY created_at, note_id;
-- Analyst note: Existing generic follow-up note is dated 2026-10-11,
-- earlier than hit clearance dated 2026-10-12. Don't treat as latest outcome.

-- QUERY 12 — Inspect the case's audit history for screening-review events.
SELECT event_id, case_id, event_at, actor_id, event_type,
       related_table, related_record_id,
       old_value, new_value, event_comment
FROM case_audit_log
WHERE case_id = 'KYC000002'
ORDER BY event_at, event_id;
-- Analyst note: Evidence of run and hit review exists; audit and notes may
-- contain an earlier generic case status update. Local app may add new events.

-- QUERY 13 — Compare screening checklist time with hit review time.
SELECT cc.control_name, cc.step_status,
       cc.completed_at AS checklist_completed_at,
       sh.reviewed_at AS hit_reviewed_at,
       sh.identity_assessment, sh.analyst_disposition,
       CASE WHEN cc.completed_at < sh.reviewed_at
            THEN 'CHECKLIST_PRECEDES_HIT_REVIEW'
            ELSE 'NO_EARLIER_CHECKLIST_DATE' END AS chronology_flag
FROM case_checklist AS cc
JOIN screening_runs AS sr ON sr.case_id = cc.case_id
JOIN screening_hits AS sh ON sh.screening_run_id = sr.screening_run_id
WHERE cc.case_id = 'KYC000002'
  AND cc.control_name = 'SANCTIONS_PEP_SCREENING';
-- Analyst note: Checklist COMPLETE 2026-10-11; hit reviewed 2026-10-12.
-- Verify whether the checklist represents execution or completed alert review.

-- QUERY 14 — Check escalation records; absence is a source fact, not an approval.
SELECT escalation_id, case_id, escalation_type, raised_at,
       raised_by, assigned_to, escalation_status, resolved_at,
       decision_summary
FROM escalations
WHERE case_id = 'KYC000002';
-- Analyst note: Original dataset contains zero escalations for this case.

-- QUERY 15 — Check the independent quality-control record.
SELECT qc_review_id, case_id, checker_id,
       submitted_at, checked_at, qc_outcome,
       defect_code, checker_comment
FROM qc_reviews
WHERE case_id = 'KYC000002';
-- Analyst note: Expect zero rows; QC approval is still an open control.

-- QUERY 16 — Check case approval decisions separately from screening clearance.
SELECT approval_id, case_id, approver_id, approval_type,
       requested_at, decided_at, approval_decision, approval_note
FROM case_approvals
WHERE case_id = 'KYC000002';
-- Analyst note: Expect zero rows: false-positive clearance does not approve onboarding.

-- QUERY 17 — Check for an overall case-disposition decision.
SELECT disposition_id, case_id, decision_type, decision_by,
       decided_at, decision_rationale, approval_required, approval_id
FROM case_dispositions
WHERE case_id = 'KYC000002';
-- Analyst note: Expect zero rows: no final case disposition recorded.

-- QUERY 18 — Confirm whether open information requests exist for the case.
SELECT request_id, case_id, relationship_manager_id, requested_item,
       requested_at, due_at, responded_at, request_status,
       request_detail, closure_note
FROM information_requests
WHERE case_id = 'KYC000002';
-- Analyst note: No requests in original baseline. Check live MySQL for changes.
