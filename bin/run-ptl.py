import os

from pathling import PathlingContext

from sof import ViewCtx
from sof.ptl import PtlSqlCtx

from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_DIR = os.path.join(BASE_DIR, '_data/fhir_mimic-2.2')

SPARK_CONF_DIR = os.path.join(BASE_DIR, 'env/spark-conf')
MIMIC_FHIR_PATH = "/Users/szu004/datasets/work/mimic-iv/mimic4-ptl"


def create_sql_ctx():
    os.environ['SPARK_CONF_DIR'] = SPARK_CONF_DIR
    pc = PathlingContext.create()
    spark = pc.spark
    return PtlSqlCtx(spark=spark, ds=pc.read.parquet(MIMIC_FHIR_PATH))


def main():
    print(f"Base dir: {BASE_DIR}")
    print(f"Spark conf dir: {SPARK_CONF_DIR}")

    view_ctx = (ViewCtx.Builder(sql_ctx=create_sql_ctx())
                .load_sof(os.path.join(VIEW_SRC_DIR, 'sof/*.json'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-fhir/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())

    print(view_ctx._view_defs)
    DataExporter(view_ctx).export(OUTPUT_DIR)


if __name__ == '__main__':
    main()
