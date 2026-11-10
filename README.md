# ClearCase — KYC Customer Risk Assessment & Investigation System

**A practical AML/KYC operations portfolio project built using MySQL, Python, pandas and Streamlit.**

> **Disclaimer:** ClearCase is an independent educational simulation using **fictional customers, screening records and case data**. It is not affiliated with Citi or another financial institution, and it does not implement a bank's production compliance policy.

## Project overview

ClearCase simulates the work of a KYC (Know Your Customer) analyst: examining customer information, investigating screening hits, checking documents, assessing customer risk, following up on missing information, documenting decisions and escalating unresolved cases for authorized review.

The project emphasizes **analyst reasoning, evidence documentation and auditability**, rather than machine-learning predictions.

**Baseline synthetic dataset:**

| Metric | Value |
|---|---:|
| Customers | 1,200 |
| KYC cases | 1,630 |
| Completed cases in baseline snapshot | 1,259 |
| Featured investigation case studies | 11 |

These are snapshot figures, not live dashboard metrics. Values can change if training records are updated.

## Tools and technologies

| Tool | How it is used |
|---|---|
| **MySQL / MySQL Workbench** | Relational data storage, joins, evidence queries and case analysis |
| **Python** | Data retrieval, investigation and application logic |
| **pandas** | Organizing and examining query results as DataFrames |
| **mysql.connector / SQLAlchemy** | Connecting Python to MySQL |
| **Jupyter notebooks (VS Code)** | Exploratory data analysis and verification |
| **Streamlit** | Interactive analyst interface |
| **GitHub / Markdown** | Investigation documentation and project presentation |

## Application features

- **Customer Search:** Find customers and inspect their KYC cases.
- **Case Investigation:** Review customer documents, open information requests, screening evidence, risk assessments and risk factors.
- **Analyst Notes and Audit Trail:** Record case notes in the training database, with corresponding audit events.
- **Training Information Requests:** Close **only** synthetic requests whose IDs begin with `REQ_TEST_`. Original source requests remain protected from this demonstration workflow.
- **Global Case Management:** Browse and filter cases across the baseline dataset.
- **Approvals & QC:** View quality-control outcomes, approvals and escalations.
- **Reports & Dashboard:** Monitor operational case totals and overdue work.

**Scope of interaction:** The application is a local training prototype. Entered analyst IDs are not user authentication, and the interface is not a production-grade approval or access-control system.

## How an investigation is performed

1. Identify the customer, review type, case status, priority and due date.
2. Inspect identification documents and any missing or expired evidence.
3. Examine sanctions, PEP (Politically Exposed Person) and adverse-media records where relevant.
4. Review the Customer Risk Assessment (CRA), including the contributing risk factors.
5. Record verified facts separately from unresolved questions and assumptions.
6. Recommend a documented next step: information request, continued review, escalation or authorized approval routing.
7. Preserve the analyst note and supporting audit trail.

A screening match is **not** proof of wrongdoing. A risk score does **not** override mandatory screening or approval controls.

## Eleven featured KYC investigations

Each case folder contains `README.md`, `analyst_note.md`, `evidence_queries.sql` and `interview_prep.md`.


## Featured KYC Investigation Case Studies

| No. | Case Study | Investigation Focus |
|---|---|---|
| 01 | [Alice Bennett](featured_cases/ClearCase_Case01_Alice_Bennett/README.md) | Expired identity document and periodic KYC review |
| 02 | [Sofia Walker](featured_cases/ClearCase_Case02_Sofia_Walker/README.md) | PEP screening and enhanced due diligence |
| 03 | [Owen Ashford](featured_cases/ClearCase_Case03_Owen_Ashford/README.md) | Potential sanctions match investigation |
| 04 | [Northgate Imports](featured_cases/ClearCase_Case04_Northgate_Imports/README.md) | Layered ownership and UBO identification |
| 05 | [Riverbend Ventures](featured_cases/ClearCase_Case05_Riverbend_Ventures/README.md) | Adverse media investigation |
| 06 | [Daniel Mercer](featured_cases/ClearCase_Case06_Daniel_Mercer/README.md) | False positive sanctions screening |
| 07 | [Crestline Manufacturing](featured_cases/ClearCase_Case07_crestline_manufacturing/README.md) | Event-driven ownership change review |
| 08 | [Samuel Whitmore](featured_cases/ClearCase_Case08_samuel_whitmore/README.md) | Fuzzy name and alias screening |
| 09 | [Iris Marshall](featured_cases/ClearCase_Case09_Iris_Marshall/README.md) | PEP and close-associate investigation |
| 10 | [Harborview Consulting](featured_cases/ClearCase_Case10_Harborview_Consulting/README.md) | QC rework and investigation documentation |
| 11 | [Trident Infrastructure](featured_cases/ClearCase_Case11_Trident_Infrastructure/README.md) | Enhanced due diligence and source of wealth |


**Evidence standard:** These investigations are based on the supplied synthetic dataset. Re-run the SQL checks against the current local MySQL database before treating outputs as final, particularly if training notes or requests were added.

## Application architecture

```text
Synthetic KYC data in MySQL
          |
          v
app/helper.py — SQL queries and controlled data operations
          |
          v
pandas DataFrames
          |
          v
app/app.py — Streamlit user interface
          |
          v
Analyst investigation, notes and audit trail
```

## Project structure

```text
KYC_Customer_Risk_Assessment/
├── app/                 # Streamlit app and database helper functions
├── data/                # Synthetic project datasets
├── featured_cases/      # Eleven documented investigations
├── notebooks/           # Python/Jupyter investigation notebooks
├── screenshots/         # Application screenshots (add before publishing)
├── sql/                 # MySQL schema, loading and analysis scripts
├── streamlit/           # Existing project configuration/support folder
├── .gitignore           # Prevents secrets and local-only files from being committed
└── README.md            # Main project introduction
```

Local-only folders such as `.venv/` and secrets such as `.env` are deliberately omitted from the public structure.

## Running the app locally

Prerequisites: a working Python environment, the ClearCase MySQL schema and synthetic data loaded locally, and database connection settings configured privately.

Open a terminal in the project root and run:

```cmd
.venv\Scripts\python.exe -m streamlit run app\app.py
```

This command starts the **local** Streamlit application. A public deployment, downloadable demo database and one-command environment setup have **not** been established by this README.

## Limitations and responsible use

- The dataset contains fictional identities and simulated watchlist, PEP and adverse-media findings.
- Customer-risk scoring and investigation procedures are illustrative, not real bank policies.
- The prototype does not provide production-grade authentication, role-based access, maker-checker enforcement or regulatory decision-making.
- The application restricts demonstration request closures to `REQ_TEST_` records; original information requests must not be represented as closed without evidence.
- No Suspicious Activity Report / Suspicious Transaction Report is generated automatically, and the program does not determine legal sanctions status.
- Screenshots and documented SQL findings should be verified before public publication.

## What this project demonstrates

A portfolio demonstration of **KYC case investigation, sanctions/PEP screening review, beneficial ownership analysis, adverse-media evaluation, customer risk assessment, escalation reasoning, documentation, SQL evidence retrieval and a Python–MySQL–Streamlit workflow**.

---

*Educational portfolio project — fictional data only.*
