-- CLEARCASE KYC | CASE 05 — RIVERBEND VENTURES | ADVERSE MEDIA
-- READ ONLY: No INSERT, UPDATE, DELETE, DROP or ALTER statements.
-- Source snapshot 2026-11-05; live MySQL may have later training changes.
-- Execute each entire SELECT statement through its semicolon in VS Code.
USE clearcase_kyc;

-- QUERY 01 — Establish which KYC case and customer are under review.
SELECT c.customer_id, c.legal_name, c.customer_type, c.country_code,
       c.industry, c.relationship_manager_id,
       k.case_id, k.scenario_id, k.review_type, k.trigger_event,
       k.opened_at, k.due_at, k.priority, k.case_status,
       k.complexity, k.assigned_analyst_id
FROM customers AS c
JOIN kyc_cases AS k ON k.customer_id = c.customer_id
WHERE c.customer_id = 'CUS00005' AND k.case_id = 'KYC001202';
-- Analyst note: Expect Riverbend Ventures, periodic HIGH_RISK_REVIEW,
-- case ESCALATED, priority HIGH, due 2026-11-21. Do not confuse with
-- the customer's separate onboarding case.

-- QUERY 02 — Identify the actual individuals connected as directors.
SELECT d.director_id, d.customer_id, d.party_id,
       p.legal_name AS director_name, p.party_type,
       d.position_title, d.appointed_date, d.verification_status
FROM customer_directors AS d
LEFT JOIN related_parties AS p ON p.party_id = d.party_id
WHERE d.customer_id = 'CUS00005'
ORDER BY d.director_id;
-- Analyst note: DIR00003 identifies verified Managing Director Lily Clarke
-- (PTY00006). A director verification is not evidence that an allegation is true.

-- QUERY 03 — Read the case's adverse-media alert exactly as recorded.
SELECT media_alert_id, case_id, article_id,
       screened_subject_type, screened_subject_id,
       match_assessment, relevance, source_reliability,
       investigation_status, investigation_note, assessed_at
FROM adverse_media_alerts
WHERE case_id = 'KYC001202';
-- Analyst note: Expect AMA000149; identity CONFIRMED_IDENTITY,
-- relevance LOW, reliability MEDIUM and investigation ESCALATED.

-- QUERY 04 — Join alert, fictional article, director and party identity.
SELECT a.media_alert_id, a.case_id, a.article_id,
       a.screened_subject_type, a.screened_subject_id,
       rp.legal_name AS screened_person,
       d.position_title, d.verification_status AS director_verification,
       ar.headline, ar.fictional_publisher, ar.published_at,
       ar.event_category, ar.event_stage, ar.credibility_tier,
       ar.is_synthetic, ar.public_url,
       a.match_assessment, a.relevance,
       a.source_reliability, a.investigation_status
FROM adverse_media_alerts AS a
JOIN kyc_cases AS k ON a.case_id = k.case_id
JOIN adverse_media_articles AS ar ON a.article_id = ar.article_id
LEFT JOIN related_parties AS rp
  ON a.screened_subject_type = 'PARTY'
 AND rp.party_id = a.screened_subject_id
LEFT JOIN customer_directors AS d
  ON d.party_id = a.screened_subject_id
 AND d.customer_id = k.customer_id
WHERE a.case_id = 'KYC001202';
-- Analyst note: Fictional FRAUD/INVESTIGATION article (not conviction).
-- The article is NOT a real source. Check the director link belongs to
-- Riverbend and do not equate matched identity with proven misconduct.

-- QUERY 05 — Verify article-subject references and avoid misattribution.
SELECT s.article_subject_id, s.article_id,
       s.subject_type, s.subject_id, s.subject_role,
       p.legal_name AS named_party
FROM adverse_media_subjects AS s
LEFT JOIN related_parties AS p
  ON s.subject_type = 'PARTY' AND s.subject_id = p.party_id
WHERE s.article_id = 'AM00001'
ORDER BY s.article_subject_id;
-- Analyst note: AMS00334 links PARTY PTY00006 as DIRECTOR_NAMED_SUBJECT;
-- other synthetic subjects exist. Do not assume they are the same entity.

-- QUERY 06 — Verify the assigned specialist escalation is unresolved.
SELECT escalation_id, case_id, escalation_type,
       raised_at, raised_by, assigned_to,
       escalation_status, resolved_at, decision_summary
FROM escalations
WHERE case_id = 'KYC001202';
-- Analyst note: ESC000048 ADVERSE_MEDIA OPEN;
-- Pending compliance review. Do not invent a final outcome.

-- QUERY 07 — Confirm original director's official party master details.
SELECT p.party_id, p.legal_name, p.party_type,
       p.country_code, p.date_of_birth, p.party_status,
       d.director_id, d.position_title, d.verification_status
FROM related_parties AS p
JOIN customer_directors AS d ON d.party_id = p.party_id
WHERE d.customer_id = 'CUS00005'
  AND p.party_id = 'PTY00006';
-- Analyst note: Supports the recorded identity and corporate relationship;
-- it does NOT independently substantiate any media allegation.

-- QUERY 08 — Check missing and verified KYC documents.
SELECT document_id, document_type, subject_type, subject_id,
       verification_status, exception_code, received_at, verified_at
FROM customer_documents
WHERE case_id = 'KYC001202'
ORDER BY document_id;
-- Analyst note: 1 INCORPORATION_CERTIFICATE is MISSING/NOT_RECEIVED;
-- registered address, director ID, ownership declaration and funds
-- evidence are VERIFIED. Missing document is independent blocker.

-- QUERY 09 — Identify mandatory controls still awaiting completion.
SELECT control_name, mandatory, step_status,
       completed_at, completed_by
FROM case_checklist
WHERE case_id = 'KYC001202'
ORDER BY check_id;
-- Analyst note: Six OPEN controls and two COMPLETE in source snapshot.
-- Do not conflate completed director/UBO work with final approval.

-- QUERY 10 — Distinguish sanctions/PEP customer-level screening from media alert.
SELECT screening_run_id, case_id, screened_subject_type,
       screened_subject_id, run_status, potential_hit_count,
       screening_scope, screened_at
FROM screening_runs
WHERE case_id = 'KYC001202';
-- Analyst note: Completed customer screening, 0 potential hits.
-- This does not clear the director-specific adverse-media alert.

-- QUERY 11 — Inspect DRAFT overall customer risk assessment.
SELECT assessment_id, case_id, assessment_score, risk_rating,
       edd_required, assessment_status, assessed_at, methodology,
       decision_rationale
FROM customer_risk_assessments
WHERE case_id = 'KYC001202';
-- Analyst note: Expect RA001202 / score 3.579 / HIGH / EDD YES / DRAFT.
-- Synthetic scoring, not a bank's actual methodology.

-- QUERY 12 — Recompute risk score from five recorded contributions.
SELECT f.case_id,
       COUNT(*) AS factor_count,
       ROUND(SUM(f.weight), 4) AS weight_total,
       ROUND(SUM(f.weighted_value), 4) AS calculated_score,
       a.assessment_score AS stored_score,
       ROUND(SUM(f.weighted_value) - a.assessment_score, 4) AS difference
FROM case_risk_factors AS f
JOIN customer_risk_assessments AS a ON a.case_id = f.case_id
WHERE f.case_id = 'KYC001202'
GROUP BY f.case_id, a.assessment_score;
-- Analyst note: 5 factors, total weight 1.0000, calculated and stored
-- score 3.579, difference 0. Factor values are teaching heuristics.

-- QUERY 13 — Show individual factors to explain the HIGH risk model.
SELECT factor_name, factor_value, weight,
       weighted_value, evidence_note
FROM case_risk_factors
WHERE case_id = 'KYC001202'
ORDER BY weighted_value DESC;
-- Analyst note: Screening exposure is 5*0.25=1.25, but this does
-- NOT establish a real adverse-media offence.

-- QUERY 14 — Review note history without adding or changing anything.
SELECT note_id, case_id, note_type, author_id,
       created_at, note_text, evidence_reference
FROM case_notes
WHERE case_id = 'KYC001202'
ORDER BY created_at, note_id;
-- Analyst note: Two source-snapshot notes; update your narrative only
-- from genuine new evidence, never invent a document or decision.

-- QUERY 15 — Inspect the case audit trail including escalation.
SELECT event_id, event_at, actor_id, event_type,
       related_table, related_record_id,
       old_value, new_value, event_comment
FROM case_audit_log
WHERE case_id = 'KYC001202'
ORDER BY event_at, event_id;
-- Analyst note: Expect ESCALATED event EVT0005070 referencing ESC000048.
-- Events may arrive in a different order than sequential event IDs.

-- QUERY 16 — Show absence/presence of final sign-off and information requests.
SELECT 'information_requests' AS record_type, COUNT(*) AS records
FROM information_requests WHERE case_id = 'KYC001202'
UNION ALL
SELECT 'qc_reviews', COUNT(*)
FROM qc_reviews WHERE case_id = 'KYC001202'
UNION ALL
SELECT 'case_approvals', COUNT(*)
FROM case_approvals WHERE case_id = 'KYC001202'
UNION ALL
SELECT 'case_dispositions', COUNT(*)
FROM case_dispositions WHERE case_id = 'KYC001202';
-- Analyst note: All four record counts are zero in original source.
-- The missing incorporation certificate still needs follow-up.
