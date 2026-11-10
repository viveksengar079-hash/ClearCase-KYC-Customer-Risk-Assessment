# ClearCase KYC — Featured Investigation 01
## Expired identity proof during a periodic KYC review

**Portfolio classification:** Synthetic-data AML/KYC investigation exercise — not a real bank customer investigation.

### Case at a glance

| Attribute | Verified source finding |
|---|---|
| Customer | Alice Bennett |
| Customer ID | `CUS00006` |
| Case ID | `KYC001203` |
| Customer type | `INDIVIDUAL` |
| Review type | `PERIODIC` |
| Case priority | `HIGH` |
| Case status | `PENDING_INFORMATION` |
| Case due date | `2026-10-29` |
| Assigned relationship manager | `USR020` |
| Outstanding original request | `REQ000072` (`REFRESH_IDENTITY`), `OPEN` |

**Issue:** The identity-proof document (`DOC0003241`) was recorded as `EXPIRED`, with `EXPIRED_AT_REVIEW` as its exception code. Its recorded expiry date was **2026-10-03**, and the receipt date was **2026-10-09**. The address-proof and source-of-funds records were marked `VERIFIED`. An information request for refreshed identity evidence was raised on **2026-10-10** with a due date of **2026-10-17**.

### Investigation question

Can the periodic KYC review be completed while the customer's identity proof is expired and the original request for renewed evidence remains open?

**Analyst determination:** Not on the evidence currently recorded. Keep the case in `PENDING_INFORMATION`; follow up for a valid identity document, verify it under applicable policy, document the outcome, and only then consider progressing through the institution's review and approval controls. A status change is not justified merely by closing a separate training request.

### Core evidence and follow-up

1. Validate the customer and case identifiers, current state and assigned RM.
2. Inspect the stored document metadata: identity-proof `EXPIRED`, address proof `VERIFIED`, source-of-funds evidence `VERIFIED`.
3. Review original information request `REQ000072`, which remains `OPEN`; note its October 17 due date.
4. Confirm case status remains `PENDING_INFORMATION` and check relevant risk assessment, screening and escalation records before any final recommendation.
5. Request replacement identity proof through the appropriate relationship-manager workflow. Review and verify the new evidence before recommending resolution.
6. Record factual findings and follow-up actions in case notes; retain audit records. Escalate overdue or unresolved issues under the actual institution's procedures, rather than assuming an automatic regulatory filing.

**As-of illustration:** On **2026-11-10**, if unchanged, the request due date is **24 calendar days** earlier and the case due date **12 calendar days** earlier. These calendar calculations do *not* on their own establish a contractual SLA violation.

### A key distinction: priority is not risk rating

This case has `HIGH` **worklist priority**. Do **not** state that Alice has a `HIGH` *customer risk rating* or requires EDD unless the actual recorded risk-assessment data proves that separately.

### Training-data integrity

A separate request, `REQ_TEST_KYC001203_01`, was created strictly to test Streamlit updates. It was marked `CLOSED` with a training closure note and an audit event dated November 10, 2026. **That test action is not proof that Alice provided a new identity document**. The original `REQ000072` remained `OPEN` when verified.

### Included artifacts

- [`analyst_note.md`](analyst_note.md) — structured case finding, disposition and next action
- [`evidence_queries.sql`](evidence_queries.sql) — read-only SQL checks for known table names
- [`interview_prep.md`](interview_prep.md) — defensible case narrative and cross-questions

### How to demonstrate in Streamlit

1. Customer Search → `CUS00006` → select `KYC001203`.
2. Case Investigation → Documents: observe recorded expiry exception.
3. Information Requests: distinguish the real `REQ000072` (`OPEN`) from the `REQ_TEST_...` (`CLOSED`) training row.
4. Review Screening and Risk Assessment tabs **without inferring results that have not been checked**.
5. Notes & Audit: show investigation documentation and the training update audit trail.
6. Case Management: show `PENDING_INFORMATION` and high priority.

### Important limitations

This case uses synthetic operational records, not a customer's actual identity document or authenticated screening-provider reports. Recorded `VERIFIED` statuses are the data's entries, not independent physical document verification by the portfolio author. No new risk rating, sanctions disposition, SAR/STR determination or final approval is inferred beyond the dataset.
