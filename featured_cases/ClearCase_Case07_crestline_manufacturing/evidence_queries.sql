-- CLEARCASE KYC | CASE 07 — CRESTLINE MANUFACTURING | EVENT-DRIVEN OWNERSHIP REVIEW
-- READ-ONLY TRAINING CASE: Only SELECTs follow. USE selects the schema.
-- IMPORTANT: Highlight and execute EACH COMPLETE SQL statement through its semicolon in VS Code.
-- Source-snapshot findings must be rechecked against the user's current local MySQL.
USE clearcase_kyc;

-- QUERY 01 — Verify the customer, the case, the recorded trigger and the case owner.
SELECT c.customer_id, c.legal_name, c.customer_type, c.country_code,
       c.customer_status, c.industry, c.relationship_manager_id,
       k.case_id, k.scenario_id, k.review_type, k.trigger_event,
       k.opened_at, k.due_at, k.priority, k.complexity,
       k.assigned_analyst_id, k.case_status
FROM customers AS c
JOIN kyc_cases AS k ON k.customer_id = c.customer_id
WHERE c.customer_id = 'CUS00007' AND k.case_id = 'KYC001204';
-- Why: Reconfirm we are working on the correct event-driven case.
-- Expected original snapshot: OWNERSHIP_CHANGE, opened 2026-10-15,
-- HIGH, COMPLEX, IN_REVIEW, analyst USR010, RM USR023.

-- QUERY 02 — Check how the training scenario describes its intended workflow.
SELECT scenario_id, case_id, scenario_name, analyst_level, focus_area,
       expected_handling, expected_screening_outcome, learning_points
FROM case_scenarios
WHERE case_id = 'KYC001204';
-- Why: Scenario guidance is a learning aid, NOT evidence that a task was completed.

-- QUERY 03 — Join direct ownership links to real person/entity descriptions.
SELECT o.ownership_id, o.owned_entity_id, o.owner_party_id,
       p.legal_name AS owner_name, p.party_type, p.country_code,
       o.share_pct, o.voting_pct, o.effective_date, o.verification_status
FROM corporate_ownership AS o
JOIN related_parties AS p ON p.party_id = o.owner_party_id
WHERE o.owned_entity_type = 'CUSTOMER'
  AND o.owned_entity_id = 'CUS00007'
ORDER BY o.share_pct DESC;
-- Why: Identify the new owner, equity, votes and verification status.
-- Expected: William Nolan 65%/65% PENDING; Noah Nolan 35%/35% VERIFIED.

-- QUERY 04 — Check recorded ownership totals without assuming verification.
SELECT COUNT(*) AS recorded_owner_links,
       ROUND(SUM(share_pct), 2) AS share_pct_total,
       ROUND(SUM(voting_pct), 2) AS voting_pct_total,
       SUM(CASE WHEN verification_status = 'PENDING' THEN 1 ELSE 0 END)
           AS pending_links
FROM corporate_ownership
WHERE owned_entity_type = 'CUSTOMER'
  AND owned_entity_id = 'CUS00007';
-- Why: 100% total checks arithmetic, not legal evidence quality.
-- Expected: 2 links, 100.00 / 100.00, 1 PENDING.

-- QUERY 05 — Compare recorded directors with the owners.
SELECT d.director_id, d.party_id, p.legal_name, p.party_type,
       d.position_title, d.appointed_date, d.verification_status
FROM customer_directors AS d
JOIN related_parties AS p ON p.party_id = d.party_id
WHERE d.customer_id = 'CUS00007'
ORDER BY d.director_id;
-- Why: Director verification and ownership verification are separate controls.
-- Expected: William Nolan Director; Noah Nolan Managing Director; both VERIFIED here.

-- QUERY 06 — Inspect all recorded evidence/document statuses.
SELECT document_id, case_id, subject_type, subject_id,
       document_type, document_reference, received_at,
       verification_status, verified_at, verified_by, exception_code
FROM customer_documents
WHERE case_id = 'KYC001204'
ORDER BY document_id;
-- Why: A VERIFIED OWNERSHIP_DECLARATION does not override a PENDING
-- ownership relationship in corporate_ownership.
-- Expected original snapshot: 5 document rows, all VERIFIED.

-- QUERY 07 — Count the documents, highlighting exceptions if they exist locally.
SELECT verification_status, COUNT(*) AS document_count
FROM customer_documents
WHERE case_id = 'KYC001204'
GROUP BY verification_status;
-- Why: Recheck document QC and identify later changes.

-- QUERY 08 — Read screening-run evidence and recorded scope.
SELECT screening_run_id, case_id, customer_id, screened_subject_type,
       screened_subject_id, screened_at, screening_method, screening_scope,
       run_status, source_snapshot_at, potential_hit_count
FROM screening_runs
WHERE case_id = 'KYC001204';
-- Why: A COMPLETED screening run with zero hits is not proof that all
-- related persons were screened or that every other KYC control is complete.
-- Expected: RUN0001204, COMPLETED, 0 potential hits.

-- QUERY 09 — Verify whether any screening hits are linked to that run.
SELECT r.screening_run_id, r.case_id, h.screening_hit_id,
       h.watchlist_entity_id, h.match_score,
       h.identity_assessment, h.analyst_disposition
FROM screening_runs AS r
LEFT JOIN screening_hits AS h
    ON h.screening_run_id = r.screening_run_id
WHERE r.case_id = 'KYC001204';
-- Why: A NULL screening_hit_id alongside a real run means no hit row
-- was joined; it does not mean screening was never performed.

-- QUERY 10 — Identify OPEN mandatory controls before recommending completion.
SELECT check_id, control_name, mandatory, step_status,
       completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC001204'
ORDER BY control_name;
-- Why: Distinguish data collection from final review and maker-checker signoff.
-- Expected OPEN: OWNERSHIP_UBO, CUSTOMER_RISK_ASSESSMENT, QC_APPROVAL.

-- QUERY 11 — Read the risk assessment, explicitly checking whether it is final.
SELECT assessment_id, case_id, assessment_score, risk_rating,
       edd_required, assessment_status, assessed_at,
       assessed_by, methodology, decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC001204';
-- Why: MEDIUM 3.0510 is a DRAFT illustrative risk result, not case approval.

-- QUERY 12 — Recalculate the individual risk-factor contributions.
SELECT factor_id, factor_name, factor_value, weight, weighted_value,
       ROUND(factor_value * weight, 4) AS recalculated_value,
       ROUND(weighted_value - factor_value * weight, 4) AS difference
FROM case_risk_factors
WHERE case_id = 'KYC001204'
ORDER BY factor_id;
-- Why: Confirm that each factor contribution is factor_value x weight.
-- The SCREENING_EXPOSURE factor is 4.01 despite zero recorded screening hits;
-- do not falsely assert it represents a sanctions match.

-- QUERY 13 — Reconcile total weights with the overall DRAFT assessment.
SELECT a.case_id, a.assessment_score,
       ROUND(SUM(f.weighted_value), 4) AS calculated_score,
       ROUND(SUM(f.weight), 4) AS weight_total,
       ROUND(a.assessment_score - SUM(f.weighted_value), 4) AS score_difference
FROM customer_risk_assessments AS a
JOIN case_risk_factors AS f ON f.case_id = a.case_id
WHERE a.case_id = 'KYC001204'
GROUP BY a.case_id, a.assessment_score;
-- Why: Expect 3.0510, total weight 1.0000, difference 0.0000.

-- QUERY 14 — Find any information requests for updated ownership evidence.
SELECT request_id, case_id, relationship_manager_id,
       requested_item, request_status, requested_at,
       due_at, responded_at, request_detail, closure_note
FROM information_requests
WHERE case_id = 'KYC001204'
ORDER BY requested_at, request_id;
-- Why: The original CSV had ZERO requests for this case.
-- A later local record may be present; do not invent one in the case note.

-- QUERY 15 — Find recorded escalations (if any).
SELECT escalation_id, case_id, escalation_type,
       raised_at, raised_by, assigned_to,
       escalation_status, resolved_at, decision_summary
FROM escalations
WHERE case_id = 'KYC001204';
-- Why: The original snapshot had no escalation row, not proof escalation is prohibited.

-- QUERY 16 — Examine notes, distinguishing generic text from verified findings.
SELECT note_id, case_id, author_id, created_at,
       note_type, note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC001204'
ORDER BY created_at, note_id;
-- Why: Earlier generic follow-up note mentions incomplete screening even though
-- the recorded screening run is COMPLETED with zero hits. Reconcile time/scope.

-- QUERY 17 — Inspect the recorded audit trail for the ownership-triggered case.
SELECT event_id, case_id, event_at, actor_id,
       event_type, related_table, related_record_id,
       old_value, new_value, event_comment
FROM case_audit_log
WHERE case_id = 'KYC001204'
ORDER BY event_at, event_id;
-- Why: Case-created, screening-run and status-change events establish workflow
-- chronology but do not prove underlying shareholder evidence was authenticated.

-- QUERY 18 — Check independent QC records and case approvals separately.
SELECT q.qc_review_id, q.case_id, q.qc_outcome,
       q.checked_at, q.checker_id, q.defect_code, q.checker_comment
FROM qc_reviews AS q
WHERE q.case_id = 'KYC001204';
-- Why: In original source no QC row; do not treat missing QC as QC PASS.

-- QUERY 19 — Check recorded approval decisions separately from QC.
SELECT a.approval_id, a.case_id, a.approval_type,
       a.requested_at, a.decided_at, a.approval_decision, a.approval_note
FROM case_approvals AS a
WHERE a.case_id = 'KYC001204';
-- Why: No source-snapshot approval exists. Approval is not an L2 analyst's
-- unilateral decision in this simulator.

-- QUERY 20 — Compare ownership effective date with event-case initiation.
SELECT k.case_id, k.trigger_event, k.opened_at,
       o.ownership_id, o.effective_date, o.verification_status,
       o.share_pct, o.voting_pct,
       DATEDIFF(k.opened_at, o.effective_date) AS days_from_effective_to_opened
FROM kyc_cases AS k
JOIN corporate_ownership AS o
  ON o.owned_entity_type = 'CUSTOMER'
 AND o.owned_entity_id = k.customer_id
WHERE k.case_id = 'KYC001204'
ORDER BY o.effective_date DESC;
-- Why: New 65% link effective 2026-10-14 precedes opening on 2026-10-15 by 1 day.
-- Old verified 35% link effective 2023-07-15 is not itself the new trigger.
