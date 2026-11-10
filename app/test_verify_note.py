
# TASK 21D: VERIFY SAVED NOTE AND AUDIT RECORD

import pandas as pd
from sqlalchemy import text
from helper import engine

# Use the note ID printed in your previous test
note_id = "NOTE_ED834309218D49B6BE0ADD00BDA5C6A3"

query = text("""
    SELECT
        n.note_id,
        n.case_id,
        n.author_id,
        n.note_text,
        a.event_id,
        a.event_type,
        a.actor_id
    FROM case_notes AS n
    LEFT JOIN case_audit_log AS a
        ON n.note_id = a.related_record_id
        AND a.related_table = 'case_notes'
    WHERE n.note_id = :note_id
""")

with engine.connect() as connection:
    result = pd.read_sql(
        query,
        connection,
        params={"note_id": note_id}
    )

print(result.to_string(index=False))
