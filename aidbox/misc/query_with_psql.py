import pandas as pd
from sqlalchemy import create_engine, text

# Create an engine instance
engine = create_engine('postgresql+psycopg2://postgres:postgres@localhost:9432/postgres')

# Define your SQL query
query1 = "CREATE OR REPLACE TEMP VIEW xxxx AS SELECT * FROM mimic.md_bg"

# Execute the first query to create the view


# Define the second query to fetch data from the view
query2 = "SELECT * FROM xxxx LIMIT 10"

with engine.connect() as connection:
    connection.execute(text(query1))
    # Execute the second query and store the result in a DataFrame
    df = pd.read_sql_table(query2, connection)
    print("\n".join(map(str, connection.execute(text(query2)).fetchmany(10))))



# Display the DataFrame
print(df)