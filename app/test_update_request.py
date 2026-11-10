
# Test updating a practice information request

from helper import update_information_request

event_id = update_information_request(
    request_id="REQ_TEST_43DE0DE4309E",
    actor_id="USR010",
    closure_note=(
        "TRAINING TEST ONLY: Simulated closure for testing. "
        "No actual document or response was received or verified."
    )
)

print("Practice request updated successfully!")
print("Audit event ID:", event_id)
