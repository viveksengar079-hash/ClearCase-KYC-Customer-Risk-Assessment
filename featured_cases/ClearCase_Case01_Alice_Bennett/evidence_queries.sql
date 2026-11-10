-- CLEARCASE KYC | CASE 01 - ALICE BENNETT
-- Read-only evidence checks for the local clearcase_kyc MySQL database.
-- No INSERT, UPDATE or DELETE statements are included.
-- Run the whole statement including its terminating semicolon.

USE clearcase_kyc;

-- 1) Verify customer/case linkage, review type, priority, state and due date.
-- Why: Start every investigation by confirming that the evidence belongs
-- to the correct customer and case, rather than relying on display labels.
SELECT
    c.customer_id,
    c.legal_name,
    c.customer_type,
    k.case_id,
    k.review_type,
    k.case_status,
    k.priority,
    k.due_at
FROM customers AS c
JOIN kyc_cases AS k
    ON c.customer_id = k.customer_id
WHERE c.customer_id = 'CUS00006'
  AND k.case_id = 'KYC001203';

-- 2) Review the original information request and the separate training request.
-- Why: The simulated CLOSED request must never be mistaken for resolution
-- of the real identity refresh request REQ000072.
SELECT
    request_id,
    case_id,
    relationship_manager_id,
    requested_item,
    requested_at,
    due_at,
    responded_at,
    request_status,
    request_detail,
    closure_note
FROM information_requests
WHERE case_id = 'KYC001203'
  AND request_id IN ('REQ000072', 'REQ_TEST_KYC001203_01')
ORDER BY request_id;

-- 3) Calculate calendar days past due as of a fixed review date.
-- Why: Explicit as-of dates are reproducible; calendar days are NOT
-- automatically SLA breaches or business days.
SELECT
    request_id,
    request_status,
    due_at,
    DATEDIFF('2026-11-10', due_at) AS calendar_days_after_due_date
FROM information_requests
WHERE request_id = 'REQ000072';

-- 4) Check current recorded risk-assessment details.
-- Why: HIGH case priority is NOT the same as a HIGH customer risk rating.
-- Do not infer EDD if the recorded assessment does not say so.
SELECT *
FROM customer_risk_assessments
WHERE case_id = 'KYC001203';

-- 5) Check recorded risk factors independently.
SELECT *
FROM case_risk_factors
WHERE case_id = 'KYC001203';

-- 6) Retrieve historical notes and audit history for evidence integrity.
SELECT *
FROM case_notes
WHERE case_id = 'KYC001203';

SELECT *
FROM case_audit_log
WHERE case_id = 'KYC001203';

-- DOCUMENT EVIDENCE
-- The project has a verified helper.get_case_documents(case_id) function.
-- Use Case Investigation > Documents, or inspect that function in helper.py
-- to reuse its ACTUAL table name. The underlying document table name is
-- deliberately not guessed here. Confirm DOC0003241 and the two VERIFIED rows.
