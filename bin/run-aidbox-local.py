import os
from sof import ViewCtx
from sof.aidbox import AidboxSqlCtx

from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_DIR = os.path.join(BASE_DIR, '_data/aidbox_mimic-demo-2.2')


def create_sql_ctx():
    ctx = AidboxSqlCtx(
        'http://localhost:8080',
        'postgresql+psycopg2://aidbox:fIF2TkhhH0@localhost:8432/aidbox',
        auth=('basic', 'secret')
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
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-fhir/*.sql'))
    #            .with_defined(['md_oxygen_delivery', 'md_bg', 'md_vitalsigns', 'md_icustay_detail'])
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())

    print(view_ctx._view_defs)
    view_ctx.create_all()
    # view_ctx.get_view('st_subject').show()
    # print(sql_ctx.select("SELECT * FROM md_icustay_detail LIMIT 10").fetchmany(10))
    # print(sql_ctx.select("SELECT * FROM st_subject").fetchmany(10))
    DataExporter(view_ctx).export(OUTPUT_DIR)


if __name__ == '__main__':
    main()
