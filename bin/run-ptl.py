import os
import glob

from pathling import PathlingContext

from sof import SqlCtx, SOFView, SQLView, ViewCtx

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_DIR = os.path.join(BASE_DIR, 'data/fhir_mimic-2.2')

SPARK_CONF_DIR = os.path.join(BASE_DIR, 'env/spark-conf')
MIMIC_FHIR_PATH = "/Users/szu004/datasets/work/mimic-iv/mimic4-ptl"


def create_sql_ctx():
    os.environ['SPARK_CONF_DIR'] = SPARK_CONF_DIR
    pc = PathlingContext.create()
    spark = pc.spark
    return SqlCtx(spark=spark, ds=pc.read.parquet(MIMIC_FHIR_PATH))


def main():
    print(f"Base dir: {BASE_DIR}")
    print(f"Spark conf dir: {SPARK_CONF_DIR}")


    view_ctx = (ViewCtx.Builder(sql_ctx=create_sql_ctx())
                .load_sof(os.path.join(VIEW_SRC_DIR, 'sof/*.json'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'sql/*.sql'))
                .build())

    print(view_ctx._view_defs)

    export_views = [
        'subject',
        'reading_o2_flow',
        'reading_spo2',
        'reading_so2'
    ]
    for view_tag in export_views:
        print(f"Exporting view: {view_tag}")
        view_ctx.get_view(f'coh_{view_tag}').to_csv(os.path.join(OUTPUT_DIR, f"{view_tag}.csv"))


if __name__ == '__main__':
    main()
