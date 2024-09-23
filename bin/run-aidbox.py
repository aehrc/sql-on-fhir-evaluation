import os

import duckdb
from sof import ViewCtx
from sof.aidbox import AidboxSqlCtx

from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_DIR = os.path.join(BASE_DIR, '_data/aidbox_mimic-2.2')

def create_sql_ctx():
    duckdb.sql("ATTACH 'dbname=aidbox user=aidbox password=fIF2TkhhH0 host=localhost port=8432' AS db (TYPE POSTGRES)")
    duckdb.sql("""
        USE db;
        DROP SCHEMA IF EXISTS mimic CASCADE;
        CREATE SCHEMA IF NOT EXISTS mimic;
        CREATE SCHEMA IF NOT EXISTS sof;
        SET search_path TO 'mimic,sof,public';
    """)
    return AidboxSqlCtx('http://localhost:8080', auth=('basic', 'secret'))

def main():
    print(f"Base dir: {BASE_DIR}")
    view_ctx = (ViewCtx.Builder(sql_ctx=create_sql_ctx())
                .load_sof(os.path.join(VIEW_SRC_DIR, 'sof/*.json'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-fhir/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())

    print(view_ctx._view_defs)
    view_ctx.create_all()
    DataExporter(view_ctx).export(OUTPUT_DIR)

if __name__ == '__main__':
    main()
