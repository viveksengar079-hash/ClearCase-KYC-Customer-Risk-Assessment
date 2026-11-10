-- CLEARCASE KYC | CASE 08 — SAMUEL WHITMORE | FUZZY ALIAS / SANCTIONS SCREENING
-- READ-ONLY: Statements below use SELECT (plus USE to choose your schema).
-- Execute EACH COMPLETE statement, from SELECT through semicolon, in VS Code/MySQL.
-- Baseline is the original synthetic CSV; your working database may have later edits.
USE clearcase_kyc;

-- QUERY 01 — Identify the correct prospective customer and onboarding case.
SELECT c.customer_id, c.legal_name, c.customer_type, c.country_code,
       c.nationality_code, c.date_of_birth, c.customer_status,
       c.relationship_manager_id, c.occupation, c.product_type,
       k.case_id, k.scenario_id, k.review_type, k.trigger_event,
       k.opened_at, k.due_at, k.priority, k.assigned_analyst_id,
       k.case_status, k.complexity
FROM customers AS c
JOIN kyc_cases AS k ON k.customer_id = c.customer_id
WHERE c.customer_id = 'CUS00008' AND k.case_id = 'KYC000008';
-- WHY: Avoid mixing identity evidence from different customers/cases.
-- BASELINE: Samuel Whitmore, DOB 1996-06-09, ESCALATED, HIGH, due 2026-10-07.

-- QUERY 02 — Read the scenario objectives without treating them as completed work.
SELECT scenario_id, case_id, scenario_name, analyst_level,
       focus_area, expected_handling, expected_screening_outcome, learning_points
FROM case_scenarios
WHERE case_id = 'KYC000008';
-- WHY: The intended exercise is alias verification and unresolved-match escalation.

-- QUERY 03 — Verify screening execution and original hit count.
SELECT screening_run_id, case_id, customer_id, screened_subject_type,
       screened_subject_id, screened_at, screening_method, screening_scope,
       run_status, run_by, source_snapshot_at, potential_hit_count
FROM screening_runs
WHERE case_id = 'KYC000008';
-- WHY: COMPLETED means screening run finished, not that the hit was cleared.
-- BASELINE: RUN0000008, 2026-09-24, COMPLETED, potential_hit_count=1.

-- QUERY 04 — Connect the hit to the underlying sanctions record and source.
SELECT r.case_id, r.screening_run_id, h.screening_hit_id,
       h.match_score, h.match_basis, h.identity_assessment,
       h.analyst_disposition, h.reviewed_at, h.reviewed_by,
       h.analyst_rationale, w.watchlist_entity_id, w.primary_name,
       w.date_of_birth AS list_date_of_birth, w.country_code AS list_country,
       w.record_category, w.record_status, w.last_updated,
       s.source_id, s.source_name, s.dataset_is_synthetic
FROM screening_runs AS r
JOIN screening_hits AS h ON h.screening_run_id = r.screening_run_id
JOIN watchlist_entities AS w ON w.watchlist_entity_id = h.watchlist_entity_id
JOIN screening_sources AS s ON s.source_id = w.source_id
WHERE r.case_id = 'KYC000008'
ORDER BY h.screening_hit_id;
-- WHY: The hit is UNRESOLVED rather than proven true or cleared false.
-- BASELINE: HIT0000005, score 86, WL00004, SANCTIONS (fictional).

-- QUERY 05 — Find aliases linked to this exact watchlist candidate.
SELECT w.watchlist_entity_id, w.primary_name,
       a.alias_id, a.alias_name, a.alias_type
FROM watchlist_entities AS w
LEFT JOIN watchlist_aliases AS a
  ON a.watchlist_entity_id = w.watchlist_entity_id
WHERE w.watchlist_entity_id = 'WL00004';
-- WHY: The primary name Whitmoor differs from the alias Whitmore.
-- BASELINE: ALS00001 = Samuel Whitmore, TRANSLITERATION.

-- QUERY 06 — Compare the relevant identifiers without assuming an identity match.
SELECT c.customer_id, c.legal_name AS customer_name,
       c.date_of_birth AS customer_dob, c.country_code AS customer_country,
       w.primary_name AS list_primary_name,
       a.alias_name AS list_alias,
       w.date_of_birth AS list_dob,
       w.country_code AS list_country,
       CASE WHEN c.date_of_birth = w.date_of_birth
            THEN 'MATCH' ELSE 'DIFFERENT' END AS dob_comparison,
       CASE WHEN c.country_code = w.country_code
            THEN 'MATCH' ELSE 'DIFFERENT' END AS country_comparison,
       CASE WHEN c.legal_name = a.alias_name
            THEN 'MATCH' ELSE 'DIFFERENT' END AS alias_comparison
FROM customers AS c
JOIN screening_runs AS r ON r.customer_id = c.customer_id
JOIN screening_hits AS h ON h.screening_run_id = r.screening_run_id
JOIN watchlist_entities AS w ON w.watchlist_entity_id = h.watchlist_entity_id
LEFT JOIN watchlist_aliases AS a ON a.watchlist_entity_id = w.watchlist_entity_id
WHERE r.case_id = 'KYC000008' AND h.screening_hit_id = 'HIT0000005';
-- WHY: Alias MATCH and country MATCH do not cancel a major DOB DIFFERENCE.
-- BASELINE: DOB 1996-06-09 versus 1956-09-30; alias name MATCH.

-- QUERY 07 — Flag the reference-data snapshot chronology for QA.
SELECT r.screened_at, r.source_snapshot_at, h.reviewed_at,
       w.last_updated AS entity_last_updated,
       s.snapshot_date AS source_snapshot_date,
       s.source_name, s.region, s.dataset_is_synthetic
FROM screening_runs AS r
JOIN screening_hits AS h ON h.screening_run_id = r.screening_run_id
JOIN watchlist_entities AS w ON w.watchlist_entity_id = h.watchlist_entity_id
JOIN screening_sources AS s ON s.source_id = w.source_id
WHERE h.screening_hit_id = 'HIT0000005';
-- WHY: Screening in September cannot be evidenced by October-only snapshot metadata.
-- Ask for the actual historical list version; do not invent a reason for discrepancy.

-- QUERY 08 — Verify identity and address documents and their timestamps.
SELECT document_id, document_type, subject_type, subject_id,
       received_at, issued_at, expires_at, verification_status,
       verified_at, verified_by, exception_code
FROM customer_documents
WHERE case_id = 'KYC000008'
ORDER BY document_id;
-- WHY: Both documents VERIFIED, but their labels do not prove a DOB reconciliation.

-- QUERY 09 — Document status totals for this case.
SELECT verification_status, COUNT(*) AS document_count
FROM customer_documents
WHERE case_id = 'KYC000008'
GROUP BY verification_status;
-- BASELINE: 2 VERIFIED.

-- QUERY 10 — Open and completed mandatory controls.
SELECT check_id, control_name, mandatory, step_status,
       completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC000008'
ORDER BY check_id;
-- WHY: Screening, risk assessment and QC remain OPEN despite screening execution.

-- QUERY 11 — Inspect the unapproved, illustrative overall risk assessment.
SELECT assessment_id, case_id, assessment_score, risk_rating,
       edd_required, assessment_status, assessed_at, assessed_by,
       methodology, decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC000008';
-- BASELINE: HIGH 3.7135; EDD YES; DRAFT.

-- QUERY 12 — Show each factor and recompute its contribution.
SELECT factor_id, factor_name, factor_value, weight, weighted_value,
       ROUND(factor_value * weight, 4) AS recalculated_value,
       ROUND(weighted_value - factor_value * weight, 4) AS difference
FROM case_risk_factors
WHERE case_id = 'KYC000008'
ORDER BY factor_id;
-- WHY: Synthetic 5-factor scoring is not proof of a sanctions true match.

-- QUERY 13 — Verify that factor weights and score reconcile.
SELECT a.case_id, a.assessment_score,
       ROUND(SUM(f.weight), 4) AS total_weight,
       ROUND(SUM(f.weighted_value), 4) AS calculated_score,
       ROUND(a.assessment_score - SUM(f.weighted_value), 4) AS score_difference
FROM customer_risk_assessments AS a
JOIN case_risk_factors AS f ON f.case_id = a.case_id
WHERE a.case_id = 'KYC000008'
GROUP BY a.case_id, a.assessment_score;
-- BASELINE: weight=1.0000, score=3.7135, difference=0.0000.

-- QUERY 14 — Inspect recorded sanctions-related escalation.
SELECT escalation_id, case_id, escalation_type, raised_at, raised_by,
       assigned_to, escalation_status, resolved_at, decision_summary
FROM escalations
WHERE case_id = 'KYC000008'
ORDER BY raised_at, escalation_id;
-- BASELINE: ESC000003, SANCTIONS_MATCH, OPEN; no resolution recorded.

-- QUERY 15 — Retrieve analyst notes; do not equate a generic note with evidence.
SELECT note_id, case_id, author_id, created_at, note_type,
       note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC000008'
ORDER BY created_at, note_id;
-- WHY: Look for specifics on DOB checks rather than accepting generic wording.

-- QUERY 16 — Retrieve case audit events and review chronology.
SELECT event_id, case_id, event_at, actor_id, event_type,
       related_table, related_record_id, old_value, new_value, event_comment
FROM case_audit_log
WHERE case_id = 'KYC000008'
ORDER BY event_at, event_id;
-- WHY: Identify recorded escalation/hit-review events, not unrecorded decisions.

-- QUERY 17 — Check independent QC records (none in original CSV snapshot).
SELECT qc_review_id, case_id, checker_id, submitted_at,
       checked_at, qc_outcome, defect_code, checker_comment
FROM qc_reviews
WHERE case_id = 'KYC000008';
-- WHY: An escalated screening case should not be called QC-approved without evidence.

-- QUERY 18 — Check actual case approval records (none in original snapshot).
SELECT approval_id, case_id, approver_id, approval_type,
       requested_at, decided_at, approval_decision, approval_note
FROM case_approvals
WHERE case_id = 'KYC000008';
-- WHY: A pending escalation is not authorization to onboard.

-- QUERY 19 — Check documented information requests, if any.
SELECT request_id, case_id, relationship_manager_id,
       requested_item, requested_at, due_at, responded_at,
       request_status, request_detail, closure_note
FROM information_requests
WHERE case_id = 'KYC000008';
-- WHY: The original CSV had no request row; do not invent one.

-- QUERY 20 — Check whether a final case disposition was logged.
SELECT disposition_id, case_id, decision_type, decision_by,
       decided_at, decision_rationale, approval_required, approval_id
FROM case_dispositions
WHERE case_id = 'KYC000008';
-- WHY: This original source contains no final case-level disposition record.
