
# TASK 21A: MYSQL DATABASE CONNECTION

import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# Find our main project folder
project_folder = Path(__file__).resolve().parent.parent

# Load MySQL credentials from the .env file
load_dotenv(project_folder / ".env")

# Prepare database connection settings
db_url = URL.create(
    drivername="mysql+mysqlconnector",
    username=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    host=os.getenv("MYSQL_HOST"),
    port=int(os.getenv("MYSQL_PORT", "3306")),
    database=os.getenv("MYSQL_DATABASE")
)

# Create the database engine
engine = create_engine(db_url)

import pandas as pd
from sqlalchemy import text


# TASK 21B: SEARCH CUSTOMER BY ID

def get_customer(customer_id):

    query = text("""
        SELECT *
        FROM customers
        WHERE customer_id = :customer_id
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"customer_id": customer_id}
        )

    return df



# TASK 21B: RETRIEVE CUSTOMER'S KYC CASES

def get_customer_cases(customer_id):

    query = text("""
        SELECT
            case_id,
            customer_id,
            review_type,
            case_status,
            priority,
            due_at
        FROM kyc_cases
        WHERE customer_id = :customer_id
        ORDER BY due_at DESC
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"customer_id": customer_id}
        )

    return df



# TASK 21C: RETRIEVE KYC DOCUMENTS FOR A CASE

def get_case_documents(case_id):

    query = text("""
        SELECT
            document_id,
            document_type,
            verification_status,
            exception_code,
            received_at,
            expires_at,
            verified_at
        FROM customer_documents
        WHERE case_id = :case_id
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"case_id": case_id}
        )

    return df



# TASK 21C: RETRIEVE INFORMATION REQUESTS

def get_information_requests(case_id):

    query = text("""
        SELECT
            request_id,
            requested_item,
            request_status,
            requested_at,
            due_at,
            responded_at,
            relationship_manager_id
        FROM information_requests
        WHERE case_id = :case_id
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"case_id": case_id}
        )

    return df



# TASK 21C: GET SCREENING RESULTS FOR A KYC CASE

def get_case_screening(case_id):

    query = text("""
        SELECT
            sr.screening_run_id,
            sr.case_id,
            sr.screened_at,
            sr.run_status,
            sr.potential_hit_count,
            sh.screening_hit_id,
            sh.watchlist_entity_id,
            sh.match_score,
            sh.match_basis,
            sh.identity_assessment,
            sh.analyst_disposition,
            sh.analyst_rationale
        FROM screening_runs AS sr
        LEFT JOIN screening_hits AS sh
            ON sr.screening_run_id = sh.screening_run_id
        WHERE sr.case_id = :case_id
        ORDER BY sr.screened_at DESC
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"case_id": case_id}
        )

    return df



# TASK 21C: RETRIEVE CUSTOMER RISK ASSESSMENT

def get_case_risk(case_id):

    query = text("""
        SELECT
            assessment_id,
            case_id,
            assessment_score,
            risk_rating,
            edd_required,
            assessment_status,
            assessed_at,
            decision_rationale
        FROM customer_risk_assessments
        WHERE case_id = :case_id
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"case_id": case_id}
        )

    return df



# TASK 21C: RETRIEVE RISK FACTORS FOR A CASE

def get_case_risk_factors(case_id):

    query = text("""
        SELECT
            factor_name,
            factor_value,
            weight,
            weighted_value,
            evidence_note
        FROM case_risk_factors
        WHERE case_id = :case_id
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"case_id": case_id}
        )

    return df


from datetime import date
from uuid import uuid4


# TASK 21D: SAVE A KYC INVESTIGATION NOTE

def save_case_note(case_id, author_id, note_text):

    # Check that the note is valid
    note_text = note_text.strip()

    if not note_text or len(note_text) > 1000:
        raise ValueError("Note must contain 1 to 1000 characters.")

    # Create unique IDs for the new records
    note_id = "NOTE_" + uuid4().hex.upper()
    event_id = "EVT_" + uuid4().hex.upper()

    # Save both records in one transaction
    with engine.begin() as connection:

        # Confirm that the KYC case exists
        result = connection.execute(
            text("SELECT COUNT(*) FROM kyc_cases WHERE case_id = :case_id"),
            {"case_id": case_id}
        )

        if result.scalar() == 0:
            raise ValueError("KYC case not found.")

        # Save the investigation note
        connection.execute(
            text("""
                INSERT INTO case_notes
                (note_id, case_id, author_id, created_at,
                 note_type, note_text)
                VALUES
                (:note_id, :case_id, :author_id, :created_at,
                 'INVESTIGATION', :note_text)
            """),
            {
                "note_id": note_id,
                "case_id": case_id,
                "author_id": author_id,
                "created_at": date.today(),
                "note_text": note_text
            }
        )

        # Record the action in the audit log
        connection.execute(
            text("""
                INSERT INTO case_audit_log
                (event_id, case_id, event_at, actor_id,
                 event_type, related_table, related_record_id,
                 new_value, event_comment)
                VALUES
                (:event_id, :case_id, :event_at, :actor_id,
                 'NOTE_ADDED', 'case_notes', :note_id,
                 :note_id, 'Investigation note created')
            """),
            {
                "event_id": event_id,
                "case_id": case_id,
                "event_at": date.today(),
                "actor_id": author_id,
                "note_id": note_id
            }
        )

    return note_id



# TASK 21D: UPDATE A PRACTICE INFORMATION REQUEST

def update_information_request(request_id, actor_id, closure_note):

    # Only allow practice requests during testing
    if not request_id.startswith("REQ_TEST_"):
        raise ValueError("Only practice requests can be updated.")

    # Make sure a closure note is provided
    closure_note = closure_note.strip()

    if not closure_note or len(closure_note) > 1000:
        raise ValueError("Closure note must contain 1 to 1000 characters.")

    # Create an ID for the audit event
    event_id = "EVT_" + uuid4().hex.upper()

    with engine.begin() as connection:

        # Check the current request status
        result = connection.execute(
            text("""
                SELECT case_id, request_status
                FROM information_requests
                WHERE request_id = :request_id
            """),
            {"request_id": request_id}
        )

        request = result.fetchone()

        if request is None:
            raise ValueError("Information request not found.")

        case_id = request[0]
        old_status = request[1]

        if old_status != "OPEN":
            raise ValueError("Only OPEN requests can be closed.")

        # Update the practice request
        updated = connection.execute(
            text("""
                UPDATE information_requests
                SET request_status = 'CLOSED',
                    closure_note = :closure_note
                WHERE request_id = :request_id
                  AND request_status = 'OPEN'
            """),
            {
                "request_id": request_id,
                "closure_note": closure_note
            }
        )

        if updated.rowcount != 1:
            raise ValueError("Request status could not be updated.")

        # Record the change in the audit log
        connection.execute(
            text("""
                INSERT INTO case_audit_log
                (
                    event_id, case_id, event_at, actor_id,
                    event_type, related_table, related_record_id,
                    old_value, new_value, event_comment
                )
                VALUES
                (
                    :event_id, :case_id, :event_at, :actor_id,
                    'REQUEST_STATUS_CHANGED',
                    'information_requests', :request_id,
                    :old_status, 'CLOSED', :event_comment
                )
            """),
            {
                "event_id": event_id,
                "case_id": case_id,
                "event_at": date.today(),
                "actor_id": actor_id,
                "request_id": request_id,
                "old_status": old_status,
                "event_comment": "TRAINING TEST ONLY: Simulated request closure"
            }
        )

    return event_id



# TASK 21D: RETRIEVE SAVED INVESTIGATION NOTES

def get_case_notes(case_id):

    query = text("""
        SELECT
            note_id,
            case_id,
            author_id,
            created_at,
            note_type,
            note_text,
            evidence_reference
        FROM case_notes
        WHERE case_id = :case_id
        ORDER BY created_at DESC
    """)

    with engine.connect() as connection:
        df = pd.read_sql(
            query,
            connection,
            params={"case_id": case_id}
        )

    return df



# GET ALL KYC CASES FOR CASE MANAGEMENT

def get_all_kyc_cases():

    query = """
        SELECT
            k.case_id,
            k.customer_id,
            c.legal_name AS customer_name,
            k.review_type,
            k.case_status,
            k.priority,
            k.due_at
        FROM kyc_cases AS k
        LEFT JOIN customers AS c
            ON k.customer_id = c.customer_id
        ORDER BY k.due_at ASC, k.case_id ASC
    """

    with engine.connect() as connection:
        return pd.read_sql(text(query), connection)



# GET AUDIT TRAIL FOR A SELECTED KYC CASE

def get_case_audit_log(case_id):

    query = """
        SELECT *
        FROM case_audit_log
        WHERE case_id = :case_id
        ORDER BY event_id DESC
    """

    with engine.connect() as connection:

        return pd.read_sql(
            text(query),
            connection,
            params={"case_id": case_id}
        )



# 1. GET QUALITY CONTROL RECORDS

def get_case_qc_reviews(case_id):

    query = """
        SELECT *
        FROM qc_reviews
        WHERE case_id = :case_id
    """

    with engine.connect() as connection:
        return pd.read_sql(
            text(query),
            connection,
            params={"case_id": case_id}
        )


# 2. GET CASE APPROVAL RECORDS

def get_case_approvals(case_id):

    query = """
        SELECT *
        FROM case_approvals
        WHERE case_id = :case_id
    """

    with engine.connect() as connection:
        return pd.read_sql(
            text(query),
            connection,
            params={"case_id": case_id}
        )


# 3. GET COMPLIANCE ESCALATION RECORDS

def get_case_escalations(case_id):

    query = """
        SELECT *
        FROM escalations
        WHERE case_id = :case_id
    """

    with engine.connect() as connection:
        return pd.read_sql(
            text(query),
            connection,
            params={"case_id": case_id}
        )
