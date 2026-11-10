-- CLEARCASE KYC | CASE 09 — IRIS MARSHALL | PEP / CLOSE ASSOCIATE REVIEW
-- READ ONLY: use SELECT statements only. USE selects the database; it does not change data.
-- Run each COMPLETE statement through the semicolon in MySQL Workbench or VS Code.
-- Original source: synthetic ClearCase CSV package, not live screening data.
-- Local MySQL may differ from the original snapshot following practice edits.
USE clearcase_kyc;

-- QUERY 01 — Identify the actual customer and PERIODIC review case.
SELECT c.customer_id, c.legal_name, c.customer_type, c.country_code,
       c.nationality_code, c.date_of_birth, c.occupation, c.customer_status,
       c.relationship_manager_id, c.source_of_funds, c.source_of_wealth,
       k.case_id, k.review_type, k.trigger_event, k.opened_at, k.due_at,
       k.priority, k.assigned_analyst_id, k.case_status, k.scenario_id
FROM customers AS c
JOIN kyc_cases AS k ON c.customer_id = k.customer_id
WHERE c.customer_id = 'CUS00009' AND k.case_id = 'KYC001205';
-- WHY: Confirm the exact customer/case; her older 2025 onboarding case is separate.
-- EXPECT: Iris Marshall, GB, PERIODIC, PENDING_SCREENING, HIGH, due 2026-11-13.

-- QUERY 02 — Read the training scenario (not proof of current PEP status).
SELECT scenario_id, case_id, scenario_name, focus_area, analyst_level,
       expected_handling, expected_screening_outcome, learning_points
FROM case_scenarios
WHERE case_id = 'KYC001205';
-- WHY: Scenario title says "Former PEP", which must be reconciled with actual profile.

-- QUERY 03 — Check screening execution and number of potential hits.
SELECT screening_run_id, case_id, customer_id, screened_at, run_status,
       screening_method, screening_scope, potential_hit_count, source_snapshot_at
FROM screening_runs
WHERE case_id = 'KYC001205';
-- EXPECT: RUN0001205, screening run COMPLETED on 2026-10-24, one potential hit.
-- Run COMPLETED does NOT mean the investigation has been cleared.

-- QUERY 04 — Join screening hit to watchlist entity and synthetic source.
SELECT r.case_id, h.screening_hit_id, h.match_score, h.match_basis,
       h.identity_assessment, h.analyst_disposition, h.reviewed_at,
       h.reviewed_by, h.analyst_rationale,
       w.watchlist_entity_id, w.primary_name, w.date_of_birth AS list_dob,
       w.country_code AS list_country, w.record_category, w.record_status,
       w.last_updated, s.source_id, s.source_name, s.dataset_is_synthetic
FROM screening_runs AS r
JOIN screening_hits AS h ON r.screening_run_id = h.screening_run_id
JOIN watchlist_entities AS w ON h.watchlist_entity_id = w.watchlist_entity_id
JOIN screening_sources AS s ON w.source_id = s.source_id
WHERE r.case_id = 'KYC001205';
-- EXPECT: HIT0000355; WL00005; PEP; score 99; CONFIRMED_IDENTITY;
-- ESCALATED_POTENTIAL_TRUE_MATCH; reviewed 2026-10-26.
-- Do not equate a PEP identity match with a sanctions prohibition.

-- QUERY 05 — Compare recorded customer and PEP-list identifiers.
SELECT c.legal_name AS customer_name, c.date_of_birth AS customer_dob,
       c.country_code AS customer_country,
       w.primary_name AS watchlist_name, w.date_of_birth AS watchlist_dob,
       w.country_code AS watchlist_country,
       CASE WHEN c.legal_name = w.primary_name THEN 'MATCH' ELSE 'DIFFERENT' END AS name_check,
       CASE WHEN c.date_of_birth = w.date_of_birth THEN 'MATCH' ELSE 'DIFFERENT' END AS dob_check,
       CASE WHEN c.country_code = w.country_code THEN 'MATCH' ELSE 'DIFFERENT' END AS country_check
FROM kyc_cases AS k
JOIN customers AS c ON k.customer_id = c.customer_id
JOIN screening_runs AS r ON r.case_id = k.case_id
JOIN screening_hits AS h ON h.screening_run_id = r.screening_run_id
JOIN watchlist_entities AS w ON w.watchlist_entity_id = h.watchlist_entity_id
WHERE k.case_id = 'KYC001205' AND h.screening_hit_id = 'HIT0000355';
-- WHY: Evaluate corroborating identifiers, not just the similarity score.

-- QUERY 06 — Read the exact PEP classification and appointment metadata.
SELECT w.watchlist_entity_id, w.primary_name, w.record_category, w.record_status,
       p.pep_id, p.pep_category, p.public_position, p.public_body,
       p.country_code, p.term_start, p.term_end, p.pep_status
FROM watchlist_entities AS w
JOIN pep_profiles AS p ON w.watchlist_entity_id = p.watchlist_entity_id
WHERE w.watchlist_entity_id = 'WL00005';
-- EXPECT: FOREIGN, Minister, CURRENT, empty term_end.
-- DATA QA: Scenario calls Iris 'Former PEP'; actual profile says CURRENT.
-- Do NOT silently change either value. Verify current/historical public role.

-- QUERY 07 — Trace both relationship directions and identify counterpart entities.
SELECT rel.relationship_id, rel.relationship_type, rel.known_from, rel.known_to,
       rel.from_watchlist_entity_id, wf.primary_name AS from_name,
       rel.to_watchlist_entity_id, wt.primary_name AS to_name,
       CASE WHEN rel.from_watchlist_entity_id = 'WL00005'
            THEN rel.to_watchlist_entity_id ELSE rel.from_watchlist_entity_id END
            AS counterpart_id,
       CASE WHEN rel.from_watchlist_entity_id = 'WL00005'
            THEN wt.primary_name ELSE wf.primary_name END AS counterpart_name
FROM watchlist_relationships AS rel
JOIN watchlist_entities AS wf ON rel.from_watchlist_entity_id = wf.watchlist_entity_id
JOIN watchlist_entities AS wt ON rel.to_watchlist_entity_id = wt.watchlist_entity_id
WHERE rel.from_watchlist_entity_id = 'WL00005'
   OR rel.to_watchlist_entity_id = 'WL00005'
ORDER BY rel.relationship_id;
-- EXPECT: WLR00055 (Iris -> Gabriel Graham, CLOSE_ASSOCIATE);
-- WLR00106 (Leo Marshall -> Iris, BUSINESS_ASSOCIATE).
-- Direction is recorded; do not assume an unstated family relationship.

-- QUERY 08 — Inspect counterparts' own PEP/RCA classification and status.
SELECT w.watchlist_entity_id, w.primary_name, w.record_category,
       p.pep_category, p.public_position, p.public_body,
       p.term_start, p.term_end, p.pep_status
FROM watchlist_entities AS w
LEFT JOIN pep_profiles AS p ON p.watchlist_entity_id = w.watchlist_entity_id
WHERE w.watchlist_entity_id IN ('WL00025','WL00293')
ORDER BY w.watchlist_entity_id;
-- EXPECT: Gabriel Graham: INTERNATIONAL_ORGANIZATION, CURRENT.
-- Leo Marshall: RCA, FORMER; recorded role 'Senior Public Official'.
-- Be cautious: semantic consistency of synthetic category/role needs review.

-- QUERY 09 — Confirm current customer documents and their actual status.
SELECT document_id, case_id, document_type, issued_at, expires_at,
       received_at, verification_status, verified_at, exception_code
FROM customer_documents
WHERE case_id = 'KYC001205'
ORDER BY document_id;
-- EXPECT: IDENTITY_PROOF, ADDRESS_PROOF, SOURCE_OF_FUNDS_EVIDENCE, all VERIFIED.
-- Document verification != PEP/EDD clearance.

-- QUERY 10 — Identify mandatory open controls.
SELECT check_id, control_name, mandatory, step_status,
       completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC001205'
ORDER BY check_id;
-- EXPECT: OPEN mandatory screening, customer risk, EDD review, QC approval.

-- QUERY 11 — Read recorded risk assessment; no re-rating in this query.
SELECT assessment_id, case_id, assessment_score, risk_rating,
       edd_required, assessment_status, assessed_at, assessed_by,
       methodology, decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC001205';
-- EXPECT: 3.446, HIGH, YES EDD, DRAFT; illustrative synthetic method.

-- QUERY 12 — Explain the five weighted contributions.
SELECT factor_name, factor_value, weight, weighted_value, evidence_note
FROM case_risk_factors
WHERE case_id = 'KYC001205'
ORDER BY weighted_value DESC;
-- EXPECT: screening exposure = 5 x 0.25 = 1.25.

-- QUERY 13 — Reconcile the risk model arithmetic with the assessment.
SELECT a.case_id, a.assessment_score,
       ROUND(SUM(f.weighted_value),4) AS calculated_score,
       ROUND(SUM(f.weight),4) AS total_weight,
       ROUND(a.assessment_score-SUM(f.weighted_value),4) AS score_difference
FROM customer_risk_assessments AS a
JOIN case_risk_factors AS f ON a.case_id=f.case_id
WHERE a.case_id = 'KYC001205'
GROUP BY a.case_id, a.assessment_score;
-- EXPECT: 3.446, 1.0000, 0.0000.

-- QUERY 14 — Confirm OPEN compliance escalation and decision state.
SELECT escalation_id, case_id, escalation_type, raised_at, raised_by,
       assigned_to, escalation_status, resolved_at, decision_summary
FROM escalations
WHERE case_id = 'KYC001205';
-- EXPECT: ESC000049, PEP_EDD, OPEN, pending compliance review.

-- QUERY 15 — Do not mistake dismissed fictional negative news for active allegations.
SELECT a.media_alert_id, a.case_id, a.match_assessment, a.relevance,
       a.source_reliability, a.investigation_status, a.assessed_at,
       a.investigation_note, ar.article_id, ar.headline,
       ar.event_category, ar.event_stage, ar.credibility_tier,
       ar.is_synthetic
FROM adverse_media_alerts AS a
JOIN adverse_media_articles AS ar ON a.article_id = ar.article_id
WHERE a.case_id = 'KYC001205';
-- EXPECT: AMA000150 FALSE_POSITIVE, LOW relevance, MEDIUM reliability,
-- CLEARED; article AM00002 DISMISSED / fictional.

-- QUERY 16 — Check if a separate open information request exists.
SELECT request_id, requested_item, request_status,
       requested_at, due_at, responded_at, closure_note
FROM information_requests
WHERE case_id = 'KYC001205';
-- EXPECT original CSV: zero rows. An OPEN escalation is NOT an information request.

-- QUERY 17 — Check whether QC or approvals have been independently recorded.
SELECT 'QC_REVIEW' AS record_type, qc_review_id AS record_id, qc_outcome AS decision
FROM qc_reviews WHERE case_id='KYC001205'
UNION ALL
SELECT 'CASE_APPROVAL', approval_id, approval_decision
FROM case_approvals WHERE case_id='KYC001205';
-- EXPECT original snapshot: zero rows (not QC-passed or approved).

-- QUERY 18 — Read existing analyst notes, without writing a duplicate.
SELECT note_id, case_id, author_id, created_at,
       note_type, note_text, evidence_reference
FROM case_notes
WHERE case_id='KYC001205'
ORDER BY created_at, note_id;
-- EXPECT original snapshot: two notes (INTAKE and INVESTIGATION).

-- QUERY 19 — Review recorded audit history for the case.
SELECT event_id, case_id, event_at, actor_id, event_type,
       related_table, related_record_id, old_value, new_value, event_comment
FROM case_audit_log
WHERE case_id='KYC001205'
ORDER BY event_at, event_id;
-- EXPECT: creation, screening run, hit review, escalation, status movement.

-- QUERY 20 — Check screening-versus-reference snapshot chronology.
SELECT r.case_id, r.screened_at, r.source_snapshot_at,
       h.reviewed_at AS hit_reviewed_at,
       s.snapshot_date AS reference_source_snapshot_date,
       w.last_updated AS watchlist_record_last_updated,
       s.dataset_is_synthetic
FROM screening_runs AS r
JOIN screening_hits AS h ON r.screening_run_id=h.screening_run_id
JOIN watchlist_entities AS w ON h.watchlist_entity_id=w.watchlist_entity_id
JOIN screening_sources AS s ON w.source_id=s.source_id
WHERE r.case_id='KYC001205';
-- CAUTION: run/hit review in Oct 24/26 but reference metadata is Oct 31.
-- This does not prove the Oct 31 record existed as-of the Oct 24 screening.

-- QUERY 21 — Distinguish earlier completed onboarding from the new periodic case.
SELECT case_id, customer_id, review_type, opened_at,
       due_at, priority, case_status
FROM kyc_cases
WHERE customer_id='CUS00009'
ORDER BY opened_at;
-- WHY: COMPLETED onboarding KYC000009 is a different historical case;
-- it does not resolve the 2026 PEP alert for KYC001205.
