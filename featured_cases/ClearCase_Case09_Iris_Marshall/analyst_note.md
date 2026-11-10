# Case 09 — Analyst Investigation Note

**ClearCase KYC — Training Simulation / Draft Analyst Note**  
**Case ID:** `KYC001205` · **Customer ID:** `CUS00009`  
**Customer:** Iris Marshall · **Case type:** PERIODIC  
**Recorded case status:** `PENDING_SCREENING` · **Priority:** HIGH  
**Assigned analyst in original snapshot:** `USR009` · **Escalation:** `ESC000049 OPEN`  
**Evidence basis:** Original synthetic ClearCase CSV snapshot, not an actual live screening investigation.  
**Note status:** Proposed portfolio analysis only; this document has **not** been submitted to a bank or written back to the MySQL case history.

## 1. Investigation trigger and scope

The existing customer, Iris Marshall (`CUS00009`), entered a scheduled periodic KYC review (`KYC001205`) on **23 October 2026**, due **13 November 2026**. A simulated screening run (`RUN0001205`) on **24 October 2026** recorded one potential PEP hit (`HIT0000355`). The hit was reviewed on **26 October 2026**, marked `CONFIRMED_IDENTITY` / `ESCALATED_POTENTIAL_TRUE_MATCH`, and linked to open PEP/EDD escalation `ESC000049` assigned to `USR026`. The case remains `PENDING_SCREENING`. Earlier onboarding case `KYC000009` is separate and previously COMPLETED.

## 2. Confirmed recorded evidence

- **Identity comparison:** Customer Iris Marshall, DOB `1988-07-23`, GB; fictional watchlist entity `WL00005` has the same name, DOB and GB country, recorded under PEP category. Match score **99**, basis `EXACT_NAME_AND_IDENTIFIERS`. This supports the dataset's recorded identity assessment; the score is not a probability of unlawful activity.
- **PEP profile inconsistency:** Training scenario `SC09` is called "Former PEP and related close associate", but PEP profile `PEP00002` is `FOREIGN`, `CURRENT`, position `Minister`, with a recorded start date `2012-10-31` and **no term_end**. The source name "Training Former Officials Register" does not resolve the disagreement. The reported public body (fictional state-owned enterprise) may be inconsistent with the listed title and should be checked against dated, authoritative information in a real case.
- **Related-party links:** `WLR00055` records Iris → Gabriel Graham (`WL00025`) as `CLOSE_ASSOCIATE` since `2019-08-12`. `WLR00106` records Leo Marshall (`WL00293`) → Iris as `BUSINESS_ASSOCIATE` since `2018-04-04`. Neither link has a recorded end date. Gabriel's separate profile is INTERNATIONAL_ORGANIZATION / CURRENT; Leo's is RCA / FORMER. There is **no demonstrated family relationship**, even though Iris and Leo share a surname.
- **Documents:** IDENTITY_PROOF, ADDRESS_PROOF and SOURCE_OF_FUNDS_EVIDENCE for `KYC001205` are all VERIFIED. This does not complete PEP screening or EDD controls.
- **Customer risk:** `RA001205` scores **3.446**, rated HIGH, EDD YES, assessment DRAFT. Five factor contributions total **3.446** with weights totaling **1.00**. The scoring model `SIM_V1_5_FACTOR_WEIGHTED` is illustrative, not Citi methodology.
- **Outstanding mandatory checklist:** SANCTIONS_PEP_SCREENING, CUSTOMER_RISK_ASSESSMENT, EDD_REVIEW and QC_APPROVAL remain OPEN. Customer identity, document verification and analyst notes are COMPLETE.
- **Other media:** The separate simulated alert `AMA000150` is marked `FALSE_POSITIVE`, LOW relevance, MEDIUM reliability, `CLEARED`; fictional source article `AM00002` is at DISMISSED stage. Do not conflate this cleared media candidate with the active PEP escalation.
- **Approval / customer requests:** No case-specific independent QC or case approval entries and no information-request row appear in the original snapshot. The OPEN escalation is a compliance-queue item, not a missing-document request.

## 3. Outstanding uncertainties and data-quality questions

| Issue | Why it matters | Required follow-up in a real investigation |
|---|---|---|
| Former PEP scenario vs CURRENT/FOREIGN PEP profile | Could change classification, review frequency and EDD approval routing | Obtain dated authoritative office/term information; determine applicable PEP status under institution policy |
| Official role descriptor not fully supported | "Minister" and synthetic public body are insufficient to confirm a real office | Verify precise position, public function, jurisdiction and relevant dates |
| Close/business-associate links have no end date | Cannot infer current closeness, economic control or involvement | Verify association nature, evidence, duration and relevance; assess counterpart screening requirements |
| Screening run Oct 24 vs source metadata Oct 31 | Historical screening-source version is unclear | Retrieve actual as-of list snapshot, provenance or vendor audit trace |
| EDD and risk assessment still OPEN/DRAFT | No final approval has been recorded | Complete due diligence, source of wealth/funds corroboration where required, and appropriate maker-checker review |

## 4. Proposed disposition (NOT an executed case action)

**Maintain case `PENDING_SCREENING` and open PEP/EDD escalation `ESC000049` pending authorized compliance assessment.** Do not represent Iris as a verified *former* PEP based on the scenario label; the available profile records `CURRENT`. Independently verify the political exposure period and classification, evaluate associated relationships according to applicable procedures, review source-of-funds and wealth evidence in context, and complete EDD / risk approval routing. Do not automatically reject the customer or conclude misconduct solely because a PEP identity match exists. Do not mark the KYC case complete, clear the escalation, or report senior-management approval where none is documented.

## 5. Short analyst note suitable for interview narration

> **Synthetic training case — not a bank decision.** Reviewed Iris Marshall (`CUS00009`) periodic KYC case `KYC001205` and simulated PEP hit `HIT0000355` (score 99; exact name/identifiers; identity confirmed in source record). The hit is escalated and related compliance escalation `ESC000049` remains OPEN. The training scenario states "Former PEP", but detailed PEP record `PEP00002` says FOREIGN/CURRENT with no end date; classification requires independent corroboration. Recorded association links exist with Gabriel Graham (CLOSE_ASSOCIATE) and Leo Marshall (BUSINESS_ASSOCIATE), but present-day nature and relevance are unverified. Three customer documents are VERIFIED; risk is HIGH 3.446, EDD YES, assessment DRAFT. Screening, risk assessment, EDD review and QC approval remain OPEN. Recommend maintaining escalation, reconciling PEP status and relationship evidence, completing EDD and obtaining authorized review before closure. No final compliance clearance or approval is claimed.

## 6. Evidence and audit references

- `KYC001205` — case and control/checklist tables
- `RUN0001205`, `HIT0000355` — screening run and analyst disposition
- `WL00005`, `PEP00002`, `SRC05` — fictional PEP reference, profile and source
- `WLR00055`, `WLR00106` — watchlist relationship records
- `RA001205` and five `case_risk_factors` — risk rating and model reconciliation
- `ESC000049` — OPEN PEP_EDD escalation
- `AMA000150`, `AM00002` — separately cleared synthetic adverse-media alert
- `case_audit_log` and `case_notes` — recorded workflow history

For reproducible SQL, see `evidence_queries.sql`, especially Queries 04–08, 10–15 and 20. The source is the original CSV snapshot; re-run before publication if your working MySQL data was modified during Streamlit practice.
