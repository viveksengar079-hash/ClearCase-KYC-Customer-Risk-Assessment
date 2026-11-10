
# Test customer profile and KYC cases

from helper import get_customer, get_customer_cases

# Search for Alice Bennett
customer_id = "CUS00006"

# Retrieve customer information
customer = get_customer(customer_id)

# Retrieve the customer's KYC cases
cases = get_customer_cases(customer_id)

print("CUSTOMER PROFILE")
print(customer[["customer_id", "legal_name"]])

print("\nCUSTOMER KYC CASES")
print(cases)


from helper import get_customer, get_customer_cases, get_case_documents



# Test document retrieval for Alice Bennett

documents = get_case_documents("KYC001203")

print("\nALICE BENNETT - KYC DOCUMENTS")
print(documents)

from helper import get_customer, get_customer_cases, get_case_documents, get_information_requests


# Test information requests for Alice Bennett

requests = get_information_requests("KYC001203")

print("\nALICE BENNETT - INFORMATION REQUESTS")
print(requests.to_string(index=False))

from helper import get_case_screening


# Test screening retrieval for Sofia Walker

screening = get_case_screening("KYC000003")

print("\nSOFIA WALKER - SCREENING RESULTS")

print(screening.to_string(index=False))


from helper import get_case_risk


# Test risk assessment for Sofia Walker

risk = get_case_risk("KYC000003")

print("\nSOFIA WALKER - RISK ASSESSMENT")

print(risk.to_string(index=False))


from helper import get_case_risk_factors


# Test Sofia Walker's risk factors

risk_factors = get_case_risk_factors("KYC000003")

print("\nSOFIA WALKER - RISK FACTORS")
print(risk_factors.to_string(index=False))

# Check the total weighted score
print("\nTotal weighted score:",
      risk_factors["weighted_value"].sum())


from helper import get_case_notes


# Check saved notes for Alice Bennett

notes = get_case_notes("KYC001203")

print("\nALICE BENNETT - CASE NOTES")
print(notes.to_string(index=False))


