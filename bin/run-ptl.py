import os
import glob

from pathling import PathlingContext

from sof import ViewCtx, SOFView, SQLView

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_DIR = os.path.join(BASE_DIR, 'data/fhir_mimic-2.2')

SPARK_CONF_DIR = os.path.join(BASE_DIR, 'env/spark-conf')
MIMIC_FHIR_PATH = "/Users/szu004/datasets/work/mimic-iv/mimic4-ptl"


def create_view_ctx():
    os.environ['SPARK_CONF_DIR'] = SPARK_CONF_DIR
    pc = PathlingContext.create()
    spark = pc.spark
    return ViewCtx(spark=spark, ds=pc.read.parquet(MIMIC_FHIR_PATH))


def main():
    print(f"Base dir: {BASE_DIR}")
    print(f"Spark conf dir: {SPARK_CONF_DIR}")
    view_ctx = create_view_ctx()

    for view_file in glob.glob(os.path.join(VIEW_SRC_DIR, 'sof/*.json')):
        sof_view = SOFView.from_file(view_file)
        sof_view.run(view_ctx)

    for view_file in sorted(glob.glob(os.path.join(VIEW_SRC_DIR, 'sql/*.sql'))):
        sof_view = SQLView.from_file(view_file)
        sof_view.run(view_ctx)


    (SQLView.from_file(os.path.join(VIEW_SRC_DIR, 'sql/xcoh_subject.sql'))
     .to_csv(view_ctx, os.path.join(OUTPUT_DIR, 'subject.csv')))
    (SQLView.from_file(os.path.join(VIEW_SRC_DIR, 'sql/xcoh_x_reading_o2_flow.sql'))
     .to_csv(view_ctx, os.path.join(OUTPUT_DIR, 'reading_o2_flow.csv')))
    (SQLView.from_file(os.path.join(VIEW_SRC_DIR, 'sql/xcoh_x_reading_spo2.sql'))
     .to_csv(view_ctx, os.path.join(OUTPUT_DIR, 'reading_spo2.csv')))
    (SQLView.from_file(os.path.join(VIEW_SRC_DIR, 'sql/xcoh_x_reading_so2.sql'))
     .to_csv(view_ctx, os.path.join(OUTPUT_DIR, 'reading_so2.csv')))

if __name__ == '__main__':
    main()
