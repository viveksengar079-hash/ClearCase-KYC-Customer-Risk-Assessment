# Analyst Investigation Note — Sofia Walker (`KYC000003`)

**Classification:** Synthetic training case, not a submitted bank investigation note.  
**As-of review:** 2026-11-10  
**Customer:** Sofia Walker (`CUS00003`) — INDIVIDUAL, SG  
**Review:** New-to-bank onboarding, `PENDING_SCREENING`, HIGH case priority  
**Assigned analyst:** `USR011`  
**Assessment:** `HIGH`, `3.6625`, EDD `YES`, `DRAFT`  
**Escalation:** `ESC000002`, `PEP_EDD`, `OPEN`

## 1. Alert / trigger

Onboarding screening identified one candidate record for Sofia Walker. The completed simulated screening run (`RUN0000003`, 2026-09-30) is associated with screening hit `HIT0000003`: `match_score=99`, `match_basis=EXACT_NAME_AND_IDENTIFIERS`, `identity_assessment=CONFIRMED_IDENTITY` and analyst disposition `ESCALATED_POTENTIAL_TRUE_MATCH` (reviewed 2026-10-02).

**Interpretation:** The data records an identity-confirmed **PEP-related** hit needing compliance review. It does **not** establish financial crime, an official external PEP designation, or a sanctions listing.

## 2. Supporting evidence reviewed

| Evidence source | Recorded result | Significance |
|---|---|---|
| `kyc_cases` | `KYC000003` ONBOARDING; `PENDING_SCREENING`; priority HIGH; due 2026-10-13 | Case remains open; priority is not the same as customer risk rating |
| `customer_documents` | Identity `DOC0000005` and address `DOC0000006` verified | Document checks marked complete; does not dispose of PEP concerns |
| `screening_runs` | `RUN0000003` COMPLETED, one potential hit | Tool/run completed, but not the case screening approval |
| `screening_hits` | `HIT0000003` score 99; exact name and identifiers; identity confirmed; escalated | Supports nontrivial candidate, not automatic approval or crime finding |
| `watchlist_entities` | `WL00003`, Sofia Walker, SG, `record_category=PEP` | Classifies the synthetic record as PEP, not sanctions |
| `pep_profiles` | `PEP00001`: `FORMER_PEP`, "Senior Public Official", fictional body, `pep_status=CURRENT` | PEP tenure/status details need validation |
| `sanctions_designations` | No designation entry for `WL00003` in supplied snapshot | Avoid calling this a sanctions match (absence here is not an official clearance) |
| `customer_risk_assessments` | Score `3.6625`, HIGH, EDD YES, DRAFT | Enhanced review indicated; risk conclusion not final |
| `case_risk_factors` | Five factor weights total 1.00; weighted values sum 3.6625 | Mathematical reconciliation passed |
| `escalations` | `ESC000002`, type PEP_EDD, OPEN, assigned USR027 | Compliance review unresolved |
| `case_checklist` | PEP screening, risk assessment, EDD and QC approval marked OPEN | Control completion still outstanding |
| `qc_reviews` / `case_approvals` | No entries in supplied snapshot | No evidence of QC pass or approval |

## 3. Source-data quality exceptions

**DQ-01 — Ambiguous PEP status:** `pep_category=FORMER_PEP`, `pep_status=CURRENT`, `term_end` blank. These may reflect different status dimensions or an erroneous snapshot. Obtain accurate tenure information; do not choose a convenient interpretation.

**DQ-02 — Implausible tenure start:** DOB 2000-04-17 and recorded senior-official term start 2015-07-02 imply age approximately 15 on taking office. This is unlikely and needs correction or corroboration in a real review. It is a fabricated training record.

**DQ-03 — Reference-date mismatch:** Screening date 2026-09-30 versus supplied watchlist/source update dates 2026-10-31. The present synthetic reference row should not be represented as a verified point-in-time source snapshot.

**DQ-04 — Source taxonomy:** Synthetic source metadata uses a training RCA register while the linked entity has record category PEP. Reconcile classification before drawing an external screening conclusion.

**DQ-05 — Missing corroborating EDD documents:** Customer profile states source of funds "Investment returns" and source of wealth "Business ownership"; the two verified case documents concern identity and address only. Further supporting evidence is needed to confirm these financial statements.

These are data-quality exceptions, **not proof the match is false positive**. Do not quietly alter the dataset to hide them.

## 4. Risk assessment reconciliation

`3.76×0.20 + 1.00×0.20 + 4.39×0.15 + 4.01×0.20 + 5.00×0.25 = 3.6625`

The `0.25` screening weight is **illustrative only**. The factor's 1.25 contribution is material, but compliance controls and policy overrides must be assessed separately from the weighted average.

## 5. Analyst reasoning and recommendation

The submitted document metadata indicates identity/address checks have been completed, but PEP identity screening has produced an escalated candidate, with outstanding EDD and an open compliance decision. The risk assessment remains DRAFT and the formal checklist has multiple OPEN controls. The case is **not ready for onboarding approval** based on the supplied snapshot.

**Recommended disposition:** Keep in `PENDING_SCREENING`; obtain credible source clarification on PEP role and tenure; complete applicable EDD including source-of-funds/source-of-wealth checks; maintain escalation `ESC000002` until an authorized compliance decision; then document the reasoning and route the file for appropriate independent review and approval. Escalate any additional, substantiated issues through institution policy. Do not treat PEP status by itself as criminal suspicion or an automatic SAR/STR trigger.

## 6. Further evidence required

- Independent identification and tenure evidence for the matched PEP profile and applicable PEP policy classification
- Supporting source-of-funds / source-of-wealth evidence and documented assessment of expected cross-border activity
- Compliance review disposition for `ESC000002`
- Completed mandatory screening, risk assessment, EDD and QC controls; independent approval if required
- Updated audit/analyst notes with case evidence references and accurate timestamps

## 7. Final analyst note (copy-ready practice version)

> **TRAINING CASE — KYC000003:** During new-to-bank onboarding, a completed simulated screening run returned a potential PEP hit (`HIT0000003`) with match score 99, exact-name/identifier basis and recorded identity confirmation. The linked synthetic watchlist record is classified PEP; no sanctions designation is recorded for it in the supplied snapshot. The hit was escalated, and PEP/EDD escalation `ESC000002` remains OPEN. Overall CRA is HIGH (3.6625), EDD required, and DRAFT. Identity and address documentation is marked verified, but screening, EDD, risk-assessment and QC controls remain open. PEP tenure/status fields contain inconsistencies that require source corroboration. **Recommend keeping onboarding pending compliance review, completing EDD, documenting verified evidence and obtaining required independent approval before progression.**

**Not an actual disposition:** This is a portfolio analyst recommendation; no approval, real bank account hold or regulatory report was executed.
