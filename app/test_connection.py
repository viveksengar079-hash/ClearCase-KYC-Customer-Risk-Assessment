
# Test our MySQL connection

from helper import engine
from sqlalchemy import text

with engine.connect() as connection:
    result = connection.execute(text("SELECT DATABASE()"))
    print("Connected to:", result.scalar())
