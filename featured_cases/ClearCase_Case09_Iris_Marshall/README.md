# Case 09 — Iris Marshall | PEP Classification & Close-Associate Review

**Portfolio:** ClearCase KYC Customer Risk Assessment & Investigation System  
**Customer:** `CUS00009` — Iris Marshall (fictional individual; GB)  
**Case:** `KYC001205` · **Scenario:** `SC09` · **Review:** `PERIODIC` · **Priority:** HIGH  
**Case status:** `PENDING_SCREENING` · **Analyst level:** L2 / escalated compliance review  
**Source:** Original synthetic ClearCase CSV dataset. The local MySQL database may contain later training changes.

> **Educational simulation only.** People, PEP profiles, publishers, list sources, screenings, related parties and decisions are fictional. The PEP/risk model is not Citi policy, a real financial institution's scoring methodology or a verified regulatory database. **Nothing here alleges misconduct by a real person.**

## 1. Executive summary

Iris Marshall is an existing customer undergoing a periodic KYC review (`KYC001205`) opened **23 October 2026**, with a due date of **13 November 2026**. A simulated screening run on **24 October 2026** yielded one potential hit (`HIT0000355`) with match score **99**, matching name, date of birth and country to fictional PEP entry `WL00005`. The hit is recorded as `CONFIRMED_IDENTITY` and `ESCALATED_POTENTIAL_TRUE_MATCH` following review on **26 October 2026**. Case escalation `ESC000049` is `OPEN` and awaiting compliance review.

**Crucial discrepancy:** The training scenario is titled **"Former PEP and related close associate"**, but Iris's actual PEP profile (`PEP00002`) shows `pep_category=FOREIGN`, `pep_status=CURRENT`, position `Minister`, and **no `term_end`**. Do **not** report that Iris herself is a former PEP as a verified finding. The screening source is named *Training Former Officials Register*, but its name does not override the actual profile fields. Her associated entity `WL00293` has a `FORMER` PEP status; this may help explain how the case-title mismatch arose, but it does **not** resolve it.

**Recommendation (proposed; not executed):** Keep `PENDING_SCREENING` / `ESC000049 OPEN`; independently validate the current/historical PEP position and dates, assess associated relationships, complete the required EDD and approved risk assessment, and obtain authorized compliance/QC clearance before closing the periodic review. The confirmed identity match is **not** a finding of illegal activity or a sanctions designation.

## 2. Evidence register — recorded facts versus meaning

| Topic | Original-source finding | Analyst interpretation |
|---|---|---|
| Identity | `CUS00009`, Iris Marshall; GB; DOB `1988-07-23`; existing ACTIVE individual | Supports matching to `WL00005`; identity validity must be grounded in genuine KYC documentation in a real workflow |
| Current case | `KYC001205`, PERIODIC, `PENDING_SCREENING`, HIGH; `2026-10-23` opened, due `2026-11-13`; assigned `USR009` | An active periodic-review case, separate from historical onboarding |
| Historical case | `KYC000009`, ONBOARDING, COMPLETED | Prior onboarding does not resolve the newer PEP finding |
| Screening run | `RUN0001205`, `2026-10-24`, COMPLETED, potential_hit_count **1** | Technical screening executed; analyst/compliance disposition not finalized |
| Screening hit | `HIT0000355`, match score **99**, `EXACT_NAME_AND_IDENTIFIERS` | Strong candidate identity match; score is not probability of crime |
| Identity / disposition | `CONFIRMED_IDENTITY`, `ESCALATED_POTENTIAL_TRUE_MATCH`, reviewed `2026-10-26` by `USR009` | Matching identity accepted in the synthetic record; compliance review remains open |
| Watchlist subject | `WL00005` Iris Marshall, GB, `1988-07-23`, PEP, ACTIVE | **PEP category, not sanctions**; training-source data only |
| Source | `SRC05`, "Training Former Officials Register", synthetic | A source *name* does not prove former status or official/current coverage |
| PEP profile | `PEP00002`, `FOREIGN`, `Minister`, `CURRENT`, term_start `2012-10-31`, no term_end | **Contradicts "Former PEP" scenario title**; current status requires verification |
| Recorded close associate | `WLR00055`: Iris (`WL00005`) → Gabriel Graham (`WL00025`), `CLOSE_ASSOCIATE`, known_from `2019-08-12`, no end date | Recorded relationship requiring verification of nature, duration and risk; no criminal inference |
| Recorded business associate | `WLR00106`: Leo Marshall (`WL00293`) → Iris (`WL00005`), `BUSINESS_ASSOCIATE`, known_from `2018-04-04`, no end date | Direction preserved. No family link or beneficial ownership proven by this record alone |
| Other PEP profiles | Gabriel Graham: INTERNATIONAL_ORGANIZATION, CURRENT. Leo Marshall: RCA, FORMER | These are counterpart *profile* fields, not proof Iris is former |
| Case escalation | `ESC000049`, type `PEP_EDD`, OPEN, raised `2026-10-26`, assigned `USR026` | Pending compliance review; do not treat as approved or resolved |
| KYC documents | Identity, address and source-of-funds documents all VERIFIED | KYC documents not the immediate blocker; PEP/EDD controls remain open |
| Open mandatory controls | SANCTIONS_PEP_SCREENING, CUSTOMER_RISK_ASSESSMENT, EDD_REVIEW, QC_APPROVAL | Review should not be closed while these mandatory steps are outstanding |
| Risk assessment | HIGH `3.446`, EDD YES, DRAFT (`SIM_V1_5_FACTOR_WEIGHTED`) | Synthetic assessment not final signoff; score is not equivalent to authorization |
| Adverse media | Alert `AMA000150`, FALSE_POSITIVE, LOW relevance, MEDIUM reliability, CLEARED; fictional article `AM00002` at DISMISSED stage | Not an unresolved criminal allegation; distinct from the PEP hit |
| QA / approval | No `qc_reviews` / `case_approvals` row for this case | No recorded independent QC or approval for this review in original data |
| Information requests | No request for `KYC001205` in original snapshot | Do not invent a customer-doc request; open compliance escalation is a separate mechanism |

### Data-quality warning: "former" versus "current"

Do not silently replace the recorded `CURRENT` PEP status with `FORMER` based on the scenario name or the reference list's branding. The case source is *internally inconsistent*: the profile says `FOREIGN/CURRENT` and the position field says `Minister` at a fictional state-owned enterprise. The file does not provide a verifiable public appointment history. Investigators should record these as **source-data issues requiring corroboration**, not invent a political office or date of departure.

A second temporal issue: the screening run's `source_snapshot_at` is **24 October 2026**, and the hit review was **26 October 2026**, yet both the source's metadata `snapshot_date` and the watchlist entity's `last_updated` are **31 October 2026**. This may reflect a later export, but it does not establish that this exact October 31 source record existed in the October 24 run.

## 3. Relationship evidence — do not assume familial ties

```text
                           Iris Marshall (WL00005)
                           FOREIGN / CURRENT PEP
                           matched customer CUS00009
                                    |
             +----------------------+----------------------+
             |                                             |
    WLR00055 (outgoing)                          WLR00106 (incoming)
    CLOSE_ASSOCIATE                               BUSINESS_ASSOCIATE
             |                                             |
     Gabriel Graham                               Leo Marshall
         WL00025                                    WL00293
  INTERNATIONAL_ORGANIZATION                      RCA / FORMER
          CURRENT                                   (profile)
```

- `WLR00055`: record direction **Iris → Gabriel**, `CLOSE_ASSOCIATE`, since `2019-08-12`.
- `WLR00106`: record direction **Leo → Iris**, `BUSINESS_ASSOCIATE`, since `2018-04-04`.
- No end date is recorded for either relationship. This is **not proof** that the association remains active in the real world.
- The surname "Marshall" does **not** justify calling Leo a family member. No `FAMILY_MEMBER` relationship is recorded between Iris and Leo in these entries.
- Assess whether associated people/entities create additional risk or should be screened, applying the relevant institution's documented policy, not making assumptions from labels.

## 4. Five-factor synthetic risk model

| Risk factor | Factor value | Weight | Weighted contribution |
|---|---:|---:|---:|
| CUSTOMER_PROFILE | 3.84 | 0.20 | 0.7680 |
| GEOGRAPHIC | 1.00 | 0.20 | 0.2000 |
| PRODUCT_CHANNEL | 3.40 | 0.15 | 0.5100 |
| EXPECTED_ACTIVITY | 3.59 | 0.20 | 0.7180 |
| SCREENING_EXPOSURE | 5.00 | 0.25 | 1.2500 |
| **Total** | — | **1.00** | **3.4460** |

The synthetic rating is HIGH with EDD YES and DRAFT status. SCREENING_EXPOSURE's 25% weight yields 1.25 of the 3.446 total points. These weights are **illustrative**. Neither a risk rating nor a score replaces specific PEP due-diligence, independent approval or sanctions controls that apply under the bank's actual policy and jurisdiction.

## 5. Practical L1/L2 investigation workflow

1. **Confirm the selected case.** Search `CUS00009` and select periodic-review case `KYC001205`, not earlier onboarding `KYC000009`.
2. **Trace the hit to the source.** Confirm `RUN0001205`, `HIT0000355`, `WL00005`, `SRC05`, matching identifiers and actual analyst disposition. Remember screening run `COMPLETED` does not equal case clearance.
3. **Reconcile the PEP classification.** Record the scenario's "former" wording against the detailed profile's `FOREIGN/CURRENT` and blank end date; request authoritative, dated evidence if this were a real case.
4. **Review recorded associates.** Inspect both relationship directions, counterpart PEP profiles and relationship provenance. Do not infer family or an ongoing business tie without evidence.
5. **Assess EDD completeness.** Consider position, source of funds/wealth, purpose/expected activity and relationship risks according to governing policy. The source lists employment income/business ownership, but no full independent wealth verification package is supplied in this snapshot.
6. **Treat adverse media separately.** The recorded negative-news alert was cleared as a false positive and the fictional article is at DISMISSED stage. Do not describe it as an unresolved proven allegation.
7. **Maintain escalation.** Preserve `ESC000049 OPEN`; verify assigned queue/decision owner and the minimum information required for a substantive compliance decision.
8. **Resolve mandatory controls.** Customer identity and documents are COMPLETE, but screening, risk assessment, EDD review and QC approval remain OPEN. Do not mark any as passed without actual evidence and authority.
9. **Document findings clearly.** Keep verified facts, apparent inconsistencies, additional checks, and proposed action separate. A recommendation is not a completed workflow action.

## 6. Why this case is useful in interviews

This case tests whether the analyst can resist a plausible but **wrong** label. A strong answer says: "The case guide describes a former PEP, but the detailed profile says CURRENT FOREIGN PEP with no term end. I cannot reconcile that from the source alone. I would preserve the open escalation and verify the current/historical position, then assess relationships and EDD under policy." That is stronger than asserting a fictional case title as fact.

## 7. Reproduction and evidence files

Use `evidence_queries.sql` to verify 21 read-only queries. Execute complete statements through their semicolons. Start with Query **04** (screening evidence), **06** (actual PEP profile), **07–08** (associates), **10** (open controls), **13** (risk reconciliation), **14** (escalation), and **20** (reference timing).

Open your Streamlit app **Customer Search → CUS00009 → KYC001205 → Case Investigation**, then review Screening and Risk Assessment. Open **Approvals & QC → Escalations**. The current Streamlit screening panel may not yet show the full PEP biography or relationship graph; the SQL evidence supplements that app view.

**Do not alter the source customer, screening disposition, PEP status, escalation or QC fields just to create an attractive portfolio screenshot.** Save a training note only if it is accurate, clearly identified as a simulation, and warranted by the exercise.

## 8. Honest portfolio disclosure

This is a **synthetic, educational investigation**, not a real customer file, official World-Check/LexisNexis screening or operational work performed at Citi. It supports practical KYC workflow demonstrations only. Before GitHub upload: verify MySQL against the original snapshot, redact `.env` and credentials, and distinguish simulated recommendations from existing decisions.
