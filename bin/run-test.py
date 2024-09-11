import os
import glob

from pathling import PathlingContext

from sof import SqlCtx, ViewCtx, SOFViewDef, SQLViewDef

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

    print(view_ctx.get_definition('coh_subject'))
    view_ctx.get_view('coh_subject').show()


if __name__ == '__main__':
    main()
