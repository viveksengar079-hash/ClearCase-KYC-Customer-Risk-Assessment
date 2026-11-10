
# TASK 21D: VERIFY REQUEST UPDATE AND AUDIT LOG

import pandas as pd
from sqlalchemy import text
from helper import engine

# Our practice information request
request_id = "REQ_TEST_43DE0DE4309E"

# Retrieve the updated request and its audit record
query = text("""
    SELECT
        ir.request_id,
        ir.case_id,
        ir.request_status,
        ir.closure_note,
        a.event_id,
        a.event_type,
        a.old_value,
        a.new_value
    FROM information_requests AS ir
    LEFT JOIN case_audit_log AS a
        ON ir.request_id = a.related_record_id
        AND a.related_table = 'information_requests'
        AND a.event_type = 'REQUEST_STATUS_CHANGED'
    WHERE ir.request_id = :request_id
""")

with engine.connect() as connection:
    result = pd.read_sql(
        query,
        connection,
        params={"request_id": request_id}
    )

print("REQUEST UPDATE VERIFICATION")
print(result.to_string(index=False))
