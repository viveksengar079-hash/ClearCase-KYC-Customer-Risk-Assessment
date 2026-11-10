# Analyst Investigation Note — Northgate Imports (`KYC001201`)

**Training classification:** Synthetic KYC case; recommendation only, not an actual bank disposition.  
**Basis:** Supplied source CSV snapshot; verify current MySQL output before final GitHub publication.  
**Customer:** Northgate Imports (`CUS00004`), UAE corporate import/export customer, status ACTIVE.  
**Case:** `EVENT_DRIVEN` triggered by `OWNERSHIP_CHANGE`; opened 2026-11-03, due 2026-11-13; priority HIGH, complexity COMPLEX, status `PENDING_INFORMATION`; analyst `USR012`, RM `USR023`.

## 1. Trigger and risk question

A material ownership-change event opened a KYC refresh. An intermediary corporate shareholder is recorded as holding 55% of Northgate Imports, but its direct ownership link has not been verified. The analyst must identify the ultimate natural persons, validate their holdings and control, resolve missing documentary requirements, and determine whether review completion is supportable.

## 2. Evidence reviewed — what the records actually say

| Source | Recorded finding | Meaning / limitation |
|---|---|---|
| `corporate_ownership` | `OWN000003`: Intermediary Capital 1 Ltd (`PTY00001`) owns 55%; `verification_status=PENDING` | Largest direct holding has unverified documentary support |
| `corporate_ownership` | `OWN000001`: Jonah Carter owns 65% of intermediary; `VERIFIED` | 55% × 65% = **35.75% effective** but dependent on unverified upstream link |
| `corporate_ownership` | `OWN000002`: Oscar Bennett owns 35% of intermediary; `VERIFIED` | 55% × 35% = **19.25% effective** but dependent on unverified upstream link |
| `corporate_ownership` | `OWN000004`: Priya Mercer holds 30% direct, `VERIFIED` | **30.00% effective** direct interest |
| `corporate_ownership` | `OWN000005`: Marcus Bennett holds 15% direct, `VERIFIED` | **15.00% effective** direct interest |
| `related_parties` | Jonah, Oscar, Priya and Marcus are `INDIVIDUAL`; intermediary is `CORPORATE` | These are proposed natural-person ultimate owners; verification/control checks remain |
| `customer_documents` | `DOC0003231` incorporation certificate VERIFIED; `DOC0003232`–`DOC0003235` MISSING | Address, director ID, ownership declaration and source-of-funds evidence are not received |
| `information_requests` | `REQ000071`: UBO_DECLARATION OPEN; requested 2026-11-05; due 2026-11-12 | Evidence collection is ongoing; do not treat declaration as received |
| `screening_runs` | `RUN0001201` completed, potential_hit_count 0 | Customer-level run has no hits; no basis to assert separate owner screening completed |
| `customer_risk_assessments` | `RA001201`: HIGH; 3.545; EDD YES; assessment DRAFT | Enhanced review is flagged, but risk assessment not final |
| `case_checklist` | Ownership/UBO, identity, document verification, risk assessment, QC approval OPEN | Mandatory workflow not yet fully complete |
| `qc_reviews`, `case_approvals`, `escalations` | No case rows in the source snapshot | No recorded final approval/escalation in source; this doesn't mean the gaps can be ignored |

## 3. Calculation and reconciliation

- Jonah Carter: `55 × 65 / 100 = 35.75%`.
- Oscar Bennett: `55 × 35 / 100 = 19.25%`.
- Priya Mercer: direct 30.00%.
- Marcus Bennett: direct 15.00%.
- **Total: `35.75 + 19.25 + 30 + 15 = 100.00%`.**

This is an internally consistent **economic ownership calculation**, **not** conclusive verification. A fully reconciled 100% ownership map cannot substitute for source documents, control checks, nominee analysis, effective-date review or approval.

## 4. Gaps and contradictory assumptions to avoid

1. **Unverified 55% link** — Obtain current credible register/declaration and validate intermediary's stake, controlling persons and effective dates.
2. **Four missing documents** — Address proof, director ID, ownership declaration and source-of-funds evidence need follow-up, not just the UBO declaration.
3. **Owner-level screening** — A customer-level run with zero hits does not prove each natural-person owner and intermediary was screened; confirm scope before stating control COMPLETE.
4. **Triggered change not proven** — The scenario records `OWNERSHIP_CHANGE`, but the stored shareholding effective dates predate the case. Request a before/after ownership explanation and supporting evidence.
5. **Risk methodology** — 3.545 / HIGH / EDD YES is an illustrative project model, not Citi's internal scoring or a final approval.

## 5. Proposed analyst recommendation

Maintain case status **PENDING_INFORMATION** and retain HIGH operational priority. Follow up with RM `USR023` on open request `REQ000071`, obtain a current ownership chart and documentary confirmation of the 55% intermediary link, and receive the four missing case documents. Verify natural-person identity, control/voting rights and any additional beneficial owners or nominees under applicable policy. Resolve screening/EDD scope, refresh the risk evidence and document the outcome. Submit the case for independent QC/approval only after the required controls are complete. Do not unilaterally close the case or claim a final UBO decision.

## 6. Suggested audit and handoff note

> **TRAINING DRAFT — NOT SAVED TO MY SQL**: Reviewed Northgate Imports event-driven case KYC001201. Reconciled recorded ownership to Jonah Carter 35.75% indirect, Priya Mercer 30% direct, Oscar Bennett 19.25% indirect and Marcus Bennett 15% direct. The 55% stake of intermediary PTY00001 is pending verification, so indirect holdings and final UBO determination remain provisional. Request REQ000071 for UBO declaration is OPEN; four case documents remain MISSING. Recorded risk assessment is HIGH/3.545/EDD YES/DRAFT. Recommend obtaining up-to-date ownership and documentary evidence, completing applicable owner-screening/control checks, and retaining PENDING_INFORMATION until review and QC requirements are satisfied.

## 7. Interview outcome statement

The important conclusion is **not** merely “two people exceed 25%.” It is: “I followed corporate-to-corporate ownership through a second layer, calculated the effective stakes, recognized the unverified parent link, distinguished ownership from control and recommended an evidence-driven hold rather than premature approval.”
