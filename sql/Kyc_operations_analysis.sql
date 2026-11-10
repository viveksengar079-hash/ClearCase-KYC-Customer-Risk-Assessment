
USE clearcase_kyc;

-- Check how many KYC cases we have
-- under each review type and status

SELECT
    review_type,
    case_status,
    COUNT(*) AS total_cases
FROM clearcase_kyc.kyc_cases
GROUP BY
    review_type,
    case_status
ORDER BY total_cases DESC;

-- TASK 1: KYC WORKLOAD ANALYSIS
--
-- Observation:
-- I analyzed the distribution of KYC cases based
-- on their review type and current status.
--
-- Key Findings:
-- 1. Onboarding cases with COMPLETED status
--    have the highest number of records.
--
-- 2. Event-driven cases with AWAITING_QC status
--    have the lowest number of records.
--
-- Business Insight:
-- The results show that completed onboarding
-- reviews form the largest group in this dataset.
-- Very few event-driven cases are awaiting QC.
--
-- Analyst Perspective:
-- This gives an overview of the KYC workload.
-- However, case counts alone cannot tell us
-- whether pending reviews are delayed.
--
-- Next Action:
-- Analyze open cases, review deadlines and
-- pending documentation to identify cases
-- that require immediate attention.


-- TASK 2: CUSTOMER-WISE KYC CASE ANALYSIS

--In Task 1, We found how many cases exist under each review type and status.
--But the results didn't tell you which customers those cases belong to.
--Task 2 solves that problem.

SELECT
    k.case_id,
    c.customer_id,
    c.legal_name,
    c.customer_type,
    k.review_type,
    k.case_status,
    k.priority,
    k.due_at
FROM kyc_cases AS k
INNER JOIN customers AS c
    ON k.customer_id = c.customer_id
ORDER BY k.due_at ASC


-- TASK 2B: CUSTOMER TYPE AND REVIEW TYPE ANALYSIS

SELECT
    c.customer_type,
    k.review_type,
    COUNT(*) AS total_cases
FROM kyc_cases AS k
INNER JOIN customers AS c
    ON k.customer_id = c.customer_id
GROUP BY
    c.customer_type,
    k.review_type
ORDER BY
    c.customer_type,
    total_cases DESC;


-- TASK 2B: CUSTOMER TYPE AND REVIEW TYPE ANALYSIS
--
-- Observation:
-- I joined the customers and kyc_cases tables
-- and grouped the records by customer type
-- and KYC review type.
--
-- Key Finding:
-- Individual customers have more KYC cases
-- than corporate customers across all three
-- review types: onboarding, periodic and
-- event-driven.
--
-- Business Insight:
-- Individual customer reviews account for a
-- larger share of the KYC workload.
--
-- However, a higher case count does not
-- necessarily mean higher operational effort,
-- because corporate KYC reviews may require
-- additional ownership and document checks.
--
-- Next Action:
-- Analyze document verification statuses to
-- identify cases requiring follow-up.


-- TASK 3: DOCUMENT VERIFICATION STATUS

SELECT
    verification_status,
    COUNT(*) AS total_documents
FROM customer_documents
GROUP BY verification_status
ORDER BY total_documents DESC;


-- TASK 3: KYC DOCUMENT VERIFICATION ANALYSIS
--
-- Observation:
-- I analyzed 4,664 customer document records
-- to understand their verification status.
--
-- Key Findings:
-- 1. 4,445 documents are verified.
-- 2. 195 documents are missing.
-- 3. 23 documents have mismatched information.
-- 4. 1 document has expired.
--
-- Overall, 219 document records have exceptions,
-- representing approximately 4.7% of the total.
--
-- Business Insight:
-- Most documents are verified, but the remaining
-- exceptions may prevent KYC reviews from being
-- completed until the required checks are done.
--
-- Recommended Action:
-- Identify the customers and cases linked to
-- these exceptions, verify the document issues,
-- and request updated information where required.



-- TASK 4: FIND CUSTOMERS WITH DOCUMENT EXCEPTIONS

SELECT
    k.case_id,
    c.legal_name,
    c.customer_type,
    d.document_type,
    d.verification_status,
    d.exception_code,
    k.case_status,
    k.due_at
FROM customer_documents AS d

INNER JOIN kyc_cases AS k
    ON d.case_id = k.case_id

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

WHERE d.verification_status IN (
    'MISSING',
    'MISMATCH',
    'EXPIRED'
)

ORDER BY
    CASE
        WHEN d.verification_status = 'EXPIRED' THEN 1
        WHEN d.verification_status = 'MISMATCH' THEN 2
        WHEN d.verification_status = 'MISSING' THEN 3
    END,
    k.due_at ASC

LIMIT 20;


-- TASK 4: CUSTOMER DOCUMENT EXCEPTION ANALYSIS
--
-- Observation:
-- I joined customer_documents, kyc_cases,
-- and customers to identify which customers
-- have missing, mismatched or expired documents.
--
-- Key Finding:
-- I identified Alice Bennett, an individual
-- customer, whose identity proof was marked
-- EXPIRED with exception code EXPIRED_AT_REVIEW.
--
-- Her KYC case is currently in
-- PENDING_INFORMATION status.
--
-- Business Insight:
-- An expired identity document may require
-- updated evidence before the KYC review
-- can be completed.
--
-- Recommended Action:
-- Check the customer's other documents and
-- existing information requests.
--
-- If updated identity proof is required,
-- follow up with the appropriate team and
-- document the resolution before case closure.


-- TASK 5: CUSTOMER DOCUMENT REVIEW

SELECT
    k.case_id,
    c.legal_name,
    d.document_type,
    d.verification_status,
    d.exception_code,
    k.case_status
FROM customers AS c

INNER JOIN kyc_cases AS k
    ON c.customer_id = k.customer_id

INNER JOIN customer_documents AS d
    ON k.case_id = d.case_id

WHERE c.legal_name = 'Alice Bennett'

ORDER BY
    k.case_id,
    d.document_type;

-- This is a plausible KYC refresh scenario: a document that was valid during an earlier review may expire before a subsequent review.
-- However, we haven't yet confirmed whether KYC000006 was an onboarding case and KYC001203 was a periodic review.

--Lets verify the review types for these two cases.


-- TASK 5A: VERIFY ALICE BENNETT'S REVIEW HISTORY

SELECT
    k.case_id,
    c.legal_name,
    k.review_type,
    k.case_status,
    k.due_at
FROM kyc_cases AS k
INNER JOIN customers AS c
    ON k.customer_id = c.customer_id
WHERE c.legal_name = 'Alice Bennett'
ORDER BY k.case_id;


-- TASK 5: CUSTOMER DOCUMENT INVESTIGATION
--
-- Observation:
-- I investigated Alice Bennett's KYC records
-- and identified two separate reviews.
--
-- Key Findings:
-- During onboarding (KYC000006), both identity
-- and address proofs were verified, and the
-- KYC case was completed.
--
-- During periodic review (KYC001203), I found
-- that her identity proof was marked EXPIRED.
-- However, her address proof and source of
-- funds evidence were verified.
--
-- The periodic review is currently marked
-- PENDING_INFORMATION.
--
-- Business Insight:
-- Documents verified during onboarding may
-- expire before a subsequent periodic review.
-- Therefore, previous KYC completion does not
-- remove the need for updated verification.
--
-- Recommended Action:
-- Check existing information requests to
-- determine whether updated identity proof
-- has already been requested.
--
-- The case should not be completed until the
-- applicable documentation requirements and
-- other outstanding checks are satisfied.



-- TASK 6: CHECK EXISTING INFORMATION REQUESTS

SELECT *
FROM information_requests
WHERE case_id = 'KYC001203';


-- TASK 6: INFORMATION REQUEST INVESTIGATION
--
-- Observation:
-- I investigated the pending information
-- requests for Alice Bennett's periodic
-- KYC review (KYC001203).
--
-- Key Findings:
-- The customer's identity proof was marked
-- EXPIRED during the periodic review.
--
-- I found that an information request had
-- already been raised for REFRESH_IDENTITY.
-- The request is currently OPEN.
--
-- Business Insight:
-- This indicates that an identity refresh
-- has already been requested, but the
-- information request remains unresolved.
--
-- Analyst Action:
-- Instead of raising a duplicate request,
-- I would check the existing request,
-- review its deadline and follow up with
-- the responsible team when required.
--
-- Once updated evidence is received,
-- I would verify it and document the
-- findings before recommending case closure.



-- TASK 7: CHECK KYC CASE PRIORITY AND DEADLINE

SELECT
    k.case_id,
    c.legal_name,
    k.review_type,
    k.case_status,
    k.priority,
    k.due_at
FROM kyc_cases AS k
INNER JOIN customers AS c
    ON k.customer_id = c.customer_id
WHERE k.case_id = 'KYC001203';
 -- Alice's identity proof expired during her periodic review.
 -- An information request for updated identity evidence was raised.
 -- That request remains open.
 -- The KYC case is HIGH priority and was already past its deadline at the dataset. 


 
-- TASK 7: KYC CASE PRIORITY AND DEADLINE
--
-- Observation:
-- I checked the priority and due date of
-- Alice Bennett's periodic KYC review.
--
-- Key Findings:
-- The case KYC001203 is marked HIGH priority
-- with a deadline of 29 October 2026.
--
-- As of the dataset snapshot (05 Nov 2026),
-- the case was 7 calendar days overdue.
--
-- The customer's identity proof is expired,
-- and the REFRESH_IDENTITY request is still open.
--
-- Business Insight:
-- This case requires attention because the
-- review deadline has passed while the
-- required information remains outstanding.
--
-- Recommended Action:
-- Check the existing information request,
-- its follow-up history and escalation status.
--
-- Coordinate with the responsible team
-- and escalate according to the applicable
-- KYC review and SLA procedures.


-- TASK 8: CHECK EXISTING CASE ESCALATIONS

SELECT *
FROM escalations
WHERE case_id = 'KYC001203';

 -- We have now identified a potentially important operational gap in Alice Bennett's KYC review

-- TASK 8: KYC ESCALATION VERIFICATION
--
-- Observation:
-- I checked the escalations table for
-- Alice Bennett's periodic review KYC001203.
--
-- Key Finding:
-- No escalation record was found for this case.
--
-- The case is HIGH priority, its deadline
-- was 29 October 2026, and the identity
-- refresh information request remains OPEN.
--
-- Business Insight:
-- The case was 7 calendar days past its
-- deadline at the dataset snapshot, with
-- no escalation recorded in the table.
--
-- This may indicate a need for additional
-- operational follow-up.
--
-- Recommended Action:
-- Review the request follow-up history and
-- applicable escalation rules.
--
-- If required, notify the responsible
-- supervisor and document the escalation.


-- TASK 9: REVIEW CUSTOMER CASE ACTIVITY

SELECT *
FROM case_audit_log
WHERE case_id = 'KYC001203';

--
-- TASK 9: CASE ACTIVITY HISTORY ANALYSIS
--
-- Observation:
-- I reviewed the audit history for Alice
-- Bennett's periodic KYC case KYC001203.
--
-- Key Findings:
-- 08 Oct: The case was created as OPEN.
-- 09 Oct: A screening run was completed.
-- 10 Oct: An identity-refresh information
--         request was created.
-- 10 Oct: The case status changed from
--         OPEN to PENDING_INFORMATION.
--
-- The last recorded audit event was on
-- 10 October 2026.
--
-- The case was due on 29 October 2026,
-- but remained pending at the dataset
-- snapshot of 05 November 2026.
--
-- No escalation record was found.
--
-- Business Insight:
-- The case had an outstanding information
-- request and was past its review deadline.
-- No further activities appeared in the
-- case audit history after 10 October.
--
-- Recommended Action:
-- Check the information request follow-up
-- history and any case notes before deciding
-- whether additional escalation is required.


--=======================================================================
-- FINAL INVESTIGATION: ALICE BENNETT
-- CASE ID: KYC001203
--=======================================================================

-- I investigated Alice Bennett's periodic
-- KYC review and found that her identity
-- proof was expired.
--
-- During her previous onboarding review,
-- her identity and address documents were
-- verified and the case was completed.
--
-- An information request was raised on
-- 10 Oct 2026 for REFRESH_IDENTITY,
-- assigned to RM USR020.
--
-- The request was due on 17 Oct 2026
-- but remains OPEN.
--
-- The KYC review was due on 29 Oct 2026
-- and remains PENDING_INFORMATION.
--
-- As of 05 Nov 2026:
-- Information request: 19 days overdue.
-- KYC review: 7 days overdue.
--
-- No escalation was recorded, and no
-- further case activity appeared in the
-- audit history after 10 Oct.
--
-- ANALYST RECOMMENDATION:
-- Follow up with RM USR020 regarding the
-- outstanding identity refresh.
--
-- Review whether escalation is required
-- under the applicable KYC procedures.
--
-- Keep the review pending until the
-- required documentation is verified.
--
-- Note: This is a simulated investigation,
-- not a completed banking compliance decision.



-- TASK 11: IDENTIFY OVERDUE HIGH-PRIORITY KYC CASES

SELECT
    k.case_id,
    c.legal_name,
    c.customer_type,
    k.review_type,
    k.case_status,
    k.priority,
    k.due_at,
    DATEDIFF('2026-11-05', k.due_at) AS overdue_days

FROM kyc_cases AS k

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

WHERE k.priority = 'HIGH'
  AND k.case_status = 'PENDING_INFORMATION'
  AND k.due_at < '2026-11-05'

ORDER BY overdue_days DESC;


-- TASK 11: HIGH-PRIORITY OVERDUE KYC CASES
--
-- Observation:
-- I analyzed KYC cases to identify
-- high-priority reviews that were overdue
-- and still pending customer information.
--
-- Key Findings:
-- A total of 16 cases were identified.
--
-- Henry Morgan had the longest outstanding
-- review, at 51 calendar days overdue
-- as of 05 November 2026.
--
-- Business Insight:
-- These cases require operational attention
-- because their review deadlines have passed
-- while information remains outstanding.
--
-- Recommended Action:
-- Prioritize reviewing the most overdue cases.
-- Check outstanding information requests,
-- follow-up records and escalation status
-- before deciding the next action.



-- TASK 11A: INVESTIGATE HENRY MORGAN'S OVERDUE CASE

SELECT
    k.case_id,
    c.legal_name,
    c.customer_type,
    k.review_type,
    k.case_status,
    k.priority,
    k.due_at,
    DATEDIFF('2026-11-05', k.due_at) AS overdue_days

FROM kyc_cases AS k

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

WHERE c.legal_name = 'Henry Morgan'
  AND k.priority = 'HIGH'
  AND k.case_status = 'PENDING_INFORMATION'
  AND k.due_at < '2026-11-05'

ORDER BY overdue_days DESC;


-- TASK 11A: HENRY MORGAN CASE REVIEW
--
-- Observation:
-- I investigated the most overdue case
-- from the high-priority KYC backlog.
--
-- Key Findings:
-- Customer: Henry Morgan
-- Case ID: KYC001372
-- Review Type: EVENT_DRIVEN
-- Priority: HIGH
-- Status: PENDING_INFORMATION
-- Overdue: 51 calendar days
--
-- Business Insight:
-- This event-driven review requires
-- further investigation to understand
-- the trigger and outstanding information.
--
-- Next Action:
-- Check existing information requests
-- before deciding on further follow-up.



-- TASK 11B: CHECK HENRY MORGAN'S
-- OUTSTANDING INFORMATION REQUESTS

SELECT *
FROM information_requests
WHERE case_id = 'KYC001372';



-- TASK 11C: VERIFY UBO REQUEST APPLICABILITY

SELECT
    k.case_id,
    c.customer_id,
    c.legal_name,
    c.customer_type,
    k.review_type,
    ir.*

FROM kyc_cases AS k

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

INNER JOIN information_requests AS ir
    ON k.case_id = ir.case_id

WHERE k.case_id = 'KYC001372';



-- TASK 11D: CHECK UBO DECLARATIONS
-- REQUESTED FROM INDIVIDUAL CUSTOMERS

SELECT
    COUNT(*) AS total_ubo_requests,
    COUNT(DISTINCT k.case_id) AS affected_cases,
    COUNT(DISTINCT c.customer_id) AS affected_customers

FROM information_requests AS ir

INNER JOIN kyc_cases AS k
    ON ir.case_id = k.case_id

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

WHERE c.customer_type = 'INDIVIDUAL'
  AND ir.requested_item = 'UBO_DECLARATION';



-- TASK 11E: IDENTIFY INDIVIDUAL CUSTOMERS
-- WITH UBO DECLARATION REQUESTS

SELECT
    c.customer_id,
    c.legal_name,
    c.customer_type,
    k.review_type,
    ir.*

FROM information_requests AS ir

INNER JOIN kyc_cases AS k
    ON ir.case_id = k.case_id

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

WHERE c.customer_type = 'INDIVIDUAL'
  AND ir.requested_item = 'UBO_DECLARATION'

ORDER BY c.legal_name;



-- TASK 11F: CHECK HENRY MORGAN'S ESCALATION HISTORY

SELECT *
FROM escalations
WHERE case_id = 'KYC001372';


-- TASK 11F: ESCALATION VERIFICATION
--
-- Observation:
-- I checked the escalation history for
-- Henry Morgan's KYC case KYC001372.
--
-- Key Findings:
-- No escalation record was found.
--
-- The event-driven review is HIGH priority,
-- remains PENDING_INFORMATION and was
-- 51 calendar days overdue as of 05 Nov 2026.
--
-- An outstanding UBO_DECLARATION request
-- was also identified for this individual.
--
-- Business Insight:
-- The case requires operational follow-up
-- and clarification of the document request.
--
-- Recommended Action:
-- Contact the responsible RM (USR024).
-- Verify why UBO information was requested.
-- Review applicable escalation procedures
-- and refer the overdue case to a supervisor
-- where required.
--
-- Do not close the case without resolving
-- the outstanding KYC requirements.


-- TASK 12: IDENTIFY SCREENING TABLES

SHOW TABLES LIKE '%screen%';


-- TASK 12A: UNDERSTAND SCREENING TABLE STRUCTURE

-- Check reference screening sources
DESCRIBE screening_sources;

-- Check screening execution records
DESCRIBE screening_runs;

-- Check potential screening matches
DESCRIBE screening_hits;


-- TASK 12B: CHECK SCREENING DATA VOLUME

SELECT
    'screening_sources' AS table_name,
    COUNT(*) AS total_records
FROM screening_sources

UNION ALL

SELECT
    'screening_runs',
    COUNT(*)
FROM screening_runs

UNION ALL

SELECT
    'screening_hits',
    COUNT(*)
FROM screening_hits;



-- TASK 12B: EXAMINE SCREENING RECORDS

SELECT *
FROM screening_sources
LIMIT 5;

SELECT *
FROM screening_runs
LIMIT 5;

SELECT *
FROM screening_hits
LIMIT 5;


-- TASK 12B: SCREENING DATA EXPLORATION
--
-- Observation:
-- I examined the screening sources,
-- screening runs and screening hits.
--
-- Key Findings:
-- Screening sources: 12
-- Screening runs: 1,630
-- Screening hits: 493
--
-- The dataset includes synthetic
-- sanctions and PEP screening sources.
--
-- Screening hits include confirmed
-- identity matches, false positives
-- and unresolved matches.
--
-- Business Insight:
-- A high match score does not necessarily
-- indicate a genuine identity match.
--
-- Analyst Action:
-- Investigate the matched entity,
-- compare available identity details
-- and verify the relevant screening
-- category before recommending action.



-- TASK 12C: SCREENING INVESTIGATION OUTCOMES

SELECT
    identity_assessment,
    analyst_disposition,
    COUNT(*) AS total_hits

FROM screening_hits

GROUP BY
    identity_assessment,
    analyst_disposition

ORDER BY total_hits DESC;



-- TASK 12C: SCREENING INVESTIGATION OUTCOMES
--
-- Observation:
-- I analyzed screening hits to understand
-- their identity assessments and recorded
-- analyst dispositions.
--
-- Key Findings:
-- Total screening hits: 493
--
-- False positives cleared: 470 (95.3%)
-- Unresolved hits escalated: 20 (4.1%)
-- Confirmed identity matches escalated: 3 (0.6%)
--
-- Business Insight:
-- Most screening hits were classified
-- as false positives and cleared.
--
-- However, 23 hits were escalated,
-- including unresolved and confirmed
-- identity matches.
--
-- Recommended Action:
-- Review escalated hits with supporting
-- identity evidence and watchlist details.
--
-- Confirm whether a hit involves sanctions,
-- PEP or another screening category before
-- determining the appropriate next action.


-- TASK 12D: IDENTIFY WATCHLIST DATA TABLES

SHOW TABLES LIKE '%watchlist%';


-- TASK 12E: UNDERSTAND WATCHLIST ENTITIES

-- Step 1: Check the available columns
DESCRIBE watchlist_entities;

-- Step 2: Examine the first five records
SELECT *
FROM watchlist_entities
LIMIT 5;


-- TASK 12E: WATCHLIST ENTITY EXPLORATION
--
-- Observation:
-- I examined the watchlist_entities table
-- to understand the reference records
-- used in customer screening.
--
-- Key Findings:
-- Total watchlist records: 878
--
-- The sample includes both SANCTIONS
-- and PEP records, with identity fields
-- such as name, country and date of birth.
--
-- Business Insight:
-- These details can help analysts
-- compare customer identities against
-- potentially matching watchlist records.
--
-- Next Action:
-- Join screening hits with customers,
-- watchlist entities and screening sources
-- to investigate confirmed identity matches.



-- TASK 12F: INVESTIGATE CONFIRMED
-- WATCHLIST IDENTITY MATCHES

SELECT
    r.case_id,
    c.legal_name AS customer_name,
    h.screening_hit_id,
    w.watchlist_entity_id,
    w.primary_name AS watchlist_name,
    w.date_of_birth,
    w.country_code,
    w.record_category,
    s.source_name,
    h.match_score,
    h.match_basis,
    h.identity_assessment,
    h.analyst_disposition

FROM screening_hits AS h

INNER JOIN screening_runs AS r
    ON h.screening_run_id = r.screening_run_id

INNER JOIN customers AS c
    ON r.customer_id = c.customer_id

INNER JOIN watchlist_entities AS w
    ON h.watchlist_entity_id = w.watchlist_entity_id

INNER JOIN screening_sources AS s
    ON w.source_id = s.source_id

WHERE h.identity_assessment = 'CONFIRMED_IDENTITY'

ORDER BY
    w.record_category,
    h.match_score DESC;



-- TASK 12F: CONFIRMED WATCHLIST MATCHES
--
-- Observation:
-- I joined the screening records with
-- customer information, watchlist entities
-- and screening sources.
--
-- Key Findings:
-- Three confirmed identity matches
-- were identified.
--
-- Owen Ashford: SANCTIONS
-- Sofia Walker: PEP
-- Iris Marshall: PEP
--
-- Business Insight:
-- The results show that one confirmed
-- identity match involves a sanctions
-- watchlist record, while two involve
-- PEP records.
--
-- Recommended Action:
-- Prioritize Owen Ashford for sanctions
-- investigation and review the supporting
-- identity evidence and escalation status.
--
-- The two PEP cases will be examined
-- separately during PEP screening analysis.



-- TASK 12G: INVESTIGATE OWEN ASHFORD
-- CUSTOMER IDENTITY

-- Step 1: Examine customer table fields
DESCRIBE customers;

-- Step 2: Retrieve Owen's customer details
SELECT *
FROM customers
WHERE legal_name = 'Owen Ashford';


-- TASK 12G: OWEN ASHFORD IDENTITY VERIFICATION
--
-- Observation:
-- I compared Owen Ashford's customer
-- identity details with the matched
-- sanctions watchlist record WL000001.
--
-- Key Findings:
-- Customer name: Owen Ashford
-- Watchlist name: Owen Ashford
--
-- Date of birth: MATCHED
-- Country: MATCHED
-- Watchlist category: SANCTIONS
--
-- Business Insight:
-- The matching identity attributes
-- support the recorded confirmed identity
-- assessment in the synthetic dataset.
--
-- Recommended Action:
-- Review the sanctions source, existing
-- analyst disposition and escalation
-- records before documenting the
-- final investigation recommendation.



-- TASK 12H: CHECK OWEN ASHFORD'S
-- SANCTIONS SCREENING DISPOSITION

SELECT
    r.case_id,
    r.screened_at,
    h.screening_hit_id,
    w.primary_name AS watchlist_name,
    w.record_category,
    w.record_status,
    s.source_name,
    s.region,
    h.match_score,
    h.match_basis,
    h.identity_assessment,
    h.analyst_disposition,
    h.reviewed_at

FROM screening_hits AS h

INNER JOIN screening_runs AS r
    ON h.screening_run_id = r.screening_run_id

INNER JOIN watchlist_entities AS w
    ON h.watchlist_entity_id = w.watchlist_entity_id

INNER JOIN screening_sources AS s
    ON w.source_id = s.source_id

WHERE h.screening_hit_id = 'HIT0000001';


-- TASK 12H: OWEN ASHFORD SANCTIONS REVIEW
--
-- Observation:
-- I examined the existing analyst decision
-- for Owen Ashford's sanctions screening hit.
--
-- Key Findings:
-- Screening source:
-- Training US Restriction Reference
--
-- Match basis: EXACT_NAME_AND_IDENTIFIERS
-- Identity assessment: CONFIRMED_IDENTITY
-- Analyst disposition:
-- ESCALATED_POTENTIAL_TRUE_MATCH
-- Reviewed on: 08 October 2026
--
-- Business Insight:
-- The matching name, date of birth and
-- country support the recorded identity
-- assessment.
--
-- The screening hit was escalated
-- as a potential true match rather than
-- cleared as a false positive.
--
-- Recommended Action:
-- Verify the related case-level escalation
-- and review the available case evidence.
--
-- Any final sanctions decision should
-- follow applicable compliance procedures.



-- TASK 12I: VERIFY SANCTIONS CASE ESCALATION

SELECT
    r.case_id,
    h.screening_hit_id,
    h.analyst_disposition,
    e.*

FROM screening_hits AS h

INNER JOIN screening_runs AS r
    ON h.screening_run_id = r.screening_run_id

LEFT JOIN escalations AS e
    ON r.case_id = e.case_id

WHERE h.screening_hit_id = 'HIT0000001';


-- TASK 12I: SANCTIONS ESCALATION VERIFICATION
--
-- Observation:
-- I checked the case-level escalation
-- for Owen Ashford's sanctions screening.
--
-- Key Findings:
-- The screening hit was classified as
-- CONFIRMED_IDENTITY and escalated as
-- a potential true match.
--
-- A case-level escalation record exists.
--
-- Escalation status: OPEN
-- Decision summary: PENDING COMPLIANCE REVIEW
--
-- Business Insight:
-- A potential sanctions identity match
-- has been identified, and an associated
-- KYC case escalation remains unresolved.
--
-- The precise reason for the case-level
-- escalation should also be verified.
--
-- Recommended Action:
-- Keep the screening finding under review.
-- Verify the escalation reason and monitor
-- the pending compliance decision.
--
-- Do not independently clear the match
-- or close the investigation without
-- the required authorization.


-- TASK 13: INVESTIGATE CONFIRMED PEP MATCHES

SELECT
    r.case_id,
    c.legal_name AS customer_name,
    c.customer_type,
    w.primary_name AS watchlist_name,
    w.country_code,
    w.date_of_birth,
    s.source_name,
    h.match_score,
    h.match_basis,
    h.identity_assessment,
    h.analyst_disposition

FROM screening_hits AS h

INNER JOIN screening_runs AS r
    ON h.screening_run_id = r.screening_run_id

INNER JOIN customers AS c
    ON r.customer_id = c.customer_id

INNER JOIN watchlist_entities AS w
    ON h.watchlist_entity_id = w.watchlist_entity_id

INNER JOIN screening_sources AS s
    ON w.source_id = s.source_id

WHERE w.record_category = 'PEP'
  AND h.identity_assessment = 'CONFIRMED_IDENTITY'

ORDER BY h.match_score DESC;


-- TASK 13: CONFIRMED PEP MATCH ANALYSIS
--
-- Observation:
-- I investigated screening records
-- classified as confirmed PEP identity
-- matches.
--
-- Key Findings:
-- Two customers were identified:
-- Sofia Walker and Iris Marshall.
--
-- Both have a screening match score of 99.
-- Both were assessed as CONFIRMED_IDENTITY.
-- Both were escalated as potential matches.
--
-- Business Insight:
-- These customers require further
-- investigation of their political
-- exposure and relevant risk factors.
--
-- PEP status alone does not establish
-- wrongdoing or a sanctions restriction.
--
-- Recommended Action:
-- Review their KYC case details,
-- political exposure, customer risk
-- assessment and existing escalations
-- before recommending further action.
 

-- TASK 13A: INVESTIGATE PEP CUSTOMER KYC CASES

SELECT
    r.case_id,
    c.legal_name,
    c.customer_type,
    k.review_type,
    k.case_status,
    k.priority,
    k.due_at,
    h.match_score,
    h.identity_assessment,
    h.analyst_disposition

FROM screening_hits AS h

INNER JOIN screening_runs AS r
    ON h.screening_run_id = r.screening_run_id

INNER JOIN customers AS c
    ON r.customer_id = c.customer_id

INNER JOIN kyc_cases AS k
    ON r.case_id = k.case_id

INNER JOIN watchlist_entities AS w
    ON h.watchlist_entity_id = w.watchlist_entity_id

WHERE w.record_category = 'PEP'
  AND h.identity_assessment = 'CONFIRMED_IDENTITY'

ORDER BY c.legal_name;


-- TASK 13A: PEP CUSTOMER KYC CASE ANALYSIS
--
-- Observation:
-- I examined the KYC cases associated
-- with two confirmed PEP identity matches.
--
-- Key Findings:
-- Sofia Walker:
-- Review Type: ONBOARDING
-- Case Status: PENDING_SCREENING
-- Priority: HIGH
--
-- Iris Marshall:
-- Review Type: PERIODIC
-- Case Status: PENDING_SCREENING
-- Priority: HIGH
--
-- Both customers have confirmed PEP
-- identity matches and escalated
-- screening dispositions.
--
-- Business Insight:
-- The customers are undergoing different
-- KYC review processes, but both cases
-- remain pending screening.
--
-- Recommended Action:
-- Verify the existing escalation records,
-- evaluate the political exposure and
-- review relevant customer risk factors.
--
-- Determine whether EDD and additional
-- approvals are required under the
-- applicable KYC procedures.



-- TASK 13B: CHECK PEP CASE ESCALATIONS

SELECT
    k.case_id,
    c.legal_name,
    k.review_type,
    k.case_status,
    e.*

FROM kyc_cases AS k

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

LEFT JOIN escalations AS e
    ON k.case_id = e.case_id

WHERE k.case_id IN ('KYC000003', 'KYC001205')

ORDER BY c.legal_name;


-- TASK 13B: PEP ESCALATION VERIFICATION
--
-- Observation:
-- I checked existing escalation records
-- for Sofia Walker and Iris Marshall.
--
-- Key Findings:
-- Both customers have case-level
-- escalation records.
--
-- Both escalation statuses are OPEN.
-- Both decision summaries indicate
-- PENDING COMPLIANCE REVIEW.
--
-- Business Insight:
-- The customers have confirmed PEP
-- screening identity matches, and their
-- KYC cases remain under review.
--
-- No final compliance decisions have
-- been recorded in the escalation results.
--
-- Recommended Action:
-- Verify the reasons for both escalations.
-- Review political exposure and available
-- risk assessment information.
--
-- Confirm whether EDD and additional
-- approvals are required under policy.



-- TASK 13C: IDENTIFY PEP AND RISK TABLES

-- Find tables related to PEP information
SHOW TABLES LIKE '%pep%';

-- Find tables related to customer risk
SHOW TABLES LIKE '%risk%';



-- EXAMINE SAMPLE PEP AND RISK RECORDS

SELECT *
FROM pep_profiles
LIMIT 5;

SELECT *
FROM case_risk_factors
LIMIT 5;

SELECT *
FROM customer_risk_assessments
LIMIT 5;



-- TASK 13D: PEP AND CUSTOMER RISK DATA
--
-- Observation:
-- I explored the PEP profiles, case risk
-- factors and customer risk assessments.
--
-- Key Findings:
-- PEP profiles: 290 records
-- Case risk factors: 8,150 records
-- Customer risk assessments: 1,630 records
--
-- The PEP table records political positions,
-- exposure categories and relevant dates.
--
-- The risk tables record weighted risk
-- factors, scores, ratings and EDD flags.
--
-- Sofia Walker's onboarding case has
-- a HIGH risk rating and EDD_REQUIRED = YES.
-- However, her assessment remains DRAFT.
--
-- A possible inconsistency was also found
-- in her PEP category and status fields.
--
-- Next Action:
-- Compare the PEP profiles and recorded
-- risk assessments for Sofia and Iris.



-- TASK 13E: PEP EXPOSURE AND RISK ASSESSMENT

SELECT
    c.legal_name,
    k.case_id,
    k.review_type,
    p.pep_category,
    p.public_position,
    p.public_body,
    p.country_code,
    p.pep_status,
    p.term_start,
    p.term_end,
    a.assessment_score,
    a.risk_rating,
    a.edd_required,
    a.assessment_status

FROM screening_hits AS h

INNER JOIN screening_runs AS r
    ON h.screening_run_id = r.screening_run_id

INNER JOIN kyc_cases AS k
    ON r.case_id = k.case_id

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

INNER JOIN watchlist_entities AS w
    ON h.watchlist_entity_id = w.watchlist_entity_id

INNER JOIN pep_profiles AS p
    ON w.watchlist_entity_id = p.watchlist_entity_id

LEFT JOIN customer_risk_assessments AS a
    ON k.case_id = a.case_id

WHERE k.case_id IN ('KYC000003', 'KYC001205')
  AND w.record_category = 'PEP'
  AND h.identity_assessment = 'CONFIRMED_IDENTITY'

ORDER BY c.legal_name;



-- TASK 13E: PEP EXPOSURE AND RISK ASSESSMENT
--
-- Observation:
-- I investigated the PEP profiles and
-- risk assessments of Sofia Walker
-- and Iris Marshall.
--
-- Key Findings:
-- Sofia Walker:
-- PEP Category: FORMER_PEP
-- Public Position: Senior Public Official
--
-- Iris Marshall:
-- PEP Category: FOREIGN
-- Public Position: Minister
--
-- Both have PEP_STATUS = CURRENT.
-- Both are rated HIGH risk.
-- Both require EDD.
-- Both assessments remain DRAFT.
-- Both have open compliance escalations.
--
-- Business Insight:
-- The recorded assessments indicate
-- additional due diligence is required.
--
-- Sofia's FORMER_PEP category and CURRENT
-- status require clarification.
--
-- Recommended Action:
-- Verify the nature of political exposure,
-- review EDD evidence and applicable
-- approval requirements.
--
-- Refer unresolved classification issues
-- to the responsible compliance team.
--
-- Do not treat DRAFT assessments as
-- finalized or approved.



-- TASK 14: IDENTIFY ADVERSE MEDIA TABLES

SHOW TABLES LIKE '%adverse%';

SHOW TABLES LIKE '%media%';


-- TASK 14A: IDENTIFY ADVERSE MEDIA TABLE COLUMNS

SELECT
    table_name,
    GROUP_CONCAT(
        column_name
        ORDER BY ordinal_position
        SEPARATOR ', '
    ) AS available_columns

FROM information_schema.columns

WHERE table_schema = DATABASE()
  AND (
      table_name LIKE '%adverse%'
      OR table_name LIKE '%media%'
  )

GROUP BY table_name
ORDER BY table_name;



-- TASK 14B: INVESTIGATE ADVERSE MEDIA ALERTS

SELECT
    a.media_alert_id,
    k.case_id,
    c.legal_name,
    k.review_type,
    a.screened_subject_type,
    a.screened_subject_id,
    ar.headline,
    ar.event_category,
    ar.event_stage,
    ar.credibility_tier,
    a.match_assessment,
    a.relevance,
    a.source_reliability,
    a.investigation_status,
    a.assessed_at

FROM adverse_media_alerts AS a

INNER JOIN kyc_cases AS k
    ON a.case_id = k.case_id

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

INNER JOIN adverse_media_articles AS ar
    ON a.article_id = ar.article_id

ORDER BY a.assessed_at DESC, a.media_alert_id

LIMIT 20;



-- TASK 14B: ADVERSE MEDIA ALERT ANALYSIS
--
-- Observation:
-- I analyzed adverse media alerts linked
-- to KYC customers and their review cases.
--
-- Key Findings:
-- The records include alleged fraud,
-- money laundering, terrorist financing,
-- bribery and other financial crime issues.
--
-- Different event stages were identified,
-- including ALLEGATION, INVESTIGATION,
-- CHARGES_FILED, CONVICTION and DISMISSED.
--
-- The articles also have different
-- recorded credibility levels.
--
-- Business Insight:
-- Adverse media findings must be assessed
-- based on identity, relevance, reliability
-- and the actual stage of the reported event.
--
-- Next Action:
-- Investigate Iris Marshall's adverse
-- media alert and review its supporting
-- article and analyst assessment.



-- TASK 14C: INVESTIGATE IRIS MARSHALL
-- ADVERSE MEDIA ALERT

SELECT
    c.legal_name,
    a.media_alert_id,
    ar.headline,
    ar.article_summary,
    ar.fictional_publisher,
    ar.published_at,
    ar.event_category,
    ar.event_stage,
    ar.credibility_tier,
    a.match_assessment,
    a.relevance,
    a.source_reliability,
    a.investigation_status,
    a.investigation_note,
    a.assessed_at

FROM adverse_media_alerts AS a

INNER JOIN kyc_cases AS k
    ON a.case_id = k.case_id

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

INNER JOIN adverse_media_articles AS ar
    ON a.article_id = ar.article_id

WHERE a.media_alert_id = 'AMA000150';



-- TASK 14C: IRIS MARSHALL ADVERSE MEDIA REVIEW
--
-- Observation:
-- I investigated adverse media alert
-- AMA000150 for Iris Marshall.
--
-- Key Findings:
-- Event Category: MONEY_LAUNDERING
-- Event Stage: DISMISSED
-- Relevance: LOW
-- Source Reliability: MEDIUM
-- Investigation Status: CLEARED
--
-- The article is entirely fictional and
-- does not assert any real-world allegation.
--
-- The investigation note confirms that
-- the fictional article and identity
-- information were reviewed.
--
-- Business Insight:
-- The recorded evidence supports the
-- existing adverse media clearance.
--
-- However, Iris Marshall's separate
-- PEP-related compliance review remains OPEN.
--
-- Recommended Action:
-- Retain the adverse media findings and
-- clearance rationale in the case record.
--
-- Continue monitoring the outstanding
-- PEP compliance review separately.
--
-- Do not treat adverse media clearance
-- as approval of the entire KYC case.



-- TASK 15A: IDENTIFY CORPORATE OWNERSHIP TABLES

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND (
      table_name LIKE '%owner%'
      OR table_name LIKE '%ubo%'
      OR table_name LIKE '%party%'
      OR table_name LIKE '%entity%'
  )
ORDER BY table_name;


-- TASK 15B: EXPLORE CORPORATE OWNERSHIP

-- Check the available columns
DESCRIBE corporate_ownership;

-- Examine five ownership records
SELECT *
FROM corporate_ownership
LIMIT 5;


-- TASK 15B: CORPORATE OWNERSHIP EXPLORATION
--
-- Observation:
-- I examined the corporate_ownership table.
--
-- Key Findings:
-- Total ownership records: 1,380
--
-- The dataset contains direct ownership
-- links and ownership through other parties.
--
-- Customer CUS00004 has three recorded
-- direct ownership relationships:
-- PTY00001: 55% (PENDING verification)
-- PTY00004: 30% (VERIFIED)
-- PTY00005: 15% (VERIFIED)
--
-- PTY00001 has two further owners:
-- PTY00002: 65%
-- PTY00003: 35%
--
-- Business Insight:
-- The ownership structure requires
-- indirect ownership analysis.
--
-- Recommended Action:
-- Calculate indirect ownership, verify
-- party identities and investigate
-- pending ownership verification.



-- TASK 15C: DIRECT AND INDIRECT OWNERSHIP

SELECT
    c.legal_name,
    c.customer_type,
    d.owner_party_id AS direct_owner_id,
    d.share_pct AS direct_share_pct,
    d.verification_status,
    i.owner_party_id AS indirect_owner_id,
    i.share_pct AS second_level_share_pct,

    ROUND(
        d.share_pct * i.share_pct / 100,
        2
    ) AS effective_indirect_share_pct

FROM corporate_ownership AS d

INNER JOIN customers AS c
    ON d.owned_entity_type = 'CUSTOMER'
   AND d.owned_entity_id = c.customer_id

LEFT JOIN corporate_ownership AS i
    ON i.owned_entity_type = 'PARTY'
   AND i.owned_entity_id = d.owner_party_id

WHERE c.customer_id = 'CUS00004'

ORDER BY
    d.share_pct DESC,
    i.share_pct DESC;



-- TASK 15C: DIRECT AND INDIRECT OWNERSHIP
--
-- Observation:
-- I analyzed the ownership structure
-- of corporate customer Northgate Imports.
--
-- Key Findings:
-- PTY00001 directly owns 55%.
-- PTY00004 directly owns 30%.
-- PTY00005 directly owns 15%.
--
-- PTY00001 has two further owners:
-- PTY00002 owns 65% of PTY00001.
-- PTY00003 owns 35% of PTY00001.
--
-- Effective indirect ownership:
-- PTY00002: 35.75%
-- PTY00003: 19.25%
--
-- Business Insight:
-- The company has a multi-level ownership
-- structure requiring UBO identification.
--
-- The 55% direct ownership relationship
-- is still marked PENDING verification.
--
-- Recommended Action:
-- Identify whether the ultimate parties
-- are individuals or legal entities.
--
-- Verify the pending ownership evidence
-- and review relevant control information
-- before concluding UBO identification.



-- TASK 15D: FIND PARTY MASTER TABLES

SHOW TABLES LIKE '%part%';


-- TASK 15E: IDENTIFY BENEFICIAL OWNERS

-- Step 1: Understand the party master table
DESCRIBE related_parties;

-- Step 2: Examine sample records
SELECT *
FROM related_parties
LIMIT 5;



-- TASK 15E: OWNER IDENTITY VERIFICATION
--
-- Observation:
-- I examined the related_parties table
-- to identify the owners of Northgate Imports.
--
-- Key Findings:
-- Intermediary Capital 1 Ltd is a corporate
-- party holding 55% of Northgate Imports.
--
-- The intermediary has two individual owners:
-- Jonah Carter and Oscar Bennett.
--
-- Their effective indirect ownership is:
-- Jonah Carter: 35.75%
-- Oscar Bennett: 19.25%
--
-- Two individuals directly own Northgate:
-- Priya Mercer: 30%
-- Marcus Bennett: 15%
--
-- Business Insight:
-- Four natural persons were identified
-- within the recorded ownership structure.
--
-- However, the intermediary's 55% stake
-- remains pending verification.
--
-- Recommended Action:
-- Verify the ownership evidence and
-- assess relevant ownership thresholds,
-- voting rights and other control factors
-- before finalizing UBO identification.



-- TASK 15F: FINAL CORPORATE OWNERSHIP REPORT

SELECT
    c.legal_name AS customer_name,

    p1.legal_name AS direct_owner,
    p1.party_type AS direct_owner_type,
    d.share_pct AS direct_share_pct,

    COALESCE(
        p2.legal_name,
        p1.legal_name
    ) AS identified_owner,

    COALESCE(
        p2.party_type,
        p1.party_type
    ) AS identified_owner_type,

    CASE
        WHEN i.owner_party_id IS NULL
            THEN d.share_pct
        ELSE ROUND(
            d.share_pct * i.share_pct / 100, 2
        )
    END AS effective_ownership_pct,

    d.verification_status AS direct_link_status,
    i.verification_status AS second_level_status

FROM corporate_ownership AS d

INNER JOIN customers AS c
    ON d.owned_entity_type = 'CUSTOMER'
   AND d.owned_entity_id = c.customer_id

LEFT JOIN related_parties AS p1
    ON d.owner_party_id = p1.party_id

LEFT JOIN corporate_ownership AS i
    ON i.owned_entity_type = 'PARTY'
   AND i.owned_entity_id = d.owner_party_id

LEFT JOIN related_parties AS p2
    ON i.owner_party_id = p2.party_id

WHERE c.customer_id = 'CUS00004'

ORDER BY effective_ownership_pct DESC;



-- TASK 15F: FINAL CORPORATE OWNERSHIP REVIEW
--
-- Observation:
-- I investigated the direct and indirect
-- ownership of Northgate Imports.
--
-- Key Findings:
-- Jonah Carter: 35.75% indirect ownership
-- Priya Mercer: 30.00% direct ownership
-- Oscar Bennett: 19.25% indirect ownership
-- Marcus Bennett: 15.00% direct ownership
--
-- Total recorded ownership: 100%.
--
-- Two indirect ownership paths involve
-- a 55% intermediary ownership link
-- marked PENDING verification.
--
-- Business Insight:
-- Four natural persons were identified,
-- but the complete ownership structure
-- is not yet fully verified.
--
-- Recommended Action:
-- Obtain and verify the outstanding
-- intermediary ownership evidence.
--
-- Assess beneficial ownership thresholds,
-- voting rights and other control factors
-- before finalizing the UBO determination.



-- TASK 16A: ANALYZE CUSTOMER RISK FACTORS

SELECT
    c.legal_name,
    k.case_id,
    f.factor_name,
    f.factor_value,
    f.weight,
    f.weighted_value,
    a.assessment_score,
    a.risk_rating,
    a.edd_required,
    a.assessment_status

FROM case_risk_factors AS f

INNER JOIN kyc_cases AS k
    ON f.case_id = k.case_id

INNER JOIN customers AS c
    ON k.customer_id = c.customer_id

INNER JOIN customer_risk_assessments AS a
    ON k.case_id = a.case_id

WHERE k.case_id = 'KYC000003'

ORDER BY f.weighted_value DESC;



-- TASK 16A: CUSTOMER RISK FACTOR ANALYSIS
--
-- Observation:
-- I investigated the five risk factors
-- contributing to Sofia Walker's
-- customer risk assessment.
--
-- Key Findings:
-- SCREENING_EXPOSURE: 1.2500
-- EXPECTED_ACTIVITY: 0.8020
-- CUSTOMER_PROFILE: 0.7520
-- PRODUCT_CHANNEL: 0.6585
-- GEOGRAPHIC: 0.2000
--
-- Total weighted risk score: 3.6625
--
-- Screening exposure was the largest
-- contributor to the overall risk score.
--
-- The recorded risk rating is HIGH,
-- and EDD_REQUIRED is YES.
--
-- The assessment remains in DRAFT status.
--
-- Business Insight:
-- The five weighted values reconcile
-- with the recorded assessment score.
--
-- Recommended Action:
-- Review supporting evidence for the
-- risk factors and complete the required
-- due diligence before final approval.



-- TASK 16B: VALIDATE CUSTOMER RISK SCORES

SELECT
    a.case_id,
    a.assessment_score,
    ROUND(SUM(f.weighted_value), 4)
        AS calculated_score,

    ROUND(
        a.assessment_score - SUM(f.weighted_value),
        4
    ) AS score_difference,

    ROUND(SUM(f.weight), 4)
        AS total_weight

FROM customer_risk_assessments AS a

INNER JOIN case_risk_factors AS f
    ON a.case_id = f.case_id

GROUP BY
    a.case_id,
    a.assessment_score

HAVING ABS(score_difference) > 0.0001
    OR ABS(total_weight - 1) > 0.0001;



-- TASK 16B: CUSTOMER RISK SCORE VALIDATION
--
-- Observation:
-- I audited the calculated risk scores
-- against the recorded assessment scores.
--
-- Key Findings:
-- Zero calculation discrepancies found
-- among assessments with matching
-- risk-factor records.
--
-- The total factor weights also matched
-- the expected value of 1.0000.
--
-- Business Insight:
-- The results support the consistency
-- of the recorded risk-scoring calculations.
--
-- However, missing factor records were
-- not tested by this query.
--
-- Recommended Action:
-- Include missing-record checks in the
-- final data quality audit.



-- TASK 17A: IDENTIFY QC AND APPROVAL TABLES

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND (
      table_name LIKE '%qc%'
      OR table_name LIKE '%quality%'
      OR table_name LIKE '%approval%'
      OR table_name LIKE '%escalation%'
  )
ORDER BY table_name;



-- TASK 17B: UNDERSTAND QC, APPROVAL
-- AND ESCALATION TABLE STRUCTURES

SELECT
    table_name,
    GROUP_CONCAT(
        column_name
        ORDER BY ordinal_position
        SEPARATOR ', '
    ) AS available_columns

FROM information_schema.columns

WHERE table_schema = DATABASE()
  AND table_name IN (
      'qc_reviews',
      'case_approvals',
      'escalations'
  )

GROUP BY table_name
ORDER BY table_name;



-- TASK 17C: AUDIT COMPLETED KYC CASES

SELECT
    COUNT(DISTINCT k.case_id) AS total_completed_cases,

    COUNT(DISTINCT q.case_id) AS cases_with_qc,

    COUNT(DISTINCT a.case_id) AS cases_with_approval_record,

    COUNT(DISTINCT e.case_id) AS cases_with_escalation

FROM kyc_cases AS k

LEFT JOIN qc_reviews AS q
    ON k.case_id = q.case_id

LEFT JOIN case_approvals AS a
    ON k.case_id = a.case_id

LEFT JOIN escalations AS e
    ON k.case_id = e.case_id

WHERE k.case_status = 'COMPLETED';


-- TASK 17C: COMPLETED KYC CASE AUDIT
--
-- Observation:
-- I checked completed KYC cases to
-- identify their QC, approval and
-- escalation record coverage.
--
-- Key Findings:
-- Total completed cases: 1,259
-- Cases with QC records: 1,259
-- Cases with approval records: 1,259
-- Cases with escalation records: 0
--
-- Business Insight:
-- All completed cases have recorded
-- QC and approval activities.
--
-- However, record presence alone
-- does not confirm successful QC
-- or an approved decision.
--
-- Recommended Action:
-- Verify the actual QC outcomes
-- and approval decisions before
-- confirming workflow consistency.



-- TASK 17D: CHECK COMPLETED CASE DECISIONS

-- Step 1: QC outcomes
SELECT
    q.qc_outcome,
    COUNT(DISTINCT k.case_id) AS total_cases

FROM kyc_cases AS k

INNER JOIN qc_reviews AS q
    ON k.case_id = q.case_id

WHERE k.case_status = 'COMPLETED'

GROUP BY q.qc_outcome
ORDER BY total_cases DESC;


-- Step 2: Approval decisions
SELECT
    a.approval_decision,
    COUNT(DISTINCT k.case_id) AS total_cases

FROM kyc_cases AS k

INNER JOIN case_approvals AS a
    ON k.case_id = a.case_id

WHERE k.case_status = 'COMPLETED'

GROUP BY a.approval_decision
ORDER BY total_cases DESC;



-- TASK 17D: QC AND APPROVAL VALIDATION
--
-- Observation:
-- I examined QC outcomes and approval
-- decisions for completed KYC cases.
--
-- Key Findings:
-- Total completed cases: 1,259
-- Cases with PASS QC outcome: 1,259
-- Cases with APPROVED decision: 1,259
--
-- Business Insight:
-- All completed cases have recorded
-- passing QC and approved decisions.
--
-- This indicates consistency between
-- case completion and recorded outcomes.
--
-- However, approval timing, authorization
-- and supporting evidence were not
-- independently verified.
--
-- Recommended Action:
-- Include workflow consistency checks
-- in the final data quality audit.



-- TASK 18A: FINAL KYC DATA QUALITY AUDIT

-- Check 1: KYC cases without risk assessments
SELECT
    'Cases missing risk assessments' AS check_name,
    COUNT(*) AS issue_count
FROM kyc_cases AS k
LEFT JOIN customer_risk_assessments AS a
    ON k.case_id = a.case_id
WHERE a.case_id IS NULL

UNION ALL

-- Check 2: Assessments without risk factors
SELECT
    'Assessments missing risk factors',
    COUNT(*)
FROM customer_risk_assessments AS a
LEFT JOIN case_risk_factors AS f
    ON a.case_id = f.case_id
WHERE f.case_id IS NULL

UNION ALL

-- Check 3: Completed cases without passing QC
SELECT
    'Completed cases without QC PASS',
    COUNT(*)
FROM kyc_cases AS k
WHERE k.case_status = 'COMPLETED'
  AND NOT EXISTS (
      SELECT 1
      FROM qc_reviews AS q
      WHERE q.case_id = k.case_id
        AND q.qc_outcome = 'PASS'
  )

UNION ALL

-- Check 4: Completed cases without approval
SELECT
    'Completed cases without APPROVED decision',
    COUNT(*)
FROM kyc_cases AS k
WHERE k.case_status = 'COMPLETED'
  AND NOT EXISTS (
      SELECT 1
      FROM case_approvals AS a
      WHERE a.case_id = k.case_id
        AND a.approval_decision = 'APPROVED'
  );



-- TASK 18A: FINAL SQL DATA QUALITY AUDIT
--
-- Observation:
-- I performed four final validation
-- checks on the KYC database.
--
-- Key Findings:
-- Missing risk assessments: 0
-- Missing risk factor records: 0
-- Completed cases without QC PASS: 0
-- Completed cases without APPROVAL: 0
--
-- Business Insight:
-- All four targeted validation checks
-- passed with zero detected issues.
--
-- The database is ready for the planned
-- Python-based analysis and application
-- development.
--
-- Note:
-- Earlier identified exceptions, such as
-- questionable UBO document requests,
-- remain documented for further review.


USE clearcase_kyc;

SHOW CREATE TABLE information_requests;


USE clearcase_kyc;

-- Create one training request if it does not already exist.
-- This request is only for testing the Streamlit workflow.


INSERT INTO clearcase_kyc.information_requests
(request_id, case_id, relationship_manager_id, requested_item,
 requested_at, due_at, responded_at, request_status,
 request_detail, closure_note)
VALUES
('REQ_TEST_KYC001203_01', 'KYC001203', 'USR020',
 'TEST_REFRESH_IDENTITY', CURDATE(),
 DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL, 'OPEN',
 'TRAINING TEST ONLY: Simulated identity document request.', NULL)
ON DUPLICATE KEY UPDATE request_id = request_id;


SELECT
    request_id,
    case_id,
    requested_item,
    request_status,
    requested_at,
    due_at,
    closure_note
FROM information_requests
WHERE request_id = 'REQ_TEST_KYC001203_01';

SELECT
    request_id,
    request_status,
    closure_note
FROM clearcase_kyc.information_requests
WHERE request_id IN (
    'REQ_TEST_KYC001203_01',
    'REQ000072'
);




