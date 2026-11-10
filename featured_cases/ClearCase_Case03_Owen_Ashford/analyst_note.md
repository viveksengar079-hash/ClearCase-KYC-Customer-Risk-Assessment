# Analyst Investigation Note — Owen Ashford (`KYC000001`)

**Classification:** Synthetic training exercise — not a real sanctions listing or a submitted bank investigation.  
**Prepared:** 2026-11-10  
**Customer:** Owen Ashford (`CUS00001`), INDIVIDUAL, GB, PROSPECT  
**Case:** ONBOARDING / NEW_TO_BANK; `ESCALATED`, case priority HIGH, due 2026-10-19  
**Assigned analyst:** `USR003`  
**Recorded escalation:** `ESC000001`, type SANCTIONS_MATCH, OPEN, assigned `USR027`

## 1. Trigger and question

A new-to-bank cross-border-payments prospect was screened through the *synthetic* local sanctions/PEP reference process. Run `RUN0000001` (2026-10-06) returned hit `HIT0000001`, score 99, match basis `EXACT_NAME_AND_IDENTIFIERS`, with `identity_assessment=CONFIRMED_IDENTITY`. Analyst disposition was `ESCALATED_POTENTIAL_TRUE_MATCH`, reviewed 2026-10-08. The case remains escalated pending a specialist compliance decision. Question: can KYC onboarding progress while this concern and basic documentary checks remain open? **Recommendation: No, not before authorized resolution under the applicable workflow.**

## 2. Verified evidence (supplied CSV source snapshot)

| Source | Recorded evidence | What it means — and does not mean |
|---|---|---|
| `customers` | `CUS00001`; GB; DOB 1965-10-09; Accountant; product Cross-border Payments | Identity attributes align with a synthetic reference; no real identity verification asserted |
| `kyc_cases` | `KYC000001`, ONBOARDING, ESCALATED, HIGH priority, due 2026-10-19 | Escalation is still the case's recorded status |
| `screening_runs` | `RUN0000001` COMPLETED, potential_hit_count=1, source_snapshot_at 2026-10-06 | The technical run finished, not the compliance decision |
| `screening_hits` | `HIT0000001` score 99, EXACT_NAME_AND_IDENTIFIERS, CONFIRMED_IDENTITY, ESCALATED_POTENTIAL_TRUE_MATCH | Stored analyst screening conclusion; not evidence of real-world criminal activity |
| `watchlist_entities` | `WL00001`, Owen Ashford, GB, DOB 1965-10-09, SANCTIONS, ACTIVE | Fictional matched reference, not an official listing |
| `screening_sources` | `SRC03`, Training US Restriction Reference, synthetic YES, snapshot 2026-10-31 | Source needs provenance; not an actual legal authority |
| `sanctions_designations` | `SAN00001`, ACTIVE, training restriction `TRANSACTION_RESTRICTION` | Fictional example, does not establish an actual asset freeze or prohibition |
| `escalations` | `ESC000001`, SANCTIONS_MATCH, OPEN, decision Pending compliance review | Authorized disposition outstanding |
| `customer_documents` | Identity proof and address proof `MISSING`, exception `NOT_RECEIVED` | Mandatory customer evidence is incomplete |
| `customer_risk_assessments` | 3.296, MEDIUM, EDD NO, DRAFT | Risk average cannot approve or clear screening issue |
| `case_checklist` | ID, documents, screening, risk, QC OPEN; EDD_REVIEW COMPLETE | Control statuses need interpretation and reconciliation |
| `qc_reviews` / `case_approvals` | No rows in source snapshot | No recorded independent approval in that snapshot |

## 3. Risk assessment cross-check

The five weights sum to 1.00 and weighted values sum to **3.2960**. `SCREENING_EXPOSURE` has value 5 and weight 0.25, adding **1.25** to the total. The composite rating is MEDIUM even with high-severity screening concerns; this is **a model limitation to explain**, not a basis for clearing sanctions exposure. HIGH case priority reflects operational urgency, not the CRA's risk tier.

## 4. Gaps and inconsistencies

**DQ-01:** ID and address document records are missing; require collection, validation and properly captured evidence.  
**DQ-02:** EDD required NO in the CRA, yet EDD_REVIEW checklist COMPLETE; align assessment policy/status definitions and any required specialist review.  
**DQ-03:** Stored watchlist/source update 2026-10-31 follows screening/source snapshot 2026-10-06; a version-specific screening source is needed before treating that later row as the precise historical list entry.  
**DQ-04:** Reference source and training designation are fictional, not legal instructions. Identify governing jurisdiction and verified official list before determining actual restrictions.  
**DQ-05:** A previous SQL prose note referenced `WL000001`, but the source CSV's screening-hit foreign key is `WL00001`; use the actual ID and verify with MySQL.

## 5. Proposed disposition and next actions

- Maintain case status **ESCALATED** and the institution's applicable onboarding hold/stop controls pending sanctions/compliance disposition. Do **not** approve onboarding, mark the hit a false positive or assume a completed run resolves the concern.
- Supply the sanctions reviewer with the source evidence, matching DOB/country/name, hit metadata, designation and restriction labels, source-date discrepancy and missing documents. Check applicable jurisdiction and official list coverage using approved tools; none were accessed in this exercise.
- Obtain the missing customer documents and corroborate identity, source of funds/wealth and expected cross-border activity as required by the institution's policy.
- Resolve risk/EDD workflow inconsistencies and update case notes, audit trail, checklist and decisions only when supported by evidence and authorized approval.
- Do not create a genuine SAR/STR or claim confirmed illegal activity from this synthetic training record.

## 6. Training analyst note (copy-ready)

> **TRAINING CASE — KYC000001:** During onboarding of Owen Ashford, a simulated screening run identified hit HIT0000001 with score 99, exact name/identifier basis and recorded identity confirmation. The linked synthetic reference WL00001 is SANCTIONS-category with an ACTIVE fictional designation (SAN00001). The analyst recorded ESCALATED_POTENTIAL_TRUE_MATCH and open case-level escalation ESC000001; compliance review remains pending. Identity and address documents are missing. The illustrative customer risk score is MEDIUM (3.296, DRAFT, EDD NO), but this numeric rating cannot override sanctions screening controls. A source-snapshot-date inconsistency and an EDD/checklist inconsistency also need reconciliation. **Recommend maintaining the case in its authorized escalation/hold workflow; obtaining missing documentation; verifying the current authoritative list and applicable restrictions; and seeking the authorized compliance decision before onboarding or closure.**

**Scope limitation:** This is the student's simulated analyst recommendation. No sanctions decision, bank freeze, account action, approval or regulatory filing was executed.
