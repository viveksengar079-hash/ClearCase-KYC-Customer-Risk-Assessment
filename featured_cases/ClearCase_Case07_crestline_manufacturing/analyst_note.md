# Analyst Investigation Note — Crestline Manufacturing

**Case:** `KYC001204` | **Customer:** `CUS00007` | **Review:** EVENT_DRIVEN  
**Trigger:** OWNERSHIP_CHANGE | **Priority:** HIGH | **Recorded stage:** IN_REVIEW  
**Scope:** Synthetic training evidence in the original ClearCase CSV snapshot. Analyst recommendation only; not entered into the live case or approved by a bank.

## Analyst note (portfolio-ready)

An event-driven review was opened on 15 October 2026 following a material change in Crestline Manufacturing's ownership structure. The registered ownership records show William Nolan (`PTY00008`) holding 65% of shares and voting rights effective 14 October 2026; this ownership relationship is marked **PENDING verification**. Noah Nolan (`PTY00009`) holds the remaining 35%, with the relationship marked VERIFIED. Both parties are recorded as individuals, making them ownership/control candidates for further beneficial-ownership assessment under the applicable policy. Their combined recorded holdings total 100%, but the pending 65% link prevents treating the ownership position as fully verified.

Five case documents are recorded as VERIFIED, including an ownership declaration. The sanctions/PEP screening run completed with zero recorded potential hits. However, mandatory controls for OWNERSHIP_UBO, CUSTOMER_RISK_ASSESSMENT and QC_APPROVAL remain OPEN. The risk assessment is MEDIUM (3.0510), EDD not required, but DRAFT. No case-level information request, escalation, QC review or approval appears in the source snapshot.

**Disposition recommendation:** Maintain IN_REVIEW; reconcile the new shareholder register, effective transfer, control/voting rights and ownership declaration; request corroborating evidence through the relationship manager if needed; confirm relevant party screening and refresh the documented risk rationale. Route for QC/approval only after mandatory controls are satisfied. No KYC completion or UBO certification is claimed.

## Evidence and reasoning register

| Evidence | Observation | What it establishes / does not establish |
|---|---|---|
| `corporate_ownership`: `OWN000008` | William Nolan — 65% share and vote; `PENDING` | A recorded ownership claim, **not** independently verified control |
| `corporate_ownership`: `OWN000009` | Noah Nolan — 35% share and vote; `VERIFIED` | The other recorded direct ownership link |
| `related_parties` | Both owners are INDIVIDUAL | Natural-person UBO candidates; not final certification |
| `customer_documents` | All five document rows VERIFIED | Document processing status, **not** verification of each ownership link |
| `screening_runs` | RUN0001204 COMPLETED, potential_hit_count 0 | No potential hits recorded in this run; not an absolute sanctions clearance |
| `customer_risk_assessments` | MEDIUM, 3.0510, DRAFT, EDD NO | Illustrative unapproved risk assessment; not a substitute for controls |
| `case_checklist` | OWNERSHIP_UBO / CUSTOMER_RISK_ASSESSMENT / QC_APPROVAL OPEN | Case not ready for final closure/approval |

## Open questions for second-line review or relationship manager

1. Which legally reliable shareholder register, transfer instrument and effective-date evidence support the new 65% ownership? Were the documents current at the time of review?
2. Is there an updated beneficial-ownership declaration, and does it reconcile to the company's register, voting rights and controlling arrangements?
3. Should either natural person meet the applicable ownership or control threshold; are there any additional agreements, nominees or control rights beyond share percentages?
4. Was screening refreshed for all relevant persons after the change? The case-level customer run alone may not establish individual-owner screening coverage.
5. Why is the model's SCREENING_EXPOSURE factor 4.01 with zero case-level hits? Does the score reflect inputs not visible in these tables?
6. Who may close OWNERSHIP_UBO, approve the final risk assessment and perform independent QC under the simulated maker-checker process?

## Interview-safe 45–60 second summary

> I investigated a synthetic event-driven KYC case triggered by a change in corporate ownership. The company had two individual owners, with a new 65% controlling interest recorded as pending verification and the remaining 35% verified. I joined the ownership and party tables, distinguished shareholding from voting rights, and checked documentation, screening, risk assessment and open checklist controls. Although five documents were marked verified and screening recorded no hits, the ownership link and risk assessment were not finalized. I recommended keeping the case in review, obtaining corroborating ownership evidence and routing it for independent approval. The key lesson is that a document marked verified does not automatically mean the ownership relationship is verified.

**Boundary:** This document is simulated analysis from project data. It does not assert that verification actions were completed, a regulatory UBO threshold was officially applied, or the customer was approved.
