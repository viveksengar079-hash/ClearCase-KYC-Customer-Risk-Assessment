
# CLEARCASE KYC INVESTIGATION SYSTEM
# PHASE 6 - APPROVALS AND QC INTEGRATION

import streamlit as st
import pandas as pd
from datetime import date
import helper


# 1. WEBPAGE SETTINGS

st.set_page_config(
    page_title="ClearCase KYC",
    page_icon="🔎",
    layout="wide"
)


# 2. SESSION STATE

if "searched_customer_id" not in st.session_state:
    st.session_state.searched_customer_id = ""

if "selected_case_id" not in st.session_state:
    st.session_state.selected_case_id = ""


# 3. SIDEBAR

st.sidebar.title("ClearCase KYC")

page = st.sidebar.radio(
    "Navigation",
    [
        "Customer Search",
        "Case Investigation",
        "Case Management",
        "Approvals & QC",
        "Reports & Dashboard",
        "Audit Trail"
    ]
)


# 4. APPLICATION HEADING

st.title("ClearCase KYC Investigation System")
st.caption("AML/KYC Portfolio Project | Synthetic Customer Data")


# 5. CUSTOMER SEARCH

if page == "Customer Search":

    st.subheader("Customer Search")

    customer_id = st.text_input(
        "Enter Customer ID",
        value=st.session_state.searched_customer_id or "CUS00006"
    )

    if st.button("Search Customer"):
        st.session_state.searched_customer_id = customer_id.strip()
        st.session_state.selected_case_id = ""

    if st.session_state.searched_customer_id:

        customer = helper.get_customer(
            st.session_state.searched_customer_id
        )

        if customer.empty:
            st.error("Customer not found.")

        else:
            st.success("Customer found!")

            st.subheader("Customer Profile")

            st.write("Name:", customer.iloc[0]["legal_name"])
            st.write("Type:", customer.iloc[0]["customer_type"])

            st.dataframe(customer, hide_index=True)

            st.subheader("KYC Case History")

            cases = helper.get_customer_cases(
                st.session_state.searched_customer_id
            )

            if cases.empty:
                st.info("No KYC cases found.")

            else:
                st.dataframe(cases, hide_index=True)

                case_options = cases["case_id"].tolist()

                if st.session_state.selected_case_id in case_options:
                    selected_index = case_options.index(
                        st.session_state.selected_case_id
                    )
                else:
                    selected_index = 0

                selected_case = st.selectbox(
                    "Select a KYC Case",
                    case_options,
                    index=selected_index
                )

                st.session_state.selected_case_id = selected_case

                st.info(
                    "Open Case Investigation from the sidebar."
                )


# 6. CASE INVESTIGATION

elif page == "Case Investigation":

    st.subheader("Case Investigation")

    case_id = st.session_state.selected_case_id
    customer_id = st.session_state.searched_customer_id

    if not case_id or not customer_id:

        st.info(
            "Select a case from Customer Search "
            "or Case Management first."
        )

    else:

        customer = helper.get_customer(customer_id)
        cases = helper.get_customer_cases(customer_id)

        case_details = cases[
            cases["case_id"] == case_id
        ]

        if customer.empty or case_details.empty:

            st.error("Selected customer or case not found.")

        else:

            # 7. CUSTOMER AND CASE SUMMARY

            st.subheader(customer.iloc[0]["legal_name"])

            st.write("Customer ID:", customer_id)
            st.write("Case ID:", case_id)

            st.dataframe(case_details, hide_index=True)


            # 8. INVESTIGATION TABS

            tab1, tab2, tab3, tab4, tab5 = st.tabs(
                [
                    "Documents",
                    "Information Requests",
                    "Screening",
                    "Risk Assessment",
                    "Notes & Audit"
                ]
            )


            # 9. DOCUMENT VERIFICATION

            with tab1:

                st.subheader("KYC Documents")

                documents = helper.get_case_documents(case_id)

                if documents.empty:
                    st.info("No documents found.")

                else:
                    st.dataframe(documents, hide_index=True)

                    expired = documents[
                        documents["verification_status"] == "EXPIRED"
                    ]

                    if not expired.empty:
                        st.warning(
                            "Document exception: One or more "
                            "documents are marked EXPIRED."
                        )


            # 10. INFORMATION REQUESTS

            with tab2:

                st.subheader("Information Requests")

                if "request_update_message" in st.session_state:
                    st.success(
                        st.session_state.pop(
                            "request_update_message"
                        )
                    )

                requests = helper.get_information_requests(case_id)

                if requests.empty:

                    st.info("No information requests found.")

                else:

                    st.dataframe(requests, hide_index=True)

                    open_requests = requests[
                        requests["request_status"] == "OPEN"
                    ]

                    if not open_requests.empty:
                        st.warning(
                            f"{len(open_requests)} request(s) "
                            "are still OPEN."
                        )

                    else:
                        st.success("No open requests found.")


                    # 11. CONTROLLED TRAINING REQUEST UPDATES

                    st.divider()

                    st.subheader("Close a Training Request")

                    st.caption(
                        "Only OPEN REQ_TEST_ records can be "
                        "closed here. Original requests "
                        "remain read-only."
                    )

                    training_requests = requests[
                        requests["request_id"]
                        .astype(str)
                        .str.startswith("REQ_TEST_")
                        &
                        (requests["request_status"] == "OPEN")
                    ]

                    if training_requests.empty:

                        st.info(
                            "No OPEN training requests for this case."
                        )

                    else:

                        with st.form(
                            key=f"request_update_form_{case_id}",
                            clear_on_submit=True
                        ):

                            selected_request = st.selectbox(
                                "Select Training Request",
                                training_requests["request_id"].tolist()
                            )

                            actor_id = st.text_input(
                                "Analyst ID (Training)",
                                value="USR010"
                            )

                            closure_note = st.text_area(
                                "Closure Note",
                                max_chars=1000,
                                height=130
                            )

                            submitted = st.form_submit_button(
                                "Close Training Request"
                            )

                        if submitted:

                            if not actor_id.strip():
                                st.error("Analyst ID is required.")

                            elif not closure_note.strip():
                                st.error("Closure note is required.")

                            else:

                                try:

                                    helper.update_information_request(
                                        selected_request,
                                        actor_id.strip(),
                                        closure_note.strip()
                                    )

                                    st.session_state.request_update_message = (
                                        f"Training request "
                                        f"{selected_request} closed."
                                    )

                                    st.rerun()

                                except Exception as error:

                                    st.error(
                                        f"Update failed: {error}"
                                    )


            # 12. SCREENING

            with tab3:

                st.subheader("Sanctions and PEP Screening")

                screening = helper.get_case_screening(case_id)

                if screening.empty:

                    st.info(
                        "No screening run recorded for this case."
                    )

                else:

                    total_runs = screening[
                        "screening_run_id"
                    ].nunique()

                    hits = screening[
                        screening["screening_hit_id"].notna()
                    ]

                    st.write("Screening Runs:", total_runs)
                    st.write("Potential Hits:", len(hits))

                    st.dataframe(screening, hide_index=True)

                    if hits.empty:

                        st.info(
                            "Screening records found, "
                            "but no potential hits recorded."
                        )

                    else:

                        st.warning(
                            "Potential screening matches found. "
                            "Review match basis, identity "
                            "assessment and analyst disposition."
                        )


            # 13. RISK ASSESSMENT

            with tab4:

                st.subheader("Customer Risk Assessment")

                risk = helper.get_case_risk(case_id)

                if risk.empty:

                    st.info("No risk assessment found.")

                else:

                    st.write(
                        "Risk Rating:",
                        risk.iloc[0]["risk_rating"]
                    )

                    st.write(
                        "Risk Score:",
                        risk.iloc[0]["assessment_score"]
                    )

                    st.write(
                        "EDD Required:",
                        risk.iloc[0]["edd_required"]
                    )

                    st.write(
                        "Assessment Status:",
                        risk.iloc[0]["assessment_status"]
                    )

                    st.dataframe(risk, hide_index=True)

                    if risk.iloc[0]["assessment_status"] == "DRAFT":

                        st.warning(
                            "Risk assessment is still "
                            "in DRAFT status."
                        )

                st.subheader("Risk Factor Breakdown")

                factors = helper.get_case_risk_factors(case_id)

                if factors.empty:

                    st.info("No risk factors found.")

                else:

                    st.dataframe(factors, hide_index=True)

                    total_score = factors[
                        "weighted_value"
                    ].sum()

                    st.write(
                        "Total Weighted Risk Score:",
                        round(float(total_score), 4)
                    )


            # 14. INVESTIGATION NOTES

            with tab5:

                st.subheader("Add Investigation Note")

                st.caption(
                    "Training notes are saved to MySQL "
                    "with associated audit events."
                )

                with st.form(
                    key=f"note_form_{case_id}",
                    clear_on_submit=True
                ):

                    analyst_id = st.text_input(
                        "Analyst ID (Training)",
                        value="USR010"
                    )

                    note_text = st.text_area(
                        "Investigation Findings",
                        max_chars=1000,
                        height=150
                    )

                    save_clicked = st.form_submit_button(
                        "Save Investigation Note"
                    )

                if save_clicked:

                    if not analyst_id.strip():
                        st.error("Analyst ID is required.")

                    elif not note_text.strip():
                        st.error("Please enter investigation findings.")

                    else:

                        try:

                            helper.save_case_note(
                                case_id,
                                analyst_id.strip(),
                                note_text.strip()
                            )

                            st.success(
                                "Investigation note saved successfully."
                            )

                        except Exception as error:

                            st.error(
                                f"Could not save note: {error}"
                            )


                # 15. NOTE HISTORY

                st.divider()

                st.subheader("Investigation Note History")

                notes = helper.get_case_notes(case_id)

                if notes.empty:

                    st.info("No investigation notes recorded.")

                else:

                    st.write("Total Notes:", len(notes))
                    st.dataframe(notes, hide_index=True)


                # 16. CASE AUDIT HISTORY

                st.divider()

                st.subheader("Case Audit History")

                audit = helper.get_case_audit_log(case_id)

                if audit.empty:

                    st.info("No audit events recorded.")

                else:

                    st.write("Total Audit Events:", len(audit))
                    st.dataframe(audit, hide_index=True)


# 17. GLOBAL CASE MANAGEMENT

elif page == "Case Management":

    st.subheader("Case Management")

    st.caption(
        "Search and filter KYC cases across all customers."
    )

    all_cases = helper.get_all_kyc_cases()

    if all_cases.empty:

        st.info("No KYC cases found.")

    else:

        search_text = st.text_input(
            "Search Case ID, Customer ID or Customer Name"
        )

        col1, col2, col3 = st.columns(3)

        with col1:

            status_filter = st.selectbox(
                "Case Status",
                ["All"] + sorted(
                    all_cases["case_status"]
                    .dropna()
                    .unique()
                    .tolist()
                )
            )

        with col2:

            priority_filter = st.selectbox(
                "Priority",
                ["All"] + sorted(
                    all_cases["priority"]
                    .dropna()
                    .unique()
                    .tolist()
                )
            )

        with col3:

            review_filter = st.selectbox(
                "Review Type",
                ["All"] + sorted(
                    all_cases["review_type"]
                    .dropna()
                    .unique()
                    .tolist()
                )
            )


        # 18. APPLY CASE FILTERS

        filtered_cases = all_cases.copy()

        if search_text.strip():

            search_value = search_text.strip()

            matching_cases = (
                filtered_cases["case_id"].str.contains(
                    search_value,
                    case=False,
                    na=False,
                    regex=False
                )
                |
                filtered_cases["customer_id"].str.contains(
                    search_value,
                    case=False,
                    na=False,
                    regex=False
                )
                |
                filtered_cases["customer_name"].str.contains(
                    search_value,
                    case=False,
                    na=False,
                    regex=False
                )
            )

            filtered_cases = filtered_cases[matching_cases]

        if status_filter != "All":

            filtered_cases = filtered_cases[
                filtered_cases["case_status"] == status_filter
            ]

        if priority_filter != "All":

            filtered_cases = filtered_cases[
                filtered_cases["priority"] == priority_filter
            ]

        if review_filter != "All":

            filtered_cases = filtered_cases[
                filtered_cases["review_type"] == review_filter
            ]


        # 19. CASE WORKLIST METRICS

        st.divider()

        col1, col2, col3 = st.columns(3)

        with col1:
            st.metric("Total KYC Cases", len(all_cases))

        with col2:
            st.metric("Matching Cases", len(filtered_cases))

        with col3:

            high_count = (
                filtered_cases["priority"] == "HIGH"
            ).sum()

            st.metric(
                "High Priority in View",
                int(high_count)
            )


        # 20. CASE WORKLIST

        st.subheader("KYC Case Worklist")

        if filtered_cases.empty:

            st.info("No cases match the filters.")

        else:

            st.dataframe(filtered_cases, hide_index=True)

            st.subheader("Open a Case")

            chosen_case = st.selectbox(
                "Select Case ID",
                filtered_cases["case_id"].tolist()
            )

            if st.button("Select Case for Investigation"):

                chosen_row = filtered_cases[
                    filtered_cases["case_id"] == chosen_case
                ].iloc[0]

                st.session_state.selected_case_id = chosen_case

                st.session_state.searched_customer_id = (
                    chosen_row["customer_id"]
                )

                st.success(
                    f"Case {chosen_case} selected. "
                    "Open Case Investigation or Approvals & QC."
                )


# 21. APPROVALS & QC - NEW SECTION

elif page == "Approvals & QC":

    st.subheader("Approvals & Quality Control")

    st.caption(
        "Review stored QC outcomes, approval decisions "
        "and compliance escalation records."
    )

    case_id = st.session_state.selected_case_id

    if not case_id:

        st.info(
            "Select a KYC case from Customer Search "
            "or Case Management first."
        )

    else:

        st.write("Selected Case:", case_id)

        # 22. FETCH QC, APPROVAL AND ESCALATION DATA

        qc = helper.get_case_qc_reviews(case_id)

        approvals = helper.get_case_approvals(case_id)

        escalations = helper.get_case_escalations(case_id)


        # 23. RECORD COUNTS

        col1, col2, col3 = st.columns(3)

        with col1:
            st.metric("QC Records", len(qc))

        with col2:
            st.metric("Approval Records", len(approvals))

        with col3:
            st.metric("Escalation Records", len(escalations))


        # 24. SEPARATE REVIEW TABS

        qc_tab, approval_tab, escalation_tab = st.tabs(
            [
                "QC Reviews",
                "Approvals",
                "Escalations"
            ]
        )


        # 25. QUALITY CONTROL

        with qc_tab:

            st.subheader("Quality Control Reviews")

            if qc.empty:

                st.info(
                    "No QC review recorded for this case."
                )

            else:

                st.dataframe(qc, hide_index=True)

                # Check recorded QC outcomes.
                outcomes = (
                    qc["qc_outcome"]
                    .fillna("")
                    .astype(str)
                    .str.upper()
                )

                if (outcomes == "PASS").any():

                    st.success(
                        "A QC PASS outcome is recorded."
                    )

                if (outcomes == "FAIL").any():

                    st.warning(
                        "A QC FAIL outcome is recorded. "
                        "Review its defect and checker comments."
                    )


        # 26. APPROVAL DECISIONS

        with approval_tab:

            st.subheader("Approval Decisions")

            if approvals.empty:

                st.info(
                    "No approval decision recorded for this case."
                )

            else:

                st.dataframe(
                    approvals,
                    hide_index=True
                )

                decisions = (
                    approvals["approval_decision"]
                    .fillna("")
                    .astype(str)
                    .str.upper()
                )

                if (decisions == "APPROVED").any():

                    st.success(
                        "An APPROVED decision is recorded."
                    )

                if (decisions == "REJECTED").any():

                    st.warning(
                        "A REJECTED decision is recorded. "
                        "Review the approval details."
                    )


        # 27. COMPLIANCE ESCALATIONS

        with escalation_tab:

            st.subheader("Compliance Escalations")

            if escalations.empty:

                st.info(
                    "No escalation record found for this case."
                )

            else:

                st.dataframe(
                    escalations,
                    hide_index=True
                )

                escalation_statuses = (
                    escalations["escalation_status"]
                    .fillna("")
                    .astype(str)
                    .str.upper()
                )

                if (escalation_statuses == "OPEN").any():

                    st.warning(
                        "An OPEN escalation is recorded. "
                        "Review its status and decision details."
                    )

        st.divider()

        st.caption(
            "This page displays recorded decisions. "
            "It does not create QC outcomes, approve cases "
            "or resolve compliance escalations."
        )


# 28. AUDIT TRAIL

elif page == "Audit Trail":

    st.subheader("Audit Trail")

    st.caption(
        "Review recorded actions for the selected KYC case."
    )

    case_id = st.session_state.selected_case_id

    if not case_id:

        st.info(
            "Select a case from Customer Search "
            "or Case Management first."
        )

    else:

        st.write("Selected Case:", case_id)

        audit = helper.get_case_audit_log(case_id)

        if audit.empty:

            st.info("No audit events recorded.")

        else:

            st.metric(
                "Recorded Audit Events",
                len(audit)
            )

            st.dataframe(
                audit,
                hide_index=True
            )


# 29. OPERATIONS DASHBOARD

elif page == "Reports & Dashboard":

    st.subheader("KYC Operations Dashboard")

    st.caption(
        "Operational overview using MySQL case records."
    )

    all_cases = helper.get_all_kyc_cases()

    if all_cases.empty:

        st.info("No cases available for reporting.")

    else:

        # 30. CALCULATE CASE METRICS

        total_cases = len(all_cases)

        status_values = (
            all_cases["case_status"]
            .fillna("")
            .astype(str)
            .str.strip()
            .str.upper()
        )

        completed_cases = int(
            (status_values == "COMPLETED").sum()
        )

        not_completed_cases = total_cases - completed_cases

        open_cases = all_cases[
            status_values != "COMPLETED"
        ].copy()

        high_priority_cases = int(
            (
                open_cases["priority"]
                .fillna("")
                .astype(str)
                .str.upper() == "HIGH"
            ).sum()
        )


        # 31. KPI CARDS

        col1, col2, col3, col4 = st.columns(4)

        with col1:
            st.metric("Total Cases", total_cases)

        with col2:
            st.metric("Completed", completed_cases)

        with col3:
            st.metric("Not Completed", not_completed_cases)

        with col4:
            st.metric(
                "High Priority - Not Completed",
                high_priority_cases
            )


        # 32. CASE STATUS BREAKDOWN

        st.divider()

        st.subheader("Case Status Breakdown")

        status_summary = (
            all_cases["case_status"]
            .fillna("UNKNOWN")
            .value_counts()
            .rename_axis("Case Status")
            .reset_index(name="Cases")
        )

        st.dataframe(
            status_summary,
            hide_index=True
        )

        st.bar_chart(
            status_summary.set_index("Case Status")["Cases"]
        )


        # 33. PRIORITY AND REVIEW TYPE

        st.divider()

        col1, col2 = st.columns(2)

        with col1:

            st.subheader("Priority Distribution")

            priority_summary = (
                all_cases["priority"]
                .fillna("UNKNOWN")
                .value_counts()
                .rename_axis("Priority")
                .reset_index(name="Cases")
            )

            st.dataframe(
                priority_summary,
                hide_index=True
            )

        with col2:

            st.subheader("Review Type Distribution")

            review_summary = (
                all_cases["review_type"]
                .fillna("UNKNOWN")
                .value_counts()
                .rename_axis("Review Type")
                .reset_index(name="Cases")
            )

            st.dataframe(
                review_summary,
                hide_index=True
            )


        # 34. OVERDUE CASE REVIEW

        st.divider()

        st.subheader("Overdue Cases")

        st.caption(
            "Cases not marked COMPLETED whose due date "
            "is earlier than today's date."
        )

        open_cases["due_date_check"] = pd.to_datetime(
            open_cases["due_at"],
            errors="coerce"
        ).dt.date

        overdue_cases = open_cases[
            open_cases["due_date_check"] < date.today()
        ].copy()

        st.metric(
            "Overdue - Not Completed",
            len(overdue_cases)
        )

        st.caption(
            f"As of {date.today().strftime('%d %B %Y')}. "
            "This date-based flag does not establish "
            "whether a contractual SLA was breached."
        )

        if overdue_cases.empty:

            st.success("No overdue cases found.")

        else:

            overdue_cases = overdue_cases.sort_values(
                "due_at",
                ascending=True
            )

            st.dataframe(
                overdue_cases[
                    [
                        "case_id",
                        "customer_id",
                        "customer_name",
                        "case_status",
                        "priority",
                        "due_at"
                    ]
                ].head(15),
                hide_index=True
            )
