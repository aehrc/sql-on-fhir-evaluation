import os

import duckdb
from sof import ViewCtx
from sof.duckdb import DuckDBSqlCtx

from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_DIR = os.path.join(BASE_DIR, '_data/psql_mimic-2.2')

def create_sql_ctx():
    duckdb.sql("ATTACH 'dbname=mimic4 user=szu004' AS db (TYPE POSTGRES, READ_ONLY)")
    duckdb.sql("USE db")
    return DuckDBSqlCtx()

def main():
    print(f"Base dir: {BASE_DIR}")
    view_ctx = (ViewCtx.Builder(sql_ctx=create_sql_ctx())
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-2.2/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())

    print(view_ctx._view_defs)
    DataExporter(view_ctx).export(OUTPUT_DIR)

if __name__ == '__main__':
    main()
