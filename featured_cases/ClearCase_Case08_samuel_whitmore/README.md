# Case 08 — Samuel Whitmore | Alias / Fuzzy Sanctions Screening Investigation

**Portfolio:** ClearCase KYC Customer Risk Assessment & Investigation System  
**Customer:** `CUS00008` — Samuel Whitmore (fictional individual, `GB`)  
**Case:** `KYC000008` · **Scenario:** `SC08` · **Review:** `ONBOARDING` · **Priority:** HIGH · **Level:** L1 analyst  
**Recorded case status:** `ESCALATED` · **Screening identity assessment:** `UNRESOLVED`  
**Source:** Original synthetic ClearCase CSV snapshot. Re-run the SQL against your working MySQL instance before publication.

> **Educational simulation only.** The customer, fictional watchlist, match results and decisions are not allegations about any actual person, and no actual bank or sanctions authority is represented. The synthetic `SIM_V1_5_FACTOR_WEIGHTED` risk model is not Citi's internal methodology. These files describe analyst review and recommendations, not real client work or a final compliance decision.

## 1. Case overview — an alias match is not identity confirmation

Samuel Whitmore (`CUS00008`) is a prospective individual customer with an ONBOARDING case opened **23 September 2026**, due **7 October 2026**. The simulated sanctions/PEP/crime screening run `RUN0000008` completed on **24 September 2026** and recorded **one potential hit** (`HIT0000005`). The primary watchlist name is **Samuel Whitmoor**, while a watchlist alias is **Samuel Whitmore**. This yields an apparent *exact match to an alias*, despite a spelling variation against the primary record. The hit's matching method is recorded as `ALIAS_TRANSLITERATION`, with match score **86**.

**Key conflict:** The verified-or-not-yet-verified customer identity file records **1996-06-09** as Samuel's date of birth, while the watchlist candidate records **1956-09-30**. These dates are nearly 40 years apart. The country (`GB`) matches, but country alone is weak identity evidence. Despite the DOB conflict, the analyst disposition in the dataset is `ESCALATED_UNRESOLVED` and identity assessment `UNRESOLVED` because the recorded analyst rationale says identifiers were insufficient for a confident disposition.

The analyst must **investigate the quality, reliability and provenance of both DOB values**, plus any other decisive identifiers. The dataset does not prove that the DOB difference was independently reconciled. Do not casually override the recorded disposition or assert a confirmed sanctions match.

## 2. Verified records and how to interpret them

| Topic | Original-source finding | Interpretation |
|---|---|---|
| Customer / jurisdiction | Samuel Whitmore, `CUS00008`, INDIVIDUAL, `GB`, PROSPECT; DOB `1996-06-09` | Identity data as recorded; authenticity must be validated before final screening disposition |
| Case | `KYC000008`, `SC08`, ONBOARDING, `ESCALATED`, HIGH; assigned `USR001` | Outstanding L1 review and escalation; not approved or completed |
| Screening run | `RUN0000008`, `2026-09-24`, `COMPLETED`, `potential_hit_count=1` | The automated/local run completed, not the subsequent hit investigation |
| Screening hit | `HIT0000005`, score **86**, `ALIAS_TRANSLITERATION` | Candidate matching is probabilistic or heuristic; score is **not** probability of wrongdoing |
| Watchlist identity | `WL00004`, primary **Samuel Whitmoor**, alias **Samuel Whitmore** (`ALS00001`) | Alias supplies matching name; name agreement cannot establish identity alone |
| Watchlist attributes | Synthetic SANCTIONS record, `ACTIVE`, `GB`, DOB `1956-09-30` | Different DOB from customer; active *fictional* reference record, not an official designation |
| Source | `SRC09`, **Training Global Watchlist**, synthetic GLOBAL reference | Not an official or current sanctions source; the portfolio cannot claim live list coverage |
| Hit review | Reviewed **2026-09-26**, `UNRESOLVED`, `ESCALATED_UNRESOLVED` | Existing analyst did not approve a false-positive clearance or confirmed true-match decision |
| Case escalation | `ESC000003`, `SANCTIONS_MATCH`, **OPEN**, assigned `USR026`, decision pending compliance review | Open review requiring authorized decision; not proof of prohibition or wrongdoing |
| Customer documents | Two documents (IDENTITY_PROOF, ADDRESS_PROOF), both VERIFIED | A document's status does not prove the matching data were compared with the watchlist DOB |
| Mandatory checklist | Screening, Risk Assessment and QC Approval **OPEN**; identity, documentation, notes COMPLETE | Case cannot be treated as ready for completion merely because screening execution was recorded |
| Customer risk | HIGH **3.7135**, EDD YES, DRAFT | Synthetic risk score; no final authorized risk approval recorded |
| QC / case approvals | No records for this case in original snapshot | Independent review/approval is not documented as complete |

### Important temporal QA issue

The run says `source_snapshot_at = 2026-09-24` and the screening hit was reviewed **26 September 2026**. However, the reference `screening_sources.snapshot_date` and `watchlist_entities.last_updated` are both **2026-10-31**. The October metadata is **later** than the September screening event. It may reflect a later export of the reference data, but the source does not supply a historical as-of version. **Do not claim that the exact October version of the watchlist was available in the September run.** Flag the chronology and seek an as-of snapshot or vendor audit details in a real workflow.

## 3. Investigation workflow — how a competent L1 analyst handles this

1. **Confirm scope and identifiers.** Verify correct customer/case (`CUS00008`, `KYC000008`), screening subject, run, hit, and sanctions category. Inspect actual primary name, alias, and match basis rather than relying solely on the match score.
2. **Compare identifiers.** Check the primary name mismatch, exact alias-name match, recorded countries, and large DOB difference. Determine whether DOB and other identifiers are supported by reliable, current customer documents; the dataset's generic VERIFIED status is not sufficient to claim that independently.
3. **Review the watchlist record's reliability.** Identify the list source, its synthetic status, record update history, and whether the alias is a transliteration or spelling variant. Reconcile the later October reference snapshot against the September screening date.
4. **Assess outcome with calibrated uncertainty.** The DOB mismatch is strong evidence against identity if both DOBs are trustworthy, but the source record documents insufficient identifiers. A high name similarity score cannot settle the conflict. Document what's verified, what's missing, and why clearing now would be premature under this recorded workflow.
5. **Preserve the escalation.** The recorded disposition `ESCALATED_UNRESOLVED` and escalation `ESC000003` OPEN must remain separate from any hypothetical analyst recommendation. Do not falsely claim to have changed them or released onboarding.
6. **Review other blockers.** The illustrative risk model is HIGH 3.7135 with EDD YES and DRAFT assessment. Mandatory screening, risk assessment and QC approval steps are OPEN. Check for further evidence/approvals before recommending case completion.
7. **Write an evidence-led note.** Include customer and list DOBs, alias evidence, watchlist details, review dates, missing identifiers, chronology limitation, escalation owner and a specific next step. Follow bank-specific policy for an eventual decision.

## 4. Risk-factor reconciliation (illustrative only)

| Factor | Factor value | Weight | Contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 4.05 | 0.20 | 0.8100 |
| GEOGRAPHIC | 1.00 | 0.20 | 0.2000 |
| PRODUCT_CHANNEL | 4.05 | 0.15 | 0.6075 |
| EXPECTED_ACTIVITY | 4.23 | 0.20 | 0.8460 |
| SCREENING_EXPOSURE | 5.00 | 0.25 | 1.2500 |
| **Total** | — | **1.00** | **3.7135** |

The model gives SCREENING_EXPOSURE a factor value of 5. That is **not** evidence of a legally confirmed sanctions designation. Numerical risk ratings never replace mandatory applicable sanctions obligations or authorized review.

## 5. Recommended disposition — proposed, not executed

**Maintain `ESCALATED` / `UNRESOLVED` and keep onboarding on hold pending the authorized screening decision under the training workflow.** Check the source and verification of both DOBs; gather corroborating identifiers (where lawfully available and policy-appropriate); verify the relevant list snapshot and alias record; document the significant discrepancy and remaining unknowns; and obtain compliance guidance for disposition. A reliable, corroborated DOB conflict **may support** a false-positive outcome, but **this case's existing audit trail does not show an authorized false-positive clearance**. The analyst must not invent one. Separately resolve the DRAFT risk assessment and open mandatory checklist steps before any approval.

## 6. How to reproduce in your MySQL + Streamlit project

- Open `evidence_queries.sql`; execute each complete query through its semicolon. All data operations are SELECTs; `USE clearcase_kyc` only selects your schema.
- Open Streamlit **Customer Search → `CUS00008` → `KYC000008` → Case Investigation**. Review Documents, Screening, Risk Assessment and Notes & Audit. Review **Approvals & QC → Escalations** for `ESC000003`.
- Run Queries 04–08 to compare the hit, alias, DOBs and reference chronology; Query 10 for open control steps; Query 13 to reconcile score **3.7135**.
- The original dataset is a snapshot. Training edits to local MySQL may change records; document any differences honestly before GitHub publication.

## 7. Portfolio disclosure

This is a **fictional training investigation**, not an actual employment case or an official sanctions-list search. Avoid uploading secrets (`.env`, database credentials), actual customer information, or any unverified assertion about the watchlist subject. Include a non-sensitive screenshot of your locally running app only if useful.
