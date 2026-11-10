
# Test saving an investigation note

from helper import save_case_note

note_id = save_case_note(
    case_id="KYC001203",
    author_id="USR010",
    note_text=(
        "TRAINING TEST ONLY: Identity document remains expired. "
        "RM follow-up is required. No actual contact has been made."
    )
)

print("Investigation note saved!")
print("New note ID:", note_id)
