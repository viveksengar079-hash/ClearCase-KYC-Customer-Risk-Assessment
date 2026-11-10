-- CLEARCASE KYC | CASE 10 — HARBORVIEW CONSULTING | QC REWORK
-- SOURCE: original fictional ClearCase KYC CSV snapshot (05 Nov 2026).
-- Run each FULL query through its semicolon; SELECT statements DO NOT modify data.
-- Query outputs can differ from original CSV snapshot after training edits in MySQL.
USE clearcase_kyc;

-- QUERY 01 — Locate the customer and the exact periodic-review case.
-- WHY: Don't confuse current QC_REWORK with an older completed onboarding case.
-- EXPECT: CUS00010, KYC001206, PERIODIC, QC_REWORK, HIGH, USR002.
SELECT c.customer_id, c.legal_name, c.customer_type, c.country_code,
       c.customer_status, c.relationship_manager_id,
       k.case_id, k.review_type, k.trigger_event, k.opened_at, k.due_at,
       k.priority, k.complexity, k.assigned_analyst_id, k.case_status,
       k.scenario_id
FROM customers AS c
JOIN kyc_cases AS k ON c.customer_id = k.customer_id
WHERE c.customer_id = 'CUS00010'
  AND k.case_id = 'KYC001206';

-- QUERY 02 — Inspect the customer's earlier case separately.
-- WHY: A completed onboarding case doesn't approve a new periodic review.
-- EXPECT: KYC000010 COMPLETED; KYC001206 QC_REWORK.
SELECT case_id, customer_id, review_type, opened_at, due_at,
       case_status, priority, assigned_analyst_id
FROM kyc_cases
WHERE customer_id = 'CUS00010'
ORDER BY opened_at, case_id;

-- QUERY 03 — Retrieve exact QC outcome, defect and checker role.
-- WHY: Fix the checker-recorded defect, not a guessed one.
-- EXPECT: QC000993 RETURNED / MISSING_INVESTIGATION_RATIONALE, USR016 QC_CHECKER.
SELECT q.qc_review_id, q.case_id, q.submitted_at, q.checked_at,
       q.checker_id, u.role AS checker_role,
       q.qc_outcome, q.defect_code, q.checker_comment
FROM qc_reviews AS q
LEFT JOIN users AS u ON q.checker_id = u.user_id
WHERE q.case_id = 'KYC001206';

-- QUERY 04 — Compare maker and checker roles.
-- WHY: Show maker–checker independence in the recorded case.
-- EXPECT: maker USR002 KYC_ANALYST; checker USR016 QC_CHECKER.
SELECT k.case_id, k.assigned_analyst_id AS maker_id,
       mu.role AS maker_role, q.checker_id AS checker_id,
       cu.role AS checker_role,
       CASE WHEN k.assigned_analyst_id = q.checker_id
            THEN 'SAME_ID_CHECK_REQUIRED' ELSE 'DIFFERENT_USERS' END
         AS segregation_check
FROM kyc_cases AS k
JOIN qc_reviews AS q ON k.case_id = q.case_id
LEFT JOIN users AS mu ON k.assigned_analyst_id = mu.user_id
LEFT JOIN users AS cu ON q.checker_id = cu.user_id
WHERE k.case_id = 'KYC001206';

-- QUERY 05 — View document evidence, not merely a checklist summary.
-- WHY: Confirm exactly which document records are VERIFIED.
-- EXPECT: five documents, all VERIFIED, verified 2026-10-14.
SELECT document_id, document_type, subject_type, subject_id,
       verification_status, received_at, verified_at,
       verified_by, exception_code
FROM customer_documents
WHERE case_id = 'KYC001206'
ORDER BY document_id;

-- QUERY 06 — Summarize the document statuses.
-- WHY: Demonstrate that QC return is not automatically a failed document check.
-- EXPECT: VERIFIED = 5; no missing/mismatch/expired document status.
SELECT verification_status, COUNT(*) AS document_count
FROM customer_documents
WHERE case_id = 'KYC001206'
GROUP BY verification_status
ORDER BY verification_status;

-- QUERY 07 — Check screening run and the actual hit count.
-- WHY: A generic note refers to incomplete screening but the recorded run completed.
-- EXPECT: RUN0001206 COMPLETED, potential_hit_count 0, matching_hit_rows 0.
SELECT r.screening_run_id, r.case_id, r.screened_at,
       r.run_status, r.screening_scope, r.potential_hit_count,
       COUNT(h.screening_hit_id) AS matching_hit_rows
FROM screening_runs AS r
LEFT JOIN screening_hits AS h ON r.screening_run_id = h.screening_run_id
WHERE r.case_id = 'KYC001206'
GROUP BY r.screening_run_id, r.case_id, r.screened_at,
         r.run_status, r.screening_scope, r.potential_hit_count;

-- QUERY 08 — Examine the actual existing case notes.
-- WHY: Identify the rationale gap without attributing unrecorded findings.
-- EXPECT: NOTE0002394 (INTAKE), NOTE0002395 (generic INVESTIGATION).
SELECT note_id, case_id, author_id, created_at,
       note_type, note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC001206'
ORDER BY created_at, note_id;

-- QUERY 09 — Identify the state of all eight mandatory checklist controls.
-- WHY: A COMPLETE step isn't the same as a final approval.
-- EXPECT: seven COMPLETE; QC_APPROVAL OPEN.
SELECT check_id, control_name, mandatory,
       step_status, completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC001206'
ORDER BY check_id;

-- QUERY 10 — Retrieve the unresolved corporate-registration request.
-- WHY: Verified incorporation certificate does not automatically close an open request.
-- EXPECT: REQ000073 CORPORATE_REGISTRATION OPEN, due 2026-10-21.
SELECT request_id, case_id, relationship_manager_id, requested_item,
       requested_at, due_at, responded_at,
       request_status, request_detail, closure_note
FROM information_requests
WHERE case_id = 'KYC001206'
ORDER BY request_id;

-- QUERY 11 — Compare the OPEN request with existing incorporation evidence.
-- WHY: Flag an apparent overlap without assuming both records request the same thing.
-- EXPECT: OPEN REQ000073; VERIFIED incorporation certificate DOC0003252.
SELECT ir.request_id, ir.requested_item, ir.request_status,
       ir.request_detail,
       d.document_id, d.document_type, d.verification_status,
       d.received_at, d.verified_at
FROM information_requests AS ir
LEFT JOIN customer_documents AS d
  ON ir.case_id = d.case_id
 AND d.document_type = 'INCORPORATION_CERTIFICATE'
WHERE ir.case_id = 'KYC001206';

-- QUERY 12 — Check overall risk assessment and decisions.
-- WHY: HIGH/EDD YES can coexist with a DRAFT assessment.
-- EXPECT: RA001206, 3.888, HIGH, EDD YES, DRAFT.
SELECT assessment_id, case_id, assessment_score,
       risk_rating, edd_required, assessment_status,
       assessed_at, assessed_by, methodology, decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC001206';

-- QUERY 13 — Review each risk factor and its weighted contribution.
-- WHY: Explain the score to the checker, not just copy a HIGH label.
-- EXPECT: five weighted factors, weights sum to 1.00.
SELECT factor_id, factor_name, factor_value,
       weight, weighted_value, evidence_note
FROM case_risk_factors
WHERE case_id = 'KYC001206'
ORDER BY weighted_value DESC;

-- QUERY 14 — Reconcile calculated score against recorded score.
-- WHY: A draft score can still be mathematically checked.
-- EXPECT: assessment_score 3.888, calculated_score 3.888,
--         total_weight 1.0000, score_difference 0.0000.
SELECT a.case_id, a.assessment_score,
       ROUND(SUM(f.weighted_value), 4) AS calculated_score,
       ROUND(SUM(f.weight), 4) AS total_weight,
       ROUND(a.assessment_score - SUM(f.weighted_value), 4)
         AS score_difference
FROM customer_risk_assessments AS a
JOIN case_risk_factors AS f ON a.case_id = f.case_id
WHERE a.case_id = 'KYC001206'
GROUP BY a.case_id, a.assessment_score;

-- QUERY 15 — Confirm the absence of a final approval/disposition/escalation.
-- WHY: QC RETURNED does not represent a final risk acceptance or approval.
-- EXPECT: approval_count 0, disposition_count 0, escalation_count 0.
SELECT k.case_id,
       (SELECT COUNT(*) FROM case_approvals AS a
         WHERE a.case_id = k.case_id) AS approval_count,
       (SELECT COUNT(*) FROM case_dispositions AS d
         WHERE d.case_id = k.case_id) AS disposition_count,
       (SELECT COUNT(*) FROM escalations AS e
         WHERE e.case_id = k.case_id) AS escalation_count
FROM kyc_cases AS k
WHERE k.case_id = 'KYC001206';

-- QUERY 16 — Read all audit events, including QC and case-status events.
-- WHY: Keep an immutable history and detect event-order problems.
-- EXPECT: five source snapshot events; QC event 15 Oct,
--         CASE_STATUS event recorded 14 Oct (chronology issue).
SELECT event_id, case_id, event_at, actor_id,
       event_type, related_table, related_record_id,
       old_value, new_value, event_comment
FROM case_audit_log
WHERE case_id = 'KYC001206'
ORDER BY event_at, event_id;

-- QUERY 17 — Flag the status/QC date inconsistency explicitly.
-- WHY: QC_REWORK audit event pre-dates the QC's 16 Oct RETURNED outcome.
-- EXPECT: EVENT_DATE_BEFORE_QC_RETURN.
SELECT a.event_id, a.event_at AS status_event_date,
       a.event_type, a.new_value AS case_status_from_event,
       q.qc_review_id, q.checked_at AS qc_return_date,
       q.qc_outcome,
       CASE WHEN a.event_at < q.checked_at
         THEN 'EVENT_DATE_BEFORE_QC_RETURN'
         ELSE 'NO_EARLIER_DATE_FLAG' END AS chronology_check
FROM case_audit_log AS a
JOIN qc_reviews AS q ON a.case_id = q.case_id
WHERE a.case_id = 'KYC001206'
  AND a.event_type = 'CASE_STATUS'
  AND a.new_value = 'QC_REWORK'
  AND q.qc_outcome = 'RETURNED';

-- QUERY 18 — Verify recorded directors as a separate corporate KYC control.
-- WHY: Corporate verification includes people and positions, not just document status.
-- EXPECT: DIR00007 (Alice Sutton), DIR00008 (Eleanor Sterling), VERIFIED.
SELECT d.director_id, d.customer_id, d.party_id,
       p.legal_name AS director_name, d.position_title,
       d.appointed_date, d.verification_status
FROM customer_directors AS d
LEFT JOIN related_parties AS p ON d.party_id = p.party_id
WHERE d.customer_id = 'CUS00010'
ORDER BY d.director_id;

-- QUERY 19 — Compare the historical completed onboarding with this new QC rework.
-- WHY: Prior approvals apply to earlier case only; don't carry them across.
-- EXPECT: older KYC000010 COMPLETED; periodic KYC001206 QC_REWORK.
SELECT k.case_id, k.review_type, k.case_status,
       COUNT(DISTINCT q.qc_review_id) AS qc_record_count,
       COUNT(DISTINCT a.approval_id) AS approval_record_count
FROM kyc_cases AS k
LEFT JOIN qc_reviews AS q ON k.case_id = q.case_id
LEFT JOIN case_approvals AS a ON k.case_id = a.case_id
WHERE k.customer_id = 'CUS00010'
GROUP BY k.case_id, k.review_type, k.case_status
ORDER BY k.case_id;

-- QUERY 20 — Summarize unresolved controls and overdue information requests.
-- WHY: Separate an OPEN checklist control from an OPEN customer request.
-- EXPECT: one OPEN QC_APPROVAL control and one OPEN REQ000073 request.
SELECT k.case_id, k.case_status,
       (SELECT COUNT(*) FROM case_checklist AS cc
        WHERE cc.case_id = k.case_id AND cc.mandatory = 'YES'
          AND cc.step_status <> 'COMPLETE') AS incomplete_mandatory_controls,
       (SELECT COUNT(*) FROM information_requests AS ir
        WHERE ir.case_id = k.case_id AND ir.request_status = 'OPEN')
          AS open_information_requests
FROM kyc_cases AS k
WHERE k.case_id = 'KYC001206';
