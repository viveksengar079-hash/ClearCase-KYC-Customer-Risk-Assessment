# Case 07 — Crestline Manufacturing | Event-Driven KYC Review After Ownership Change

**Portfolio project:** ClearCase KYC Customer Risk Assessment & Investigation System  
**Customer:** `CUS00007` — Crestline Manufacturing (fictional corporate customer)  
**KYC case:** `KYC001204` · **Scenario:** `SC07` · **Analyst track:** L2 / complex corporate KYC  
**Case status in original CSV snapshot:** `IN_REVIEW` · **Priority:** `HIGH` · **Review type:** `EVENT_DRIVEN`  
**Verification:** Findings checked against the project's original synthetic CSV dataset. Recheck the live local MySQL database before final GitHub publication.

> **Educational simulation, not a real bank's case or policy.** This dataset contains invented names, identity data, dates and decisions. The project's `SIM_V1_5_FACTOR_WEIGHTED` model is illustrative, not Citi's or any other bank's risk methodology. The current local MySQL database may include training edits made after the original CSV snapshot.

## 1. Business problem — why an event-driven review was opened

Crestline Manufacturing is an **ACTIVE** corporate customer (`country_code=SG`). The case `KYC001204` was opened on **15 October 2026** with trigger `OWNERSHIP_CHANGE`, one day after the effective date shown for a new **65%** ownership interest. Its due date is **25 October 2026**, and the assigned analyst is `USR010` (the customer relationship manager is `USR023`).

The question is not simply whether the percentages add to 100%. **Has the significant new ownership and control been independently verified, and has the customer risk profile been appropriately reconsidered?** Until that is established, a completed document checklist or a completed screening run should not be confused with a completed KYC review.

## 2. What the actual records show

| Record | Source-snapshot finding | Table |
|---|---|---|
| Customer / country | `CUS00007`, Crestline Manufacturing; CORPORATE, `SG`, ACTIVE | `customers` |
| Case / trigger | `KYC001204`; `SC07`; `EVENT_DRIVEN`; `OWNERSHIP_CHANGE` | `kyc_cases` |
| Case opened / due | `2026-10-15` / `2026-10-25` | `kyc_cases` |
| Case priority / stage | HIGH; COMPLEX; `IN_REVIEW` | `kyc_cases` |
| New ownership link | `OWN000008`: `PTY00008` → CUS00007, **65% equity and 65% voting**, effective `2026-10-14`, **PENDING** | `corporate_ownership` |
| Other ownership link | `OWN000009`: `PTY00009` → CUS00007, **35% equity and 35% voting**, effective `2023-07-15`, **VERIFIED** | `corporate_ownership` |
| Identified persons | `PTY00008` William Nolan; `PTY00009` Noah Nolan; both `INDIVIDUAL` in party master | `related_parties` |
| Director appointments | William Nolan = Director; Noah Nolan = Managing Director; both director links **VERIFIED** | `customer_directors` |
| Documents | **Five** documents, all marked **VERIFIED**, including `OWNERSHIP_DECLARATION` | `customer_documents` |
| Screening | `RUN0001204` COMPLETED on `2026-10-16`; `potential_hit_count=0`; no screening-hit record | `screening_runs`, `screening_hits` |
| Risk | **MEDIUM 3.0510**, EDD required `NO`, assessment `DRAFT` | `customer_risk_assessments` |
| Open controls | `OWNERSHIP_UBO`, `CUSTOMER_RISK_ASSESSMENT`, and `QC_APPROVAL` | `case_checklist` |
| Case information requests | No matching request in the **original CSV snapshot** | `information_requests` |
| Escalations / QC / approvals | No case-level rows in the original CSV snapshot | `escalations`, `qc_reviews`, `case_approvals` |

**Important control distinction:** The `OWNERSHIP_DECLARATION` document is `VERIFIED`, and the relevant director link is also `VERIFIED`, but the **65% ownership relationship itself is `PENDING` verification**. These are separate evidence objects. None alone proves that the new shareholding/control position has been fully validated.

### Ownership structure (recorded, not yet fully verified)

```text
                 Crestline Manufacturing (CUS00007)
                  100% recorded shareholding
                            |
            +---------------+---------------+
            |                               |
    65% shares / votes                35% shares / votes
    effective 2026-10-14              effective 2023-07-15
    OWN000008 — PENDING               OWN000009 — VERIFIED
            |                               |
  William Nolan (PTY00008)          Noah Nolan (PTY00009)
          INDIVIDUAL                       INDIVIDUAL
```

**Arithmetic QA:** `65 + 35 = 100%` shareholding and `65 + 35 = 100%` voting rights. This is a **direct natural-person ownership scenario**, unlike Case 04's layered intermediary structure. At an illustrative *more-than-25%* threshold, both persons could be ownership-based UBO candidates, but the actual applicable threshold and control criteria depend on jurisdiction, institution and customer structure. Treat William's holding as **provisional** until the supporting ownership evidence is reconciled; do not claim a final UBO certification.

## 3. Investigation workflow an analyst can defend

1. **Verify trigger and timeline.** Confirm `OWNERSHIP_CHANGE`, the `2026-10-14` ownership effective date, the `2026-10-15` case opening and the HIGH-priority due date. A changed ownership record is the trigger, not proof of a completed review.
2. **Reconstruct shareholder and control positions.** Join `corporate_ownership` to `related_parties`. Separate equity `share_pct` from `voting_pct`, even though they are equal in this example. Assess who is a natural person, who exercises control, and whether older records were superseded.
3. **Review the pending 65% relationship.** Validate the source of the ownership change—e.g., updated shareholder register, share-transfer documents and dated beneficial-ownership declaration where applicable. Compare names, dates, percentages, voting rights and the company's corporate records. The example does **not** prove those underlying records have been independently inspected.
4. **Reconcile document status versus ownership control.** Five document rows say VERIFIED, but the `OWNERSHIP_UBO` checklist step and `OWN000008` verification status remain OPEN/PENDING. Flag this mismatch for review rather than marking the case ready.
5. **Check post-change screening.** `RUN0001204` is COMPLETED with zero recorded potential hits. That supports *no hits in this recorded run*, not a guarantee of no screening exposure ever; verify scope and screen relevant newly added persons as policy requires. The dataset only proves what it records.
6. **Reassess risk.** The risk score is MEDIUM 3.051, `DRAFT`, and EDD `NO` in the synthetic model. A material ownership change still warrants review of risk factors and the rationale before any approval; numerical scoring cannot override mandatory checks.
7. **Document and route.** Ask the relationship manager (`USR023`) for reliable missing ownership evidence if required, record an evidence-linked analyst note, and route under the simulated maker–checker workflow. Do not invent an existing information request or assert that the customer was approved.

## 4. Risk-score reconciliation (illustrative model)

| Risk factor | Factor value | Weight | Weighted contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 3.82 | 0.20 | 0.7640 |
| GEOGRAPHIC | 1.00 | 0.20 | 0.2000 |
| PRODUCT_CHANNEL | 3.03 | 0.15 | 0.4545 |
| EXPECTED_ACTIVITY | 3.15 | 0.20 | 0.6300 |
| SCREENING_EXPOSURE | 4.01 | 0.25 | 1.0025 |
| **Total** | — | **1.00** | **3.0510** |

**Model limitation / useful QA question:** The SCREENING_EXPOSURE score is 4.01 even though the recorded screening run has **zero hits**. The factor's note is generic synthetic text. You **cannot conclude** from that numeric factor alone that a sanctions/PEP hit exists. Investigate the scoring definition and whether it reflects other risk inputs; the source does not explain why it has that precise value.

**Separate checklist ambiguity:** `EDD_REVIEW` is COMPLETE although `edd_required` is NO. That can be consistent if the completed checklist documents a review of whether EDD is needed. Confirm the local workflow definition before calling it an error.

**Earlier note ambiguity:** An existing generic note says the case requires follow-up for incomplete “screening; documentation; approval or risk evidence,” while the screening-run record says COMPLETED/0 hits and documents are VERIFIED. The analyst should replace generic wording with the **specific unresolved control evidence**, not repeat it as a finding of incomplete screening without verification.

## 5. Recommended outcome — not an executed decision

**Keep the case IN_REVIEW.** Obtain and verify the documentary basis for William Nolan's newly recorded 65% ownership/voting rights, reconcile the ownership declaration to the legal ownership register and party identity records, assess both natural persons under applicable UBO/control criteria, review post-change screening and risk rationale, and then complete `OWNERSHIP_UBO` and `CUSTOMER_RISK_ASSESSMENT` through the permitted workflow. Submit for independent QC/approval only once the evidence is complete. The analyst should not change the case to COMPLETED without authorized approval.

This is an *investigation recommendation*, not proof that the actual local database has been changed or that any additional evidence has been received.

## 6. Reproduce in MySQL and Streamlit

- Run each **complete SQL statement** in `evidence_queries.sql` against your `clearcase_kyc` schema. All data queries are read-only; the opening `USE` only selects the database.
- In Streamlit search customer `CUS00007`, select `KYC001204`, then inspect Documents, Screening, Risk Assessment, Notes & Audit and Approvals & QC. The **current app does not have an ownership tab**; use Query 03 for direct shareholding and Query 05 for director records.
- Compare **Queries 01, 03, 06, 08, 09, 11 and 12** with the baseline. Record any differences caused by later local training edits.
- Do not claim the 11 featured investigations are actual employment cases or that this simulator implements an internal Citi approval procedure.

## 7. How to present on GitHub

Put this folder at `featured_cases/07_crestline_manufacturing/`. Include a non-sensitive Streamlit screenshot if helpful, but never expose your `.env` or MySQL credentials. Use `README.md` as the case landing page and link to `analyst_note.md`, `evidence_queries.sql` and `interview_prep.md`.
