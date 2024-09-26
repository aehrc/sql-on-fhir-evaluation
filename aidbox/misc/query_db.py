import os

import duckdb


def main():
    duckdb.sql(
        """ATTACH 'dbname=postgres user=postgres password=postgres host=localhost port=9432' AS db (TYPE POSTGRES);
        USE db;
        """)
    result = duckdb.sql("""
    SELECT COUNT(*) FROM patient
    """);
    print(result)


if __name__ == '__main__':
    main()