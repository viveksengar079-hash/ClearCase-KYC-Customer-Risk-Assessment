# Analyst Investigation Note — Samuel Whitmore

**Case:** `KYC000008` | **Customer:** `CUS00008` | **Review:** ONBOARDING | **Priority:** HIGH  
**Recorded stage:** ESCALATED | **Screening hit:** `HIT0000005` | **Escalation:** `ESC000003` OPEN  
**Source:** Synthetic original ClearCase CSV snapshot. This is a *portfolio recommendation*, not a note entered into the live Streamlit/MySQL system.

## Structured case note (for analyst practice)

The onboarding screening run for Samuel Whitmore (`CUS00008`) returned one potential match (`HIT0000005`, score 86) on a fictional sanctions reference record (`WL00004`). The watchlist primary name is **Samuel Whitmoor**, with the alias **Samuel Whitmore**, producing a strong name/alias match (`ALIAS_TRANSLITERATION`). Both records carry country `GB`, but customer DOB **9 June 1996** differs materially from the watchlist DOB **30 September 1956**. This discrepancy could support false-positive clearance **if both values are independently reliable**; however, the available training dataset does not document a completed reconciliation of the identity sources. The analyst recorded identity assessment `UNRESOLVED`, disposition `ESCALATED_UNRESOLVED` on **26 September 2026**, and escalation `ESC000003` remains OPEN pending compliance review.

Customer identity and address documents are marked VERIFIED, but this does not establish that the conflicting DOBs were corroborated against primary documents. The screening run is COMPLETED while the screening checklist control is OPEN—consistent with a generated alert that is not yet adjudicated. The synthetic risk assessment is HIGH (3.7135), EDD YES and DRAFT; QC approval and final risk assessment are outstanding. The reference-source metadata date (**31 October 2026**) is later than the September screening run and should be checked against historical snapshots.

**Recommendation:** Keep onboarding on hold under the simulated control framework; request corroborated DOB and other identifiers where appropriate, verify historical watchlist source/alias data, document all matching and conflicting attributes, and obtain the authorized sanctions-review disposition. Do not label Samuel a sanctioned person, clear the hit as false positive without defensible confirmation, or mark the KYC case approved. Escalation remains OPEN; no database status change is claimed.

## Evidence and reasoning register

| Evidence record | Finding | Analyst interpretation |
|---|---|---|
| `customers` / `kyc_cases` | Samuel Whitmore; DOB 1996-06-09; ESCALATED case | Customer-level facts recorded in dataset; verify with source documents |
| `screening_runs` | `RUN0000008` COMPLETED, one hit, 2026-09-24 | Screening execution completed, **not** final alert adjudication |
| `screening_hits` | `HIT0000005`, 86, alias match, UNRESOLVED | Match merits evidence review, not automatic confirmation |
| `watchlist_entities` | `WL00004` Samuel Whitmoor, 1956-09-30, `GB`, SANCTIONS, ACTIVE | Fictional candidate with strongly conflicting DOB |
| `watchlist_aliases` | `ALS00001` Samuel Whitmore, TRANSLITERATION | Exact-name alias correspondence only |
| `screening_sources` | `SRC09`, Training Global Watchlist, synthetic | No official sanctions coverage; later source-snapshot metadata |
| `escalations` | `ESC000003` OPEN, type SANCTIONS_MATCH | Authorized review remains unresolved |
| `customer_documents` | Two documents VERIFIED | Does **not** independently establish DOB provenance in this dataset |
| `case_checklist` | SANCTIONS_PEP_SCREENING, CUSTOMER_RISK_ASSESSMENT, QC_APPROVAL OPEN | Case should not be finalized |
| `customer_risk_assessments` | HIGH 3.7135, EDD YES, DRAFT | Illustrative scoring, not final sanctioned/unsanctioned determination |

## Unresolved questions / next actions

1. Which reliable, independently validated primary document supports the customer's DOB? Are there other identifiers (place of birth, nationality, address, passport number) that can be compared lawfully?
2. What is the provenance and verification status of the fictional list candidate's 1956 DOB and Samuel Whitmore alias?
3. Was a contemporaneous watchlist version available on **24 September 2026**? Why do source/entity metadata show **31 October 2026**?
4. Did the prior analyst review the DOB discrepancy, and what exact evidence led to the `UNRESOLVED` disposition? The general rationale says identifiers were insufficient.
5. What action, if any, did Compliance take after escalation `ESC000003`? No final closure/authorization is recorded in this snapshot.
6. What remains for EDD, risk assessment and independent QC, and who is authorized to sign off?

## Interview-safe 45–60 second summary

> I investigated a synthetic onboarding sanctions-screening alert where a customer's name exactly matched a watchlist alias, while the primary watchlist spelling was slightly different. The match score was 86, but I did not interpret that as a probability that the customer was sanctioned. I compared identity attributes and found a substantial DOB mismatch—1996 for the customer versus 1956 for the watchlist candidate. The record had already been escalated as unresolved, so I checked whether the underlying identity data and reference source were dependable rather than declaring a false positive. I also found the screening checklist, risk assessment and QC stages still open. My recommendation was to maintain the escalation, obtain corroborating identifiers and follow authorized compliance review before onboarding. The lesson is that a plausible alias match requires reliable identity verification and careful documentation.

**Important boundary:** This note states what was *observed* and what should be *recommended*; it does not claim actual sanctions status, customer guilt, investigator employment, or an executed case disposition.
