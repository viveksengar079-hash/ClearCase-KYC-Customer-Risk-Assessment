# Case 10 — Harborview Consulting | QC Rework and Maker–Checker Review

**Portfolio:** ClearCase KYC Customer Risk Assessment & Investigation System  
**Customer:** `CUS00010` — Harborview Consulting (fictional corporate entity, HK)  
**Case:** `KYC001206` · **Scenario:** `SC10` · **Review:** PERIODIC · **Priority:** HIGH  
**Case status in source snapshot:** `QC_REWORK` · **Assigned analyst:** `USR002` · **QC checker:** `USR016`  
**Snapshot evidence:** Original synthetic ClearCase CSV dataset (snapshot date 05 November 2026); local MySQL may differ following practice updates.

> **Training simulation, not real bank activity.** All customer details, analysts, QC records and decisions are fabricated. The project and scoring thresholds are educational examples and are **not Citi procedures**. The documents here are a **proposed analyst response**, not a completed remediation or a new database record.

## 1. Executive summary

Harborview Consulting is an existing corporate customer undergoing a periodic KYC review opened **12 October 2026** and due **02 November 2026**. The case is HIGH priority and currently in `QC_REWORK`. On **16 October 2026**, independent checker `USR016` returned the file (`QC000993`) with outcome `RETURNED`, defect code `MISSING_INVESTIGATION_RATIONALE`, and comment **“Record returned for evidence or rationale correction.”** There is no final approval or case disposition for this review.

The central deficiency is the **quality of the investigation reasoning**, not an automatically established missing identity document or confirmed screening match. All five submitted case documents are `VERIFIED`, and the 13 October 2026 screening run completed with **zero potential hits**. The five-factor risk assessment remains `DRAFT`, with HIGH risk, score **3.888** and EDD required (`YES`). The case checklist marks seven steps `COMPLETE`, but `QC_APPROVAL` is still `OPEN`. A separate corporate-registration information request (`REQ000073`) is `OPEN`; it should be reconciled against an existing verified incorporation certificate, without assuming the records are duplicates or that the information gap is resolved.

**Recommended analyst action:** Compare the returned QC defect with the existing case note and supporting evidence; rewrite the missing/weak rationale with traceable document and screening references; resolve or explicitly explain the outstanding corporate-registration request; verify the draft risk and EDD basis; then route the file back to an **independent checker** according to the simulated workflow. Do not mark the original QC outcome `PASS`, assign approval, or close the case without the appropriate review.

## 2. Business context

| Item | Source value |
|---|---|
| Customer | Harborview Consulting, `CUS00010` |
| Customer type / country | CORPORATE / HK |
| Current review | `KYC001206` — PERIODIC, `SCHEDULED_CYCLE` |
| Opened / due | 12 October / 02 November 2026 |
| Case status / complexity | `QC_REWORK` / COMPLEX |
| Case priority | HIGH |
| Maker / checker | `USR002` KYC_ANALYST / `USR016` QC_CHECKER |
| RM | `USR022` |
| Prior customer case | `KYC000010` — completed onboarding (separate historical review) |

A previous completed onboarding case does **not** automatically approve the current periodic review.

## 3. QC defect: what actually failed?

**QC record:** `QC000993`  
**Submitted:** 15 October 2026  
**Checked:** 16 October 2026  
**Outcome:** `RETURNED`  
**Defect:** `MISSING_INVESTIGATION_RATIONALE`  
**Checker note:** “Record returned for evidence or rationale correction.”

The maker's existing 14 October `INVESTIGATION` note is generic: *“Open case requires follow-up for incomplete screening; documentation; approval or risk evidence.”* The note does not specify the supporting records or why the case should be approved, returned, or held. In addition, the available screening run is `COMPLETED` with zero hits, so the statement about incomplete screening requires clarification rather than being repeated uncritically.

**A defensible correction documents** which evidence was examined, whether each item is sufficient, the current risks/gaps, who owns the next step, and why the current recommendation follows from the evidence. The note should not claim actions that the dataset does not show as completed.

## 4. Source evidence: verification and remaining gaps

### Documents

Five documents belong to this review; **all are `VERIFIED`** (verified 14 October by `USR002`):

1. Incorporation certificate — `DOC0003252`
2. Registered address — `DOC0003253`
3. Director identity — `DOC0003254`
4. Ownership declaration — `DOC0003255`
5. Source-of-funds evidence — `DOC0003256`

All five are `VERIFIED` *in the training snapshot*. This does not prove completeness of qualitative investigation rationale or that later requests can be closed.

### Screening

`RUN0001206` was screened on **13 October**, status `COMPLETED`, with `potential_hit_count = 0`. No linked `screening_hits` record exists. Avoid saying “screening was never conducted,” and avoid treating zero hits as universal proof of no risk.

### Risk and EDD

`RA001206` records score **3.888**, rating `HIGH`, EDD `YES`, status `DRAFT`. The five weighted factors reconcile to 3.888 and their weights total 1.00. The `EDD_REVIEW` checklist is marked `COMPLETE`, yet the *overall risk assessment* remains `DRAFT`. The case cannot be called fully approved on that basis.

### Information request

`REQ000073` requests `CORPORATE_REGISTRATION`, raised **14 October**, due **21 October**, status `OPEN`, no response or closure recorded. A verified incorporation certificate already exists. Possible explanations include a request for refreshed evidence, registry corroboration, or an administrative mismatch; **the source data does not identify which is true**. Verify with the RM/checker before closure.

### Checklist and approval

Seven of eight mandatory checklist controls are `COMPLETE`. `QC_APPROVAL` is `OPEN`. The current periodic review has no `case_approvals`, `case_dispositions`, or `escalations` row. A `RETURNED` QC result is not equivalent to a rejected client, final adverse decision, or an escalation.

## 5. Quality concerns to document — do not silently "fix" the data

- **Chronology:** the case audit's `CASE_STATUS` event describes `QC_REWORK` on **14 October**, even though the actual `RETURNED` QC check is dated **16 October**. This sequence is internally inconsistent if the event is meant to record the outcome of that QC review; flag for audit/data-lineage review.
- **Generic analyst note vs screening evidence:** the 14 October note mentions incomplete screening; however the screening run is complete with zero hits. Determine whether the note meant unfinished *analyst rationale* rather than unperformed screening.
- **Open registration request vs verified certificate:** do not assume one cancels the other. Determine the precise missing evidence.
- **DRAFT assessment vs completed checklist:** completion of a control step doesn't automatically finalize/approve a risk assessment.

These are useful portfolio quality findings but must not be portrayed as confirmed real-bank control failures.

## 6. Proposed maker–checker workflow

1. Review `QC000993` and extract the exact missing investigation rationale requirements.
2. Gather the existing case notes, document evidence, screening run, risk assessment and open request; cite identifiers in the revised note.
3. Clarify whether `REQ000073` remains outstanding and what evidence would satisfy it. Obtain/update supporting evidence only through an authorized workflow.
4. Produce a clear revised analyst note **as a draft**, with risk assessment status and EDD needs accurately represented.
5. Explain the audit timing anomaly to the data owner/checker; don't edit synthetic history merely to make it look consistent.
6. When prerequisites are satisfied, resubmit to an independent QC checker. The checker, not the original analyst, decides whether the rework passes. Approval remains a separate decision.
7. Record each **actual** action in the application audit trail; never claim the proposed steps have already happened.

## 7. Example analyst decision

**Disposition recommendation:** `REWORK / HOLD PENDING EVIDENCE AND INDEPENDENT QC`. Do **not** close the periodic case or represent the original QC as `PASS`. A new approval is not demonstrated in the dataset.

## 8. Files and how to use them

| File | Purpose |
|---|---|
| `README.md` | Portfolio story, evidence and limitations |
| `analyst_note.md` | Clear L1/L2-style proposed case note and handoff |
| `evidence_queries.sql` | Read-only, commented MySQL queries; execute one complete statement at a time |
| `interview_prep.md` | Interview narrative and scenario reasoning |

### VS Code / MySQL verification

Open `evidence_queries.sql` in your existing SQL editor against schema `clearcase_kyc`. Execute Queries **03 (QC outcome), 05 (documents), 07 (screening), 10 (request), 12 (risk reconciliation), 16 (audit chronology)**. Check the results match your current local MySQL database before publishing. **Do not run any INSERT, UPDATE or DELETE** for this case study.

### Streamlit walkthrough

From `Case Management`, search `KYC001206`, click **Select Case for Investigation**, then check `Case Investigation` tabs (Documents, Information Requests, Screening, Risk Assessment, Notes & Audit), followed by `Approvals & QC`. The current Streamlit QC page is **read-only**. You may write a clearly marked **TRAINING TEST ONLY** investigation note if you intentionally want to generate a real new local training note and audit event. This Markdown note alone does not modify MySQL.

## 9. Interview-safe boundary

Describe this as: **“I investigated a synthetic QC-rework case in a self-built KYC portfolio application.”** Do not call it a genuine Citi case, real bank employment or a completed checker/approver action. Real institution workflows, permissible actions, evidence standards and SLAs differ.
