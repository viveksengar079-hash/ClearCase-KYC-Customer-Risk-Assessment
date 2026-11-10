# Case 11 — Proposed KYC / EDD Analyst Investigation Note

**Environment:** ClearCase KYC — fictional training simulation; not a bank-issued case note  
**Customer:** Trident Infrastructure (`CUS00011`) · `CORPORATE` · AE · Real Estate  
**Case:** `KYC001207` · EVENT_DRIVEN / HIGH_RISK_REVIEW · HIGH priority · COMPLEX · `ESCALATED`  
**Assigned maker:** `USR011` · **RM:** `USR022` · **Compliance:** `USR026`  
**Document status:** Proposed analyst write-up; **not submitted to MySQL**  
**Source snapshot:** Original synthetic CSVs dated 05 November 2026; local MySQL should be independently confirmed.

## A. Referral / reason for review

Event-driven high-risk corporate review for Trident Infrastructure, opened **21 October 2026** and due **31 October 2026**. The case has an illustrative customer risk score **3.714**, risk category `HIGH`, EDD `YES`, assessment `DRAFT`. Compliance escalation `ESC000050` (`HIGH_RISK_EDD`) was raised **24 October**, remains `OPEN`, and has decision summary `Pending compliance review`. I do not interpret this as a confirmed suspicious-transaction determination or sanctions match.

## B. Customer profile and expected business

Active corporate Real Estate customer in AE; account product `Current Account`, channel `Online`, with expected monthly activity **USD 206,000 across 14 transactions**. These are profile assumptions, **not analyzed transaction records**. Customer-declared source of funds is `Rental income`, while declared source of wealth is `Investments`. Neither label, without reliable supporting documentation, establishes the legitimacy or scale of activity or wealth.

## C. Evidence reviewed

**Documents:** `DOC0003257` incorporation certificate, `DOC0003258` registered address and `DOC0003259` director ID recorded `VERIFIED` 23 October 2026. `DOC0003260` ownership declaration and `DOC0003261` source-of-funds evidence are `MISSING` (`NOT_RECEIVED`). Three VERIFIED / two MISSING does not satisfy full document review.

**Source-of-wealth request:** `REQ000074` requests `SOURCE_OF_WEALTH`; opened 23 October, due 30 October, assigned to RM `USR022`, currently `OPEN` with blank response/closure. This is distinct from the missing `SOURCE_OF_FUNDS_EVIDENCE` document and requires its own evidence-led resolution.

**Ownership:** Trident has three VERIFIED direct ownership links: `PTY00012` (Intermediary Capital 12 Ltd) 55%; `PTY00015` (Bianca Harris) 30%; `PTY00016` (Felix Winters) 15%. Intermediary is 65% owned by `PTY00013` Ryan Langley and 35% by `PTY00014` Arjun Morgan; both underlying links are VERIFIED. Effective natural-person shares: Ryan 35.75%, Bianca 30%, Arjun 19.25%, Felix 15% = 100%. Bianca is recorded as Managing Director and Felix as Director; both director roles VERIFIED. Missing OWNERSHIP_DECLARATION and OPEN OWNERSHIP_UBO control mean the complete case-level ownership evidence remains outstanding. UBO decision must include the applicable ownership/control criteria; economic-share calculation alone does not settle legal UBO identification.

**Screening:** `RUN0001207` completed on 22 October, 0 potential hits, no linked `screening_hits`; however `SANCTIONS_PEP_SCREENING` mandatory checklist status is OPEN. Do not misreport the run as missing or infer zero general financial crime risk.

**Risk/EDD:** `RA001207` HIGH, **3.714**, EDD YES, DRAFT. Components: CUSTOMER_PROFILE 0.708; GEOGRAPHIC 0.900; PRODUCT_CHANNEL 0.549; EXPECTED_ACTIVITY 0.772; SCREENING_EXPOSURE 0.785; sum 3.714; weights total 1.00. All risk values are synthetic—not a real bank's scoring methodology. AE's HIGH geographic label in the dataset is likewise synthetic.

**Mandatory controls:** 1 of 8 COMPLETE (`ANALYST_NOTES`); 7 OPEN (CUSTOMER_IDENTITY, DOCUMENT_VERIFICATION, SANCTIONS_PEP_SCREENING, CUSTOMER_RISK_ASSESSMENT, OWNERSHIP_UBO, EDD_REVIEW, QC_APPROVAL). No QC, approval or final disposition is recorded for this review.

**Case notes and audit:** `NOTE0002396` is INTAKE; `NOTE0002397` is generic INVESTIGATION text. Audit records include screening run, information request and escalation. The `CASE_STATUS` change to ESCALATED is dated **23 October**, preceding the `ESC000050` escalation raised **24 October**; request timeline reconciliation without overwriting source history.

## D. Investigation findings and unresolved gaps

1. The customer has **unsubstantiated SoF and SoW declarations**; source-of-funds evidence is MISSING, while the source-of-wealth information request is OPEN. This is an EDD evidence gap, not proof of illicit funds.
2. Corporate ownership edges are VERIFIED and can be calculated to natural persons, but current ownership declaration is MISSING; independent evidence and control rights should be reconciled.
3. The completed screening run (zero hits) conflicts superficially with OPEN screening checklist status; identify whether this reflects outstanding review/sign-off, not an unperformed run.
4. Risk remains HIGH and DRAFT, and a dedicated HIGH_RISK_EDD compliance escalation is still OPEN. The case cannot be treated as approved.
5. The scenario mentions cross-border risk, but **no transaction-level cross-border transfers or counterparties are present in these source files**. Do not assert suspicious transactions based on the scenario title.
6. The audit chronology and generic existing note warrant data-quality follow-up.

## E. Recommended decision / action plan

**Recommendation: maintain `ESCALATED` / hold final completion pending evidence and authorized review.**

- Request documentary proof supporting Investments (SoW) and Rental income (SoF), the missing ownership declaration, relevant legal-entity records, and reconciliation of expected activity where policy requires it. Route `REQ000074` follow-up through RM `USR022`.
- Reconfirm natural-person ownership, voting/control rights and UBO thresholds under the applicable policy; verify the documented structure and obtain current signed/independent corroboration as required.
- Obtain specific, dated support for the funds/wealth narrative; identify discrepancies between the customer declarations, documents, and actual business profile. Any account-activity conclusions require separate transaction data.
- Complete or resolve the seven OPEN mandatory control steps appropriately; reconcile screening execution with checklist status and the audit-timeline discrepancy.
- Provide the documented risk/EDD rationale to compliance specialist `USR026` for decision on escalation `ESC000050`. Independent QC and appropriate approvals must precede case closure.
- Do not independently close `REQ000074`, mark EDD complete, clear an unrelated screening alert, or alter recorded approval/escalation history without authorized evidence and audit.

## F. Draft concise analyst handoff (not a database action)

> **TRAINING DRAFT — KYC001207 / Trident Infrastructure:** I reviewed the event-driven high-risk corporate file, synthetic risk assessment `RA001207` (HIGH, 3.714, EDD YES, DRAFT), and screening run `RUN0001207` (COMPLETED, 0 hits). The customer declares Rental income as source of funds and Investments as source of wealth, but documentary SoF evidence (`DOC0003261`) and the ownership declaration (`DOC0003260`) are MISSING; the SoW information request (`REQ000074`) remains OPEN. Five ownership edges are VERIFIED; the recorded 55% intermediary traces to two individuals with 35.75% and 19.25% effective interests, alongside 30% and 15% direct interests. Seven mandatory checklist steps, including EDD and QC, remain OPEN. I recommend holding case completion, requesting evidence through `USR022`, reconciling outstanding controls and audit chronology, and keeping escalation `ESC000050` OPEN pending decision by `USR026`. No suspicious cross-border transactions or final compliance determination are established by this dataset.

## G. Operational boundaries / quality standard

This is an **analysis of original synthetic records and a proposed next-step recommendation**. The actual local Streamlit DB has not been changed by these files. A real institution's regulatory obligations, authorized reviewers, document requirements and possible restrictive measures depend on its jurisdiction, applicable law and approved policy. Avoid claiming employment or authorization at Citi or another bank.
