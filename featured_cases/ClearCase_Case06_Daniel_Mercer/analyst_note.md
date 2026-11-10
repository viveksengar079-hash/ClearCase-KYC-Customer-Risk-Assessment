# Analyst Investigation Note — Case 06: Daniel Mercer

**Case:** `KYC000002` | **Customer:** `CUS00002` (Daniel Mercer)  
**Review:** ONBOARDING / NEW_TO_BANK | **Priority:** HIGH | **Case status:** IN_REVIEW  
**Analyst perspective:** Training simulation; independent review of existing CSV evidence, not a new bank disposition.

## Reason for review

An onboarding screening run produced one potential sanctions candidate with an exact name match (score 91). Determine whether the fictional watchlist record represents the onboarding customer, and whether the overall case can proceed.

## Evidence reviewed

Customer Daniel Mercer (`CUS00002`) has recorded DOB **22 August 1967**, country `GB`. The fictional sanctions-list candidate `WL00002` has the same name and country but DOB **9 May 1955**. Screening run `RUN0000002` and hit `HIT0000002` record match basis `EXACT_NAME_DIFFERENT_DOB`, identity assessment `FALSE_POSITIVE`, analyst disposition `CLEARED_FALSE_POSITIVE`, reviewed **12 October 2026** by `USR004`. Existing rationale explicitly states that name similarity alone is insufficient and identifiers do not corroborate the record. The associated sanctions designation is a simulated `ACTIVE` listing, not a real listing or a designation of this customer. Both identity and address documents are marked `VERIFIED`.

## Assessment and reasoning

The substantial DOB discrepancy supports the **recorded false-positive screening disposition** despite the high name-similarity score. The score is not a probability of sanctions involvement. However, the current overall KYC case remains `IN_REVIEW`. The customer risk assessment is `MEDIUM` (2.8955), EDD `NO`, status `DRAFT`. The mandatory risk assessment and QC-approval checklist controls are `OPEN`; neither QC nor approval records are present in the original snapshot. An inconsistency in screening checklist completion timing relative to the later hit review merits validation of the workflow definition.

## Recommended action / handoff

Retain the documented screening clearance **subject to review of actual source identity evidence and authorized workflow**, and retain supporting comparison records. Complete the customer risk assessment, resolve outstanding case controls, obtain required QC/approvals, and keep onboarding incomplete until authorization. Do not approve onboarding merely because the screening hit was cleared. Reassess if new conflicting identity evidence or new screening information is found.

**Decision ownership:** The synthetic dataset already records the hit as `CLEARED_FALSE_POSITIVE`. This note does **not** claim an independent live sanctions clearance, a completed case, or an authorized bank approval.
