# Case 06 — Daniel Mercer | False-Positive Sanctions Screening

**Portfolio:** ClearCase KYC Customer Risk Assessment & Investigation System  
**Case:** `KYC000002` | **Customer:** `CUS00002` | **Scenario:** `SC02`  
**Customer:** Daniel Mercer (fictional individual) | **Review:** ONBOARDING (NEW_TO_BANK)  
**Current case state in original dataset:** `IN_REVIEW` | **Priority:** HIGH  
**Training level:** L1 KYC / sanctions screening analyst  
**Status of this case study:** Source-snapshot evidence verified; **recheck local MySQL results before GitHub publication**.

> **Simulation only.** Customers, sanctions records, sources, and decisions are fictional. This is not a real sanctions-screening system, an official government sanctions list, or any bank's internal procedure. Your local MySQL database might have later training edits.

## 1. The business problem

A new-to-bank individual named **Daniel Mercer** was screened against fictional sanctions, PEP and financial-crime reference data. The system generated **one potential sanctions hit** with a match score of **91** because the names matched exactly. The matched watchlist entity also has the same recorded country (`GB`), but the dates of birth differ. A high matching score is a similarity indicator, **not** a 91% likelihood that the person is sanctioned.

An L1 analyst must verify the identity evidence, document why the records do or do not describe the same person, and follow the allowed screening-disposition workflow. This is different from approving the customer for onboarding.

## 2. Actual source-record facts (original CSV snapshot)

| Item | Verified value | Source table |
|---|---|---|
| Customer ID / name | `CUS00002` — Daniel Mercer | `customers` |
| Individual DOB / country | **1967-08-22** / `GB` | `customers` |
| Customer lifecycle status | `PROSPECT` | `customers` |
| Case ID / scenario | `KYC000002` / `SC02` | `kyc_cases` |
| Case review / status | `ONBOARDING` / `IN_REVIEW` | `kyc_cases` |
| Case priority / due date | `HIGH` / `2026-10-23` | `kyc_cases` |
| Screening run | `RUN0000002`; `COMPLETED`; **1** potential hit | `screening_runs` |
| Screening hit | `HIT0000002` | `screening_hits` |
| Match score / basis | **91** / `EXACT_NAME_DIFFERENT_DOB` | `screening_hits` |
| Identity assessment | `FALSE_POSITIVE` | `screening_hits` |
| Analyst disposition | `CLEARED_FALSE_POSITIVE` on `2026-10-12` | `screening_hits` |
| Watchlist entity | `WL00002` — Daniel Mercer | `watchlist_entities` |
| Watchlist DOB / country | **1955-05-09** / `GB` | `watchlist_entities` |
| Watchlist classification | `SANCTIONS`, `ACTIVE` — **fictional** | `watchlist_entities` |
| Fictional sanctions designation | `SAN00002`, `ACTIVE`, `ASSET_FREEZE` | `sanctions_designations` |
| Customer ID and address documents | Both `VERIFIED` | `customer_documents` |
| Assessment | **2.8955**, `MEDIUM`, EDD `NO`, **DRAFT** | `customer_risk_assessments` |
| Recorded escalations | None for this case in original snapshot | `escalations` |
| QC and case approvals | None for this case in original snapshot | `qc_reviews`, `case_approvals` |

**Existing analyst rationale (verbatim from synthetic screening record):**

> Name similarity alone is insufficient; identity identifiers do not corroborate the record

### Evidence comparison

| Factor | Customer | Fictional list entry | Interpretation |
|---|---|---|---|
| Name | Daniel Mercer | Daniel Mercer | Matches; insufficient by itself |
| Date of birth | 1967-08-22 | 1955-05-09 | Substantive conflict (~12 years) |
| Country code | GB | GB | Corroborates geography but does not resolve the DOB conflict |
| Identity documents | ID and address proof VERIFIED | No actual source document attached to this practice listing | Customer-side evidence exists; examine the original documentation for confidence |
| Screening source | — | Training Sanctions Registry A, `SRC01` | Entirely simulated, **not an official source** |

**Do not confuse the fictional watchlist entry being ACTIVE with Daniel actually being designated.** The synthetic candidate appears on the simulated training sanctions list. The case's recorded decision is that it represents a **different person**.

## 3. Investigation workflow (what the analyst does)

1. **Triage** — Check `RUN0000002` and `HIT0000002`, including scope, match basis, score, source and case link.
2. **Compare identity attributes** — Verify customer name, date of birth, country and available identity documents against the candidate record. Look for further identifiers, aliases and corroboration if relevant.
3. **Assess match and document rationale** — The source data shows a materially different date of birth and a recorded `FALSE_POSITIVE` assessment. The name and country match alone do not establish identity.
4. **Verify the recorded disposition** — Confirm `CLEARED_FALSE_POSITIVE`, analyst ID `USR004`, review date and rationale. Don't present an earlier screening run as automatically approved by a reviewer.
5. **Review broader KYC completion** — Both customer documents are VERIFIED, but the risk-assessment checklist and QC approval checklist are OPEN. The customer risk assessment remains DRAFT.
6. **Recommend case handling** — Maintain the screening false-positive rationale if defensible; keep the *onboarding case* `IN_REVIEW` until outstanding checks, risk assessment and required approval are complete. Never treat screening clearance as automatic onboarding approval.

## 4. Control-quality observations (worth discussing in an interview)

**Chronology anomaly:** The case checklist labels `SANCTIONS_PEP_SCREENING` COMPLETE on `2026-10-11`, whereas the screening hit was reviewed on `2026-10-12`. This might reflect a *screening execution* milestone rather than a *fully reviewed alert*; clarify its definition and verify workflow timestamps rather than immediately alleging a control failure.

**Generic earlier note:** An existing case investigation note dated `2026-10-11` says that incomplete screening, documentation, approval **or** risk evidence requires follow-up. This predates the completed hit review and does not precisely describe the current evidence. A new analyst note should name the actual open controls.

**EDD control vs requirement:** The checklist shows `EDD_REVIEW` COMPLETE, while the risk assessment says EDD Required `NO`. This may simply mean the need for EDD was assessed; it does **not** establish that EDD was mandatory or performed. Verify policy/metadata definitions.

**No final approval:** Neither QC nor case-approval records exist for this case in the original snapshot. It must not be represented as approved.

## 5. Risk-scoring reconciliation

Synthetic factor values (from `case_risk_factors`):

| Risk factor | Value | Weight | Contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 3.55 | 0.20 | 0.7100 |
| GEOGRAPHIC | 1.00 | 0.20 | 0.2000 |
| PRODUCT_CHANNEL | 2.93 | 0.15 | 0.4395 |
| EXPECTED_ACTIVITY | 3.98 | 0.20 | 0.7960 |
| SCREENING_EXPOSURE | 3.00 | 0.25 | 0.7500 |
| **Total** | — | **1.00** | **2.8955** |

The 25% screening-exposure weight is an **illustrative model choice**, not a regulator or Citi requirement. A factor score of 3 on SCREENING_EXPOSURE should not be interpreted as evidence that the false positive wasn't cleared; the model score is a separate assessment snapshot. Never assert that any numerical risk score overrides mandatory sanctions controls.

## 6. Conclusion and disposition

**Screening decision in the supplied records:** `CLEARED_FALSE_POSITIVE` based on the DOB mismatch, despite an exact name and country match.

**Case-level analyst recommendation:** Keep the overall case `IN_REVIEW`; complete and approve the DRAFT customer risk assessment, finish QC/approval workflow, reconcile dates and document evidence. Do not change screening decisions without authorized review or reopen a cleared hit based only on its numeric score.

This analysis describes **recorded** decisions and **recommended** next steps separately; it does not claim that the author approved the customer or performed work for a financial institution.

## 7. Reproduce the evidence

Open `evidence_queries.sql` in VS Code. Run each complete, read-only SQL query against the `clearcase_kyc` schema. Confirm source IDs/values. Document any difference between the baseline CSV and the current MySQL database (which may include training modifications).

Suggested checks: **Queries 03, 04, 05, 07, 09 and 13**. These cover identity comparison, sanctions source, checklist gaps, risk-score reconciliation and review chronology.

## 8. GitHub presentation

Recommended folder: `featured_cases/06_daniel_mercer/`.

Files:
- `README.md` — this case background and defensible outcome.
- `analyst_note.md` — analyst-style note clearly separated from recorded disposition.
- `evidence_queries.sql` — repeatable investigation SQL with plain-language explanations.
- `interview_prep.md` — explain the decision and handle interviewer cross-questions.

**Do not publish real customer information**; all values here come from fictional educational records.
