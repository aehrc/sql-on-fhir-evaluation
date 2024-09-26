import os
from sof import ViewCtx
from sof.aidbox import AidboxSqlCtx

from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_DIR = os.path.join(BASE_DIR, '_data/aidbox_mimic-2.2')


def create_sql_ctx():
    ctx = AidboxSqlCtx(
        'http://localhost:9080',
        'postgresql+psycopg2://postgres:postgres@localhost:9432/postgres',
        auth=('szu004', 'secret123')
    )
    ctx.sql("""
        DROP SCHEMA IF EXISTS mimic CASCADE;
        CREATE SCHEMA IF NOT EXISTS mimic;
        CREATE SCHEMA IF NOT EXISTS sof;
        SET search_path TO mimic,sof,public;
    """)

    return ctx

def main():
    print(f"Base dir: {BASE_DIR}")
    sql_ctx = create_sql_ctx()
    view_ctx = (ViewCtx.Builder(sql_ctx=sql_ctx)
                .load_sof(os.path.join(VIEW_SRC_DIR, 'sof/*.json'))
                # load legacy beacasue of an aidbox bug with accessing choice values in extensions (value.ofType(Xxxx) is not working but valueXxxx is)
                .load_sof(os.path.join(VIEW_SRC_DIR, 'sof.legacy/*.json'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-fhir/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())

    print(view_ctx._view_defs)
    view_ctx.create_all()
    #view_ctx.get_view('md_icustay_detail').show()
    # print(sql_ctx.select("SELECT * FROM md_icustay_detail LIMIT 10").fetchmany(10))
    # print(sql_ctx.select("SELECT * FROM st_subject").fetchmany(10))
    DataExporter(view_ctx).export(OUTPUT_DIR)
    sql_ctx._conn.close()


if __name__ == '__main__':
    main()
