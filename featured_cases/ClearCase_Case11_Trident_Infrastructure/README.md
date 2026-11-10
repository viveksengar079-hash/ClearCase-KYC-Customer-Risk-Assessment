# Case 11 — Trident Infrastructure | High-Risk EDD, Source of Funds and Source of Wealth

**Portfolio:** ClearCase KYC Customer Risk Assessment & Investigation System  
**Customer:** `CUS00011` — Trident Infrastructure, fictional corporate customer (AE)  
**Case:** `KYC001207` · **Scenario:** `SC11` · **Review:** `EVENT_DRIVEN` · **Trigger:** `HIGH_RISK_REVIEW`  
**Snapshot status:** `ESCALATED` · **Priority:** `HIGH` · **Complexity:** `COMPLEX` · **Analyst:** `USR011`  
**Evidence date:** Original synthetic ClearCase source snapshot dated **05 November 2026**. Your local MySQL records may change following training edits.

> **This is fictional training data—not a bank case or Citi internal procedure.** This package documents an analyst's *proposed* investigation and is not a statement that any requested documents were received, any compliance decision was issued, or the case was approved. Source-of-wealth information here is a self-declared profile field, not verified proof.

## 1. Executive summary

Trident Infrastructure is an ACTIVE fictional AE corporate customer in the Real Estate industry. Its event-driven `HIGH_RISK_REVIEW` opened **21 October 2026**, was due **31 October 2026**, and is currently `ESCALATED`. The case carries an illustrative `HIGH` customer risk rating (score **3.714**), requires EDD (`YES`), and has a `DRAFT` risk assessment (`RA001207`). A compliance escalation, `ESC000050`, was raised **24 October 2026** and remains `OPEN`, with a pending compliance review.

The principal investigation gap is **financial/ownership evidence**, not a confirmed sanctions hit. The customer profile declares **source of funds: Rental income** and **source of wealth: Investments**, but the case has a **MISSING source-of-funds evidence document** (`DOC0003261`), **MISSING ownership declaration** (`DOC0003260`), and an **OPEN source-of-wealth information request** (`REQ000074`, due 30 October 2026). Those declarations alone cannot demonstrate that funds or accumulated wealth are legitimate or consistent with the customer's expected business profile.

A screening run (`RUN0001207`) is `COMPLETED` with **0 potential hits**, yet the screening *checklist control* remains `OPEN`. Record that difference accurately: screening execution occurred, but control sign-off is not shown as complete. Of eight mandatory controls, only `ANALYST_NOTES` is marked `COMPLETE` and the other seven are `OPEN`.

**Recommended disposition:** Retain the case in the escalated workflow; coordinate the missing source-of-funds, source-of-wealth and ownership evidence with the relationship manager (`USR022`), validate the customer's business/expected activity, complete the outstanding mandatory controls and document the EDD rationale. Submit any final disposition to the authorized compliance reviewer (`USR026`) and applicable independent QC/approval processes. Do **not** infer actual suspicious transactions or approve/close the case based solely on the numerical score.

## 2. Customer and review context

| Field | Source value | Analyst interpretation |
|---|---|---|
| Customer / case | `CUS00011` / `KYC001207` | Use this *review* case, not another case for the same customer |
| Customer type / country | CORPORATE / AE | AE is a country code, **not proof of real-world high geographic risk** |
| Industry / product / channel | Real Estate / Current Account / Online | Ask what business transactions and services are expected |
| Source of funds (customer profile) | Rental income | Self-declared source; corroboration pending |
| Source of wealth (customer profile) | Investments | Self-declared accumulation of wealth; supporting proof pending |
| Expected monthly volume | USD 206,000 | Profile expectation, **not actual flows** |
| Expected transactions per month | 14 | Profile expectation, **not observed activity** |
| Relationship manager | `USR022` | Follow-up owner for `REQ000074` |
| Assigned KYC analyst | `USR011` | Investigation owner in source data |
| Compliance escalation assigned to | `USR026` | Pending authorized compliance review |
| Opened / due | 21 / 31 October 2026 | Past due in 05 Nov snapshot; a contractual SLA breach is **not established** |

**Cross-border caveat:** The scenario name mentions a *high-risk cross-border customer*. The available 30-table KYC package does **not** include actual transaction-level cross-border flows, counterparties or source documents proving a specific international payment. The geographic risk factor is synthetic. Do not claim money was transferred across countries or that a named jurisdiction is inherently prohibited.

## 3. Source of funds vs source of wealth — what the evidence means

- **Source of Funds (SoF):** Where the money used for a particular transaction or account activity originates. Profile says `Rental income`. In a real investigation, examples of corroboration can include rental agreements, rent receipts, tax declarations, property ownership, bank account statements and reconciliation to expected activity; the precise evidence required depends on policy.
- **Source of Wealth (SoW):** How the customer ultimately accumulated its overall financial position. Profile says `Investments`. An analyst would seek coherent, verifiable investment ownership/history, capital origin, disposals, earnings, distributions or other documents relevant to the company, not simply accept the text field.
- **Observed data:** `DOC0003261` (`SOURCE_OF_FUNDS_EVIDENCE`) is `MISSING`, `REQ000074` (`SOURCE_OF_WEALTH`) is `OPEN` with no response or closure, and no verified SoW evidence is established by these case records. The document type and request item are **different**; one does not automatically resolve the other.

**Analyst action:** Request precise documents, assess reliability, reconcile dates, value and business logic, and document any residual discrepancy or inability to verify.

## 4. Document evidence — 3 VERIFIED, 2 MISSING

| Document ID | Type | Status | Practical implication |
|---|---|---|---|
| `DOC0003257` | INCORPORATION_CERTIFICATE | VERIFIED | Corporate formation evidence recorded |
| `DOC0003258` | REGISTERED_ADDRESS | VERIFIED | Address evidence recorded |
| `DOC0003259` | DIRECTOR_ID | VERIFIED | Identity of one recorded director verified |
| `DOC0003260` | OWNERSHIP_DECLARATION | MISSING / NOT_RECEIVED | Obtain the current corporate ownership declaration |
| `DOC0003261` | SOURCE_OF_FUNDS_EVIDENCE | MISSING / NOT_RECEIVED | Obtain and assess financial origin evidence |

The three verified documents were marked verified on **23 October 2026** by `USR011`. A verified director identity record does not establish the sufficiency of every corporate control and ownership check.

## 5. Ownership, UBO and director review

The **recorded ownership link records are VERIFIED** and sum to 100%. They show:

| Holder | Direct holding in Trident | Indirect breakdown / effective interest |
|---|---:|---|
| Intermediary Capital 12 Ltd (`PTY00012`) | 55% | Owns 55% of customer; intermediate corporate party |
| Bianca Harris (`PTY00015`) | 30% | 30% direct natural-person holding; also Managing Director |
| Felix Winters (`PTY00016`) | 15% | 15% direct natural-person holding; also Director |
| Ryan Langley (`PTY00013`) | — | 65% of intermediary × 55% = **35.75%** indirect |
| Arjun Morgan (`PTY00014`) | — | 35% of intermediary × 55% = **19.25%** indirect |

**Ultimate recorded natural-person economic interests:** Ryan **35.75%**, Bianca **30%**, Arjun **19.25%**, Felix **15%** = **100%**. Percentage control and voting rights must be assessed separately using the applicable jurisdictional and institutional thresholds. **Do not claim all four are legally confirmed UBOs** without applying the relevant threshold/control tests and verifying the missing `OWNERSHIP_DECLARATION`.

**Key nuance:** The five related ownership edges have status `VERIFIED`, yet the case-level ownership declaration document remains `MISSING` and the `OWNERSHIP_UBO` mandatory checklist is `OPEN`. The analyst should reconcile these different record types rather than falsely describing the ownership edges themselves as pending.

## 6. Screening and risk scoring

**Screening:** `RUN0001207`, performed **22 October 2026**, `run_status = COMPLETED`, `potential_hit_count = 0`, no associated `screening_hits`. This does **not** prove that other due-diligence risks are absent, nor does it close the `SANCTIONS_PEP_SCREENING` checklist (which remains `OPEN`).

**Customer risk assessment:** `RA001207` (`SIM_V1_5_FACTOR_WEIGHTED`), assessed 22 October 2026, **HIGH**, score **3.714**, `EDD_REQUIRED = YES`, `DRAFT`.

| Risk factor | Factor value | Weight | Weighted contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 3.54 | 0.20 | 0.708 |
| GEOGRAPHIC | 4.50 | 0.20 | 0.900 |
| PRODUCT_CHANNEL | 3.66 | 0.15 | 0.549 |
| EXPECTED_ACTIVITY | 3.86 | 0.20 | 0.772 |
| SCREENING_EXPOSURE | 3.14 | 0.25 | 0.785 |
| **Total** | | **1.00** | **3.714** |

The dataset's synthetic HIGH threshold is **3.40 or greater**. This is an educational scoring model, not Citi methodology or a regulatory standard. Although screening shows no hits, the *synthetic scoring factor* SCREENING_EXPOSURE is 3.14; these measure different things and should not be equated to an actual positive match.

## 7. Mandatory controls and case disposition

| Control | Source status |
|---|---|
| CUSTOMER_IDENTITY | OPEN |
| DOCUMENT_VERIFICATION | OPEN |
| SANCTIONS_PEP_SCREENING | OPEN |
| CUSTOMER_RISK_ASSESSMENT | OPEN |
| ANALYST_NOTES | COMPLETE |
| OWNERSHIP_UBO | OPEN |
| EDD_REVIEW | OPEN |
| QC_APPROVAL | OPEN |

**Seven mandatory controls are OPEN**, one is COMPLETE. No case-level QC record, final case approval or case disposition exists in the original dataset for `KYC001207`. `ESC000050` is an open **HIGH_RISK_EDD** escalation, raised 24 October 2026, assigned to compliance specialist `USR026`, decision summary `Pending compliance review`. Do not call it approved, finally rejected or a confirmed SAR/STR referral.

## 8. Source-data and workflow inconsistencies to flag

1. **Screening run vs checklist:** technical run `COMPLETED` with zero hits on 22 October while `SANCTIONS_PEP_SCREENING` checklist remains `OPEN`. These might capture execution versus analyst sign-off; verify the workflow definition.
2. **Generic investigation note vs screening:** `NOTE0002397` says follow-up is required for incomplete screening, documentation, approval or risk evidence; the screening run was completed. The note is generic—pinpoint which *control/analysis* is missing.
3. **Audit event order:** `EVT0005093` records transition to `ESCALATED` on **23 October**, while escalation `ESC000050` was raised **24 October**. This may be a separate workflow trigger, timestamp/backfill issue or synthetic inconsistency—investigate without rewriting history.
4. **Ownership evidence types:** all recorded ownership links are VERIFIED, but ownership declaration remains MISSING and ownership checklist OPEN. Keep these statements separate.
5. **Geography:** `countries.example_geo_risk` marks AE HIGH as a **synthetic label**. Never claim it is an objective real-world regulatory risk ranking.
6. **Date-based overdue vs SLA:** request `REQ000074` due 30 October and review due 31 October (snapshot 05 November). They are overdue by calendar date; the dataset does not supply policy clocks, extensions or breach decisions.

## 9. Proposed workflow (not completed actions)

1. Reconfirm corporate identity and account purpose; compare expected rental/business activity to the profile and supporting evidence.
2. Contact `USR022` about `REQ000074` and seek **verifiable SoW investment evidence**, plus missing SoF records and the ownership declaration.
3. Verify the 55% intermediary ownership chain to natural persons, determine threshold/control-based UBOs, and assess potential material changes.
4. Analyze expected USD 206,000/month and 14 transactions as **profile expectations only**; request actual transaction data if the real investigation requires activity review.
5. Document EDD rationale against the case's HIGH risk, with source reliability, unresolved gaps and status `DRAFT` correctly stated.
6. Reconcile checklist status versus completed screening run, and flag audit chronology to the appropriate owner.
7. Keep `ESC000050` open pending an authorized compliance decision; use independent QC/approvals only after all mandatory gates are complete.
8. Record actions actually taken with proper audit logs. Do not overwrite earlier case events or close the request without evidence.

**Proposed disposition:** `RETAIN ESCALATED / HOLD PENDING EDD EVIDENCE AND COMPLIANCE REVIEW`. This is a recommendation, **not a persisted MySQL update**.

## 10. Running the evidence checks and demonstrating Streamlit

1. Extract the package to `KYC_Customer_Risk_Assessment/featured_cases/11_trident_infrastructure/`.
2. Open `evidence_queries.sql` in your VS Code SQL editor connected to `clearcase_kyc`; run **one full SELECT statement at a time**, through its semicolon.
3. Start with Queries **04 (ownership paths), 07 (documents), 09 (SoW request), 13 (risk reconciliation), 15 (escalation)**. Compare to this snapshot; MySQL practice edits may differ.
4. In Streamlit, open `Case Management`, search `KYC001207`, select the case, then view `Case Investigation → Documents / Information Requests / Screening / Risk Assessment / Notes & Audit` and `Approvals & QC`.
5. If you choose to create a practice note, label it `TRAINING TEST ONLY` and remember **that** is a new actual database record; this Markdown file alone has **not** saved a note.

## 11. Interview positioning

Say: *“I investigated a fictional high-risk corporate event-driven KYC review in my ClearCase portfolio. I distinguished declared source of wealth from verified evidence, identified outstanding ownership/SoF documentation and EDD, reconciled a weighted risk score, and prepared a defensible compliance handoff.”* Do not claim real bank employment, actual suspicious cross-border payments, a sanctions positive match, or finalized compliance approvals.
