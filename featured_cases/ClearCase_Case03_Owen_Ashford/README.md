# ClearCase KYC — Featured Investigation 03
## Exact-identifier sanctions screening candidate: Owen Ashford

**Project context:** Fictional training data, local MySQL KYC operations simulation. This is **not** a real sanctions listing, a real bank customer, Citi's scoring methodology or evidence that any actual legal restriction applies.

**Case status:** Draft for portfolio publication. Values below were verified against the supplied `ClearCase_KYC_Citi_Analyst_Project_Complete_Datasets.zip` source snapshot. Re-run `evidence_queries.sql` against your current local MySQL database before publication, because Streamlit training writes may add records.

### Case at a glance

| Item | Source-snapshot finding |
|---|---|
| Customer and case | Owen Ashford (`CUS00001`); `KYC000001` |
| Customer type, country | INDIVIDUAL; `GB` residence/nationality codes |
| Occupation and product | Accountant; Cross-border Payments |
| Customer status | `PROSPECT` |
| Review and trigger | `ONBOARDING` / `NEW_TO_BANK` |
| KYC case status, priority | `ESCALATED` / `HIGH` |
| Opened / due | 2026-10-05 / 2026-10-19 |
| Assigned KYC analyst | `USR003` |
| Screening run | `RUN0000001`, 2026-10-06, `COMPLETED`; one potential hit |
| Screening hit | `HIT0000001`; score 99; `EXACT_NAME_AND_IDENTIFIERS` |
| Identity assessment | `CONFIRMED_IDENTITY` |
| Hit disposition | `ESCALATED_POTENTIAL_TRUE_MATCH` (reviewed 2026-10-08) |
| Watchlist entity | `WL00001`; category `SANCTIONS`; record `ACTIVE` |
| Reference source | `SRC03`, **Training US Restriction Reference**, synthetic |
| Designation record | `SAN00001`, `ACTIVE`, simulated `TRANSACTION_RESTRICTION` |
| Escalation | `ESC000001`, `SANCTIONS_MATCH`, `OPEN`, assigned `USR027` |
| Risk assessment | `RA000001`, score `3.296`, `MEDIUM`, EDD `NO`, `DRAFT` |
| Documents | ID proof and address proof both `MISSING` / `NOT_RECEIVED` |
| QC / approval | No QC or case-approval rows in source snapshot |

### Central investigation question

**What should an onboarding analyst do when exact identifiers match a synthetic sanctions reference, but the weighted CRA score is merely MEDIUM and identity documents are still missing?**

**Recommended handling:** Do **not** advance or approve the onboarding case; maintain the case in the relevant hold/escalation process under the simulated policy. Escalate to the authorized sanctions/compliance team with traceable identifiers, source metadata, designation details, missing-document gaps and a clear audit trail. The analyst cannot resolve the sanctions restriction based on the risk average, independently clear this high-concern hit or assert which real-world law applies to a fictional training reference.

### Evidence chain

1. **Profile:** Owen is an individual GB prospect requesting a cross-border-payments product. The declared occupation is accountant; expected activity is USD 20,648/month and 24 transactions/month. Recorded source of funds is investment returns; source of wealth is inheritance. These are *declarations*, not independently verified funding documentation.
2. **Identity-document gap:** `DOC0000001` ID proof and `DOC0000002` address proof are `MISSING` with `NOT_RECEIVED`. The stored identity comparison must not be represented as documentary verification of those missing files.
3. **Screening:** `RUN0000001` is technically completed with a single potential hit. `HIT0000001` records a score of 99, exact name/identifier match, identity assessment `CONFIRMED_IDENTITY`, and `ESCALATED_POTENTIAL_TRUE_MATCH` disposition.
4. **Matched reference:** `WL00001` is an ACTIVE synthetic sanctions-category entity. The linked fictional `SAN00001` designation is ACTIVE, with simulated restriction type `TRANSACTION_RESTRICTION` under training program `TRAINING-EXPORT-RESTRICTIONS`.
5. **Compliance handoff:** `ESC000001` is `OPEN`, with decision summary `Pending compliance review`. The specialist reviewer remains responsible for an authorized final decision.
6. **Risk model:** The illustrative CRA gives MEDIUM (3.296) and EDD NO, DRAFT; this cannot neutralize the screening concern or authorize onboarding.
7. **Controls:** KYC identity, document verification, sanctions/PEP screening, risk assessment and QC approval checklist steps are OPEN. An `EDD_REVIEW` checklist step is COMPLETE despite the assessment field `edd_required=NO`; reconcile the semantic/policy meaning instead of inventing an answer.

### Illustrated five-factor score

| Factor | Factor value | Weight | Weighted contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 3.61 | 0.20 | 0.7220 |
| GEOGRAPHIC | 1.00 | 0.20 | 0.2000 |
| PRODUCT_CHANNEL | 3.40 | 0.15 | 0.5100 |
| EXPECTED_ACTIVITY | 3.07 | 0.20 | 0.6140 |
| SCREENING_EXPOSURE | 5.00 | 0.25 | 1.2500 |
| **Total** | | **1.00** | **3.2960** |

**Key lesson:** A MEDIUM composite rating does **not** override a mandatory screening investigation. Factor weights are illustrative and do not belong to Citi or a regulator. The case's operational priority (`HIGH`) is a separate field from the customer's model risk rating (`MEDIUM`).

### Data quality and case-control observations

- **DQ-01 — Missing KYC evidence:** Identity and address proof are missing; do not imply the match against watchlist identifiers substitutes for required customer documents.
- **DQ-02 — Risk/EDD control mismatch:** Risk assessment `edd_required=NO` and `risk_rating=MEDIUM`, yet an `EDD_REVIEW` checklist step is COMPLETE while screening and approval remain OPEN. Verify how this training dataset defines these statuses, plus any workflow rule requiring enhanced review of a sanctions candidate.
- **DQ-03 — Reference-version mismatch:** Screening run/source snapshot was 2026-10-06. Stored watchlist/source last-updated or source snapshot dates are 2026-10-31. The current fictional reference row cannot prove what appeared on the earlier screening date. In a real system, inspect the actual versioned screening snapshot and refresh screening as appropriate.
- **DQ-04 — Source-authority limitation:** `Training US Restriction Reference` and `TRAINING-EXPORT-RESTRICTIONS` are synthetic labels, **not** official US sanctions lists or proof of specific legal obligations. Do not represent this case as an OFAC finding or a real prohibition.
- **DQ-05 — Reference-ID discrepancy:** The primary CSV lists `WL00001` (five digits after WL), while an older handwritten SQL note mentions `WL000001` (six digits). The case package uses the **actual CSV/watchlist foreign key** `WL00001`. Verify the current MySQL value in Query 3 before relying on either spelling.

### Recommended analyst workflow

1. Confirm the identity evidence and potential hit from original customer records and the exact, date-controlled screening reference; collect missing CIP/KYC documents under the applicable process.
2. Record the designation program, restriction type, reference provenance and jurisdictions potentially relevant to the relationship; do **not** assume US rules govern simply because a synthetic source name says “US”.
3. Maintain the required hold/escalation restrictions while the authorized sanctions reviewer establishes disposition and permitted business actions.
4. Route to compliance (`ESC000001`), documenting reason, matched identifiers, reference date, restrictions and missing documents; do not independently clear, approve or report a real-world violation.
5. Review and reconcile the CRA/EDD/checklist contradictions. Obtain the required documented decision, QC and approvals before any case closure/onboarding outcome.
6. Preserve notes, audit events, accurate timestamps and the fact that every watchlist source here is synthetic.

### Streamlit demonstration

**Customer Search** → enter `CUS00001` → choose `KYC000001` → **Case Investigation** → open **Screening**, **Documents**, **Risk Assessment**, **Notes & Audit**. Open **Approvals & QC → Escalations** to inspect `ESC000001` and **Audit Trail** for the history.

Do not use the training request-closure controls to alter a real case escalation. The app is a portfolio simulator, not an authenticated banking system.

### Folder contents

- `README.md` — business scenario, evidence, caveats and workflow
- `analyst_note.md` — structured investigation and copy-ready summary
- `evidence_queries.sql` — independent read-only MySQL checks; comments below each query explain why it matters
- `interview_prep.md` — 60-second narrative and interview-style cross-questions

**Evidence origins:** `ClearCase_KYC_Citi_Analyst_Project_Complete_Datasets.zip`, plus earlier `Kyc_operations_analysis.sql` Tasks 12F–12I. This package is a re-examination of the synthetic source; any MySQL edits after import require revalidation.
