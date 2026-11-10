# ClearCase KYC — Featured Investigation 05
## Riverbend Ventures: adverse media involving a company director

> **Scope and provenance.** This case is entirely synthetic and was reconstructed from `ClearCase_KYC_Citi_Analyst_Project_Complete_Datasets.zip`, the project's original source snapshot (2026-11-05), and the existing analyst SQL work. **No real person or company is accused of any crime.** The fictional article has no public URL, and its publisher/source ratings are training fields, not independently verified evidence. This is an L2-style portfolio exercise, not work performed for a bank or a statement of Citi policy. **Publication status: evidence-review draft; compare results with your current MySQL database before publishing.**

## Investigation question

A periodic KYC review for Riverbend Ventures has an adverse-media alert related to its **verified managing director**. The fictional article concerns alleged procurement fraud at an **INVESTIGATION** stage. The alert links to the named director but is rated **LOW relevance**, **MEDIUM source reliability**, and **ESCALATED**. How should a KYC analyst interpret these different fields, handle the unresolved escalation, and determine what additional evidence is needed?

## Case overview (source snapshot)

| Item | Recorded value |
|---|---|
| Customer / ID | **Riverbend Ventures** / `CUS00005` |
| Customer type / country / industry | `CORPORATE` / GB / Wholesale |
| Case / scenario | `KYC001202` / `SC05` |
| Review type / trigger | `PERIODIC` / `HIGH_RISK_REVIEW` |
| Case status / priority / complexity | `ESCALATED` / HIGH / COMPLEX |
| Opened / due | 2026-10-31 / **2026-11-21** (not overdue on 2026-11-10) |
| Assigned analyst / RM | `USR011` / `USR023` |
| Adverse-media alert | `AMA000149`, linked to article `AM00001` |
| Screened director | **Lily Clarke**, `PTY00006`; verified Managing Director (`DIR00003`) |
| Adverse-media identity match | `CONFIRMED_IDENTITY` (synthetic identity association) |
| Alert relevance / source reliability | **LOW / MEDIUM** |
| Alert investigation status | `ESCALATED` |
| Compliance escalation | `ESC000048` / `ADVERSE_MEDIA` / `OPEN`, decision: Pending compliance review |
| Risk assessment | `RA001202`: **HIGH**, score **3.579**, `EDD_REQUIRED=YES`, `DRAFT` |
| Final QC / approval / disposition | None recorded for this case in source snapshot |

## Linked director and fictional article

| Evidence | Source record | What it establishes / does not establish |
|---|---|---|
| Director link | `customer_directors.DIR00003`, customer `CUS00005`, party `PTY00006` | Lily Clarke is the verified Managing Director in the **synthetic corporate relationship table**. Verification of the directorship is not evidence of misconduct. |
| Party master | `related_parties.PTY00006` | Lily Clarke is an individual, country GB, active in simulated data. |
| Media-alert link | `adverse_media_alerts.AMA000149` | Screening subject type PARTY, ID PTY00006; confirmed identity association, LOW relevance, MEDIUM reliability, status ESCALATED. |
| Article | `adverse_media_articles.AM00001` | Fictional headline: **“Fictional procurement fraud allegations involving a corporate director”**. Publisher **Demo Investigative Desk**, published 2026-09-16. |
| Event stage | `AM00001` | `INVESTIGATION`, category `FRAUD`, credibility tier `MEDIUM`; **not a conviction or proven fraud**. |
| Fictionality | `is_synthetic=YES`; no `public_url` | No independent real-world source is available to authenticate. Do not claim external corroboration. |
| Subject relationship | `adverse_media_subjects.AMS00334` | Article identifies party PTY00006 as `DIRECTOR_NAMED_SUBJECT`; article also has unrelated training subject links. Do not assume all linked subjects are the same customer. |
| Compliance escalation | `ESC000048` | Open adverse-media review; `decision_summary='Pending compliance review'`. Not a final compliance finding. |

## A useful analytical contradiction — and why it matters

The three assessments describe **different dimensions**, and may reasonably coexist:

- **`CONFIRMED_IDENTITY`** says the simulated matching subject is the same person named in the alert. It **does not** confirm that the alleged fraud is true.
- **`LOW` relevance** indicates the alert's assessed materiality/relevance to the KYC decision is limited. A materiality rationale is not shown in the record; do **not** invent one.
- **`ESCALATED`** says the matter was referred for further review. Since the article is only at `INVESTIGATION` stage and reliability is `MEDIUM`, the final decision should explain why escalation was appropriate despite LOW relevance and whether corroboration changes the assessment.

**Source-quality limitation:** the synthetic article's text is generic; it provides no identifiable real case, original regulatory record, court reference, or independent URL. The role-link is recorded in the training data, but the assertion cannot be externally validated. An analyst should seek legitimate corroboration in a real case, not pretend a fictional article is evidence of wrongdoing.

## Document and operations control findings

| Area | Recorded finding | Analyst implication |
|---|---|---|
| Documents | Incorporation certificate `DOC0003236` **MISSING**, reason `NOT_RECEIVED`; four other case documents VERIFIED | Follow up on missing incorporation evidence independently of adverse-media outcome. |
| Director ID | `DOC0003238` VERIFIED for `PTY00006` | Identification document received/verified, but does not validate the allegation. |
| Sanctions/PEP screening | `RUN0001202` `COMPLETED`, potential-hit count **0** for screened CUSTOMER | Zero customer-level potential hits does not invalidate the separate adverse-media PARTY alert. It also does not prove every associated party was individually screened. |
| Mandatory checklist | Identity, document verification, sanctions/PEP screening, customer risk assessment, EDD review and QC approval **OPEN**; analyst notes and ownership/UBO **COMPLETE** | The case cannot be represented as finalized/approved. A completed ownership checklist is not proof that every other control passed. |
| Risk | Five-factor score **3.579**, HIGH, EDD YES, DRAFT | A teaching-model risk value, not a proof of guilt or final risk acceptance. |
| Information requests | No original request rows for this case in source snapshot | The file has a missing document despite no recorded information request. Recommend initiating a documented follow-up under policy if needed. |
| QC / approvals | No case-level QC, approval or final disposition | No sign-off can be claimed. |

### Risk score reconciliation (original synthetic factors)

| Factor | Value | Weight | Contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 4.14 | 0.20 | 0.8280 |
| GEOGRAPHIC | 1.00 | 0.20 | 0.2000 |
| PRODUCT_CHANNEL | 4.34 | 0.15 | 0.6510 |
| EXPECTED_ACTIVITY | 3.25 | 0.20 | 0.6500 |
| SCREENING_EXPOSURE | 5.00 | 0.25 | 1.2500 |
| **Total** | | **1.00** | **3.5790** |

The `SCREENING_EXPOSURE` factor is weighted 25% in the **synthetic methodology**, not a real institution's policy. The score must not independently decide whether an adverse-media alert is true or whether onboarding/review is approvable.

## Analyst recommendation — simulated, not an actual approval decision

**Retain `ESCALATED` and do not finalize the periodic KYC review** until the open compliance query, missing incorporation certificate and outstanding mandatory controls are resolved. Review the director identity linkage against reliable identifiers; distinguish article allegation from investigation, charge and conviction; establish whether any credible independent sources corroborate the allegation (not possible with this fictional item alone); analyze event timing, severity, case relevance, beneficial ownership/management role, and any current customer activity concerns supported by actual evidence. Ask the compliance reviewer to reconcile the LOW relevance flag with the escalation decision. Record evidence and limits, then complete EDD/checklist and route for independent QC and authorized approval.

**Do not** label Lily Clarke guilty, represent the article as real news, independently override the compliance queue, mark the case approved, or manufacture investigative evidence to make the story stronger.

## Practical workflow in ClearCase Streamlit

1. **Customer Search:** search `CUS00005`, select case `KYC001202`; review customer/profile/case details.
2. **Case Investigation → Documents:** inspect the missing incorporation certificate and four verified records.
3. **Case Investigation → Screening:** understand that the existing `get_case_screening()` function primarily handles screening runs/hits. This media alert lives in `adverse_media_alerts` and is **not yet presented in a dedicated adverse-media tab**. Use the SQL evidence queries to inspect the actual media alert and director linkage.
4. **Case Investigation → Risk Assessment:** verify HIGH / 3.579 / EDD YES / DRAFT and five weighted factors.
5. **Approvals & QC → Escalations:** verify `ESC000048` remains OPEN, with compliance review pending.
6. **Notes & Audit:** review existing notes; draft recommendations in `analyst_note.md` before adding any new training note. If writing one, label it TRAINING ONLY and allow the helper to record its audit event.
7. **Never edit original screening, media, escalation or approval conclusions** to make a demonstration pass.

## Portfolio deliverables

- `README.md` — complete case overview and issues.
- `analyst_note.md` — structured analyst evidence, judgment and handoff.
- `evidence_queries.sql` — read-only MySQL validations; execute each full `SELECT` separately in VS Code.
- `interview_prep.md` — 60-second case narrative, explanations and challenging interview questions.

### Publication validation

Verify Query 04 (article/alert/director), Query 06 (escalation), Query 08 (documents), and Query 12 (weighted risk) against the live MySQL database. These are original CSV-snapshot findings; local user-generated training records may have been added. Avoid publishing fictional names or events as actual adverse media.
