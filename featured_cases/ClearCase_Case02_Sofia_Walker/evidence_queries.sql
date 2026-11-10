-- CLEARCASE KYC | CASE 02 - SOFIA WALKER (PEP ONBOARDING)
-- All statements below are READ ONLY: SELECTs against the existing local database.
-- Verify each result against the current database before finalizing the case note.
-- In VS Code's SQL editor, select the ENTIRE statement through its semicolon.

USE clearcase_kyc;

-- 1) Confirm the identity and the onboarding case.
-- Why: Do not mix the record of another customer or a separate review.
SELECT
    c.customer_id, c.legal_name, c.customer_type,
    c.country_code, c.nationality_code, c.occupation,
    c.source_of_funds, c.source_of_wealth, c.expected_monthly_volume_usd,
    k.case_id, k.review_type, k.trigger_event, k.case_status,
    k.priority, k.opened_at, k.due_at, k.assigned_analyst_id
FROM customers AS c
JOIN kyc_cases AS k ON c.customer_id = k.customer_id
WHERE c.customer_id = 'CUS00003'
  AND k.case_id = 'KYC000003';

-- 2) Retrieve the actual screening evidence with PEP profile and source.
-- Why: A match score does not prove a sanctions designation or criminality.
SELECT
    sr.screening_run_id, sr.screened_at, sr.run_status,
    sr.screening_method, sr.potential_hit_count,
    sh.screening_hit_id, sh.match_score, sh.match_basis,
    sh.identity_assessment, sh.analyst_disposition,
    sh.analyst_rationale, sh.reviewed_at,
    we.watchlist_entity_id, we.primary_name,
    we.record_category, we.country_code,
    we.date_of_birth AS list_date_of_birth,
    we.last_updated AS list_last_updated,
    pp.pep_id, pp.pep_category, pp.public_position,
    pp.public_body, pp.term_start, pp.term_end, pp.pep_status,
    ss.source_name, ss.source_category,
    ss.dataset_is_synthetic, ss.snapshot_date AS source_snapshot_date
FROM screening_runs AS sr
LEFT JOIN screening_hits AS sh
    ON sr.screening_run_id = sh.screening_run_id
LEFT JOIN watchlist_entities AS we
    ON sh.watchlist_entity_id = we.watchlist_entity_id
LEFT JOIN pep_profiles AS pp
    ON we.watchlist_entity_id = pp.watchlist_entity_id
LEFT JOIN screening_sources AS ss
    ON we.source_id = ss.source_id
WHERE sr.case_id = 'KYC000003'
ORDER BY sr.screened_at, sh.screening_hit_id;

-- 3) Is there a recorded sanctions designation for the matched PEP entity?
-- Why: No matching row in this SYNTHETIC table is not official sanctions clearance.
SELECT *
FROM sanctions_designations
WHERE watchlist_entity_id = 'WL00003';

-- 4) Confirm risk scoring, status and whether EDD is required.
SELECT
    assessment_id, case_id, assessment_score, risk_rating,
    edd_required, assessment_status, assessed_at,
    methodology, decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC000003';

-- 5) Inspect risk-factor scores, weights and evidence notes.
SELECT factor_name, factor_value, weight, weighted_value, evidence_note
FROM case_risk_factors
WHERE case_id = 'KYC000003'
ORDER BY factor_id;

-- 6) Reconcile weighted factors with the recorded overall CRA score.
-- Why: Detect arithmetic mismatches before using scoring as evidence.
SELECT
    r.case_id,
    r.assessment_score AS recorded_score,
    ROUND(SUM(f.weighted_value), 4) AS factor_score_sum,
    ROUND(SUM(f.weight), 4) AS total_weight,
    ROUND(ROUND(SUM(f.weighted_value),4) - r.assessment_score,4)
        AS score_difference
FROM customer_risk_assessments AS r
JOIN case_risk_factors AS f ON r.case_id = f.case_id
WHERE r.case_id = 'KYC000003'
GROUP BY r.case_id, r.assessment_score;

-- 7) Review escalation status and who owns the pending decision.
SELECT
    escalation_id, case_id, escalation_type, raised_at,
    raised_by, assigned_to, escalation_status,
    resolved_at, decision_summary
FROM escalations
WHERE case_id = 'KYC000003';

-- 8) Check outstanding mandatory workflow controls.
SELECT control_name, mandatory, step_status,
       completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC000003'
ORDER BY check_id;

-- 9) Document evidence: VERIFIED statuses are not independent image inspection.
SELECT document_id, document_type, verification_status,
       received_at, expires_at, exception_code
FROM customer_documents
WHERE case_id = 'KYC000003'
ORDER BY document_id;

-- 10) Has the case received any QC review or approval yet?
SELECT * FROM qc_reviews WHERE case_id = 'KYC000003';
SELECT * FROM case_approvals WHERE case_id = 'KYC000003';

-- 11) Audit timeline and existing analyst notes.
SELECT *
FROM case_notes
WHERE case_id = 'KYC000003'
ORDER BY created_at, note_id;

SELECT *
FROM case_audit_log
WHERE case_id = 'KYC000003'
ORDER BY event_at, event_id;

-- 12) Portfolio scenario is training guidance, not an independently verified fact.
SELECT *
FROM case_scenarios
WHERE case_id = 'KYC000003';

-- 13) Optional fixed-date aging check, NOT an automatic SLA determination.
SELECT
    case_id, case_status, due_at,
    DATEDIFF('2026-11-10', due_at) AS days_after_due_date
FROM kyc_cases
WHERE case_id = 'KYC000003';
