# Case 10 — Proposed Analyst Investigation Note

**Training environment:** ClearCase KYC — synthetic portfolio case, not a production record  
**Customer:** Harborview Consulting (`CUS00010`)  
**Current case:** `KYC001206` · PERIODIC · HIGH priority · `QC_REWORK`  
**Analyst:** `USR002` (recorded maker; training ID)  
**Checker:** `USR016` (independent training QC checker)  
**Draft status:** Proposed analytical note; **not yet posted to MySQL**  
**Evidence source:** Original synthetic ClearCase CSV snapshot dated 05 November 2026; validate against local MySQL.

## A. Referral and issue

The periodic KYC review for Harborview Consulting was returned by independent QC review `QC000993` on 16 October 2026. The outcome is `RETURNED`, with defect `MISSING_INVESTIGATION_RATIONALE` and checker comment “Record returned for evidence or rationale correction.” The case is recorded as `QC_REWORK`, not completed or approved. The required analyst response is to make the existing investigation evidence and decision rationale clear, address unresolved information, and resubmit for independent verification when ready.

## B. Customer and case profile

Harborview Consulting is a fictional active HK corporate customer. The current review was opened 12 October 2026, is HIGH priority, assigned to `USR002`, and was due 02 November 2026. Its original onboarding (`KYC000010`) was completed historically but is not an approval of this new periodic review. The current assessment is `RA001206`: HIGH risk, score **3.888**, EDD `YES`, status `DRAFT`.

## C. Evidence examined

- **QC:** `QC000993` submitted 15 October, checked 16 October; defect `MISSING_INVESTIGATION_RATIONALE`; checker `USR016`.
- **Documents:** `DOC0003252` to `DOC0003256`—incorporation certificate, address evidence, director ID, ownership declaration, source-of-funds evidence—all `VERIFIED` on 14 October. The records do not show a missing verification status for these documents.
- **Screening:** `RUN0001206` completed on 13 October with **zero potential hits**; no linked screening-hit record. This does not resolve the QC rationale defect.
- **Checklist:** 7 of 8 mandatory steps `COMPLETE`; `QC_APPROVAL` remains `OPEN`.
- **Risk:** five factors (0.20, 0.20, 0.15, 0.20, 0.25) give a total weighted score **3.888**; EDD requirement YES but assessment DRAFT. `EDD_REVIEW` checklist says COMPLETE; assess whether the supporting EDD rationale is adequate.
- **Information request:** `REQ000073` (`CORPORATE_REGISTRATION`) remains OPEN; requested 14 October and due 21 October, with no response. Although `DOC0003252` is verified, this alone does not explain or close the request.
- **Decisions/escalations:** no case approval, final disposition or compliance escalation recorded for this periodic review. QC return is not a final adverse client decision.
- **Notes:** existing `INVESTIGATION` note `NOTE0002395` is generic and mentions incomplete screening; that wording conflicts with a completed screening run and needs evidence-based clarification.

## D. Findings and quality exceptions

1. **Primary QC defect:** weak/missing analytical reasoning, as explicitly recorded by the checker. A new note should identify evidence, remaining gaps, conclusions and next actions, rather than just asserting that checks were done.
2. **Outstanding request:** verify precisely what `CORPORATE_REGISTRATION` information is missing; do not infer it is satisfied by a verified incorporation certificate.
3. **Risk/EDD:** high risk with EDD YES and DRAFT assessment requires the recorded control decision to be reviewed before case closure.
4. **Audit chronology anomaly:** audit event `EVT0005088` dates the shift to `QC_REWORK` to 14 October, although QC return `QC000993` occurred on 16 October. Flag the inconsistency rather than rewrite historical entries.
5. **Maker-checker independence:** the maker can correct and resubmit; the checker/approver must independently determine QC outcome and approval.

## E. Recommended disposition and actions

**Recommended status:** retain `QC_REWORK` while the rationale and open request are addressed. Prepare a revised note linking each conclusion to document IDs, screening run, risk factors and QC feedback. Ask the RM (`USR022`) for clarification/response to `REQ000073` and the checker/data owner for clarification of the audit chronology. When all necessary evidence is in place, resubmit through an authorized independent QC process. Do **not** self-approve, change the original `RETURNED` outcome, invent a response, or mark the review `COMPLETED`.

## F. Short proposed updated rationale (not an executed action)

> Training draft: I reviewed the five verified corporate KYC documents (`DOC0003252`–`DOC0003256`) and screening run `RUN0001206` (COMPLETED, 0 potential hits). The customer's current HIGH risk score of 3.888 requires EDD; risk assessment `RA001206` remains DRAFT. The file was returned by QC (`QC000993`) because the investigation rationale was incomplete. Request `REQ000073` for corporate registration remains OPEN despite the existing verified incorporation certificate; the specific outstanding evidence requires RM confirmation. I recommend retaining QC_REWORK until the missing rationale is fully documented, the information request is resolved or appropriately justified, and the case is resubmitted for independent QC and any required approval. I also flag a case-status audit timestamp preceding the QC return for audit-lineage review.

## G. Boundaries and handoff

This is an **analyst recommendation**, not an authorized QC re-review or case-status update. It does not claim to have obtained a new registration document, closed a request, finalized EDD, or changed an approval decision. In interviews, clearly identify all evidence as fictional and all steps as proposed training workflow actions.
