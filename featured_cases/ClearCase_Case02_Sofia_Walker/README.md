# ClearCase KYC — Featured Investigation 02
## PEP match during onboarding: Sofia Walker

**Project context:** Synthetic-data KYC/AML investigation simulator. This is not a live bank record, a genuine PEP designation, or Citi's scoring methodology.

### Case summary (verified against supplied project dataset)

| Field | Source record |
|---|---|
| Customer | Sofia Walker (`CUS00003`) |
| KYC case | `KYC000003` |
| Customer type / location | INDIVIDUAL; `SG` country and nationality codes |
| Review / onboarding trigger | `ONBOARDING` / `NEW_TO_BANK` |
| Case status / priority | `PENDING_SCREENING` / `HIGH` |
| Assigned analyst | `USR011` |
| Case opened / due | 2026-09-29 / 2026-10-13 |
| Screening run | `RUN0000003`, `COMPLETED`, 2026-09-30 |
| Potential screening hit | `HIT0000003`, match score `99` |
| Match basis / identity review | `EXACT_NAME_AND_IDENTIFIERS` / `CONFIRMED_IDENTITY` |
| Watchlist entity | `WL00003`, name Sofia Walker, category `PEP` |
| Hit disposition | `ESCALATED_POTENTIAL_TRUE_MATCH` (reviewed 2026-10-02) |
| Compliance escalation | `ESC000002`, `PEP_EDD`, `OPEN`, assigned `USR027` |
| Risk assessment | `RA000003`: `3.6625`, `HIGH`, EDD `YES`, `DRAFT` |
| Quality control / approval | No QC or case-approval records in supplied source snapshot |

### Investigation question

**Can onboarding proceed when identity documents are recorded as verified, but a PEP-related screening candidate has been confirmed as the same identity and the EDD/escalation process is incomplete?**

**Proposed analyst disposition:** Keep the case pending the compliance decision, complete applicable EDD and relevant independent approval, and document the ultimate disposition. Do **not** approve onboarding solely because identity and address documents are marked `VERIFIED`. Do **not** call this a confirmed sanctions designation: the matched watchlist entity is categorized as `PEP`, and no matching row was found in the supplied `sanctions_designations` table.

### Evidence sequence

1. **Onboarding:** An individual prospect (`CUS00003`) entered the new-to-bank KYC workflow (`KYC000003`). The case remains `PENDING_SCREENING`.
2. **Customer documents:** Identity and address proof entries (`DOC0000005`, `DOC0000006`) are both marked `VERIFIED`; these are stored *status values*, not independent examination of document images.
3. **Screening:** A completed *simulated* local screening run produced one hit (`HIT0000003`) with match score `99` and the stated identity confirmation.
4. **Record classification:** The watchlist record is a fictional `PEP` record. The match is not documented as a sanctions designation.
5. **Disposition and escalation:** An analyst marked the hit `ESCALATED_POTENTIAL_TRUE_MATCH`; PEP/EDD escalation `ESC000002` remains `OPEN` with decision summary "Pending compliance review".
6. **Risk assessment:** `HIGH`, score `3.6625`, EDD `YES`, but assessment is `DRAFT`—not an approved final risk decision.
7. **Controls outstanding:** The checklist retains `SANCTIONS_PEP_SCREENING`, `CUSTOMER_RISK_ASSESSMENT`, `EDD_REVIEW`, and `QC_APPROVAL` as `OPEN`. The screening *run* is complete but the overall *case workflow* is not.

### Risk-factor calculation

The dataset's **illustrative** five-factor model adds `factor_value × weight`:

| Factor | Value | Weight | Contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 3.76 | 0.20 | 0.7520 |
| GEOGRAPHIC | 1.00 | 0.20 | 0.2000 |
| PRODUCT_CHANNEL | 4.39 | 0.15 | 0.6585 |
| EXPECTED_ACTIVITY | 4.01 | 0.20 | 0.8020 |
| SCREENING_EXPOSURE | 5.00 | 0.25 | 1.2500 |
| **Total** | | **1.00** | **3.6625** |

The `0.25` screening weight is an **illustrative model parameter**, not a Citi, regulator, or universal banking requirement. Its contribution is 1.25/3.6625 ≈ 34.1% of this particular calculated score. Numerical weighting **does not override** required screening, sanctions or PEP/EDD controls.

### Data-quality findings requiring analyst review

- The synthetic `pep_profiles` row (`PEP00001`) classifies the entity as `FORMER_PEP` but also sets `pep_status = CURRENT`, with an empty `term_end`. These fields may mean different things; do not silently interpret them as a confirmed current or former status.
- Its `public_position` is "Senior Public Official," with a recorded `term_start = 2015-07-02`, while the customer's/watchlist DOB is `2000-04-17`—approximately age 15 at that date. This is a **plausibility exception in the synthetic dataset**, not grounds to assert the PEP record is genuine or false.
- The screening run/source snapshot is dated `2026-09-30`, while the stored reference/source snapshot and watchlist last-updated dates include `2026-10-31`; the current reference record must not be represented as an immutable copy of exactly what was available on September 30. Retrieve an actual historical snapshot in a real system.
- The source is named "Training Related Parties Register", with synthetic source metadata, not an official sanctions/PEP authority. The source's category `RCA` differs from the entity record category `PEP`; confirm the source classification before drawing wider conclusions.

### What the analyst should do next

1. Confirm the screening candidate against credible, appropriately licensed sources and resolve the PEP profile's role/tenure inconsistencies.
2. Determine current/former PEP status and any related-party exposure under the institution's risk-based PEP policy; record supporting evidence, jurisdiction and dates.
3. Conduct applicable EDD: corroborate source of funds and source of wealth, expected activity, beneficial interests where relevant, and ongoing monitoring needs. The customer profile mentions investment returns and business ownership, but no supporting source-of-wealth documents are verified by the two document records shown.
4. Keep the escalation in the compliance queue until the authorized reviewer records a decision; do not assume escalation equals adverse finding or automatic refusal.
5. Complete the open checklist controls, update the risk assessment from DRAFT only with authorized supporting evidence, then route to independent QC and approval if permitted by policy.
6. Preserve case notes and the audit trail. Do not generate fictitious evidence, mark the case approved, or file a SAR/STR based only on PEP status.

### Streamlit demonstration

`Customer Search → CUS00003 → KYC000003 → Case Investigation`

- **Documents:** show the two verified records and explain why they do not clear a PEP exposure.
- **Screening:** show run `RUN0000003`, hit `HIT0000003`, match score `99`, identity assessment and disposition.
- **Risk Assessment:** show rating `HIGH`, score `3.6625`, EDD `YES`, `DRAFT`, and the five-factor reconciliation.
- **Approvals & QC → Escalations:** show `ESC000002` as `OPEN`.
- **Notes & Audit:** review the original timeline; any new note you save to the training database should be clearly marked training documentation and should not purport to resolve the PEP escalation.

### Package contents

- [`analyst_note.md`](analyst_note.md) — evidence, issues, disposition and follow-up
- [`evidence_queries.sql`](evidence_queries.sql) — **read-only** SQL to verify records in the *current* MySQL database
- [`interview_prep.md`](interview_prep.md) — defensible story and scenario questions

**Source/verification boundary:** Values above were cross-checked against the original supplied `ClearCase_KYC_Citi_Analyst_Project_Complete_Datasets.zip` CSV snapshot and the user's Streamlit risk-assessment screenshot. Your active MySQL database may contain subsequent training changes; run the SQL before treating current statuses as final. No live screening-provider or bank systems were accessed.
