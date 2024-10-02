#!/usr/bin/env python

import os
import click
from pathling import PathlingContext
from sof import ViewCtx
from sof.ptl import PtlSqlCtx

from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')
SPARK_CONF_DIR = os.path.join(BASE_DIR, 'env/spark-conf')

@click.command()
@click.option('--mimic-ptl-dir', required=True, help='Mimic Pathling encoded path')
@click.option('--output-dir', required=True, help='Output directory')
def export_ptl(mimic_ptl_dir, output_dir):
    click.echo(f"Running views on ptl data from: {mimic_ptl_dir} to: {output_dir}")
    click.echo(f"Base dir: {BASE_DIR}")
    click.echo(f"Spark conf dir: {SPARK_CONF_DIR}")

    def create_sql_ctx():
        os.environ['SPARK_CONF_DIR'] = SPARK_CONF_DIR
        pc = PathlingContext.create()
        spark = pc.spark
        return PtlSqlCtx(spark=spark, ds=pc.read.parquet(mimic_ptl_dir))


    view_ctx = (ViewCtx.Builder(sql_ctx=create_sql_ctx())
                .load_sof(os.path.join(VIEW_SRC_DIR, 'sof/*.json'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'sof_typed.spark/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-fhir/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())

    print(view_ctx._view_defs)
    DataExporter(view_ctx).export(output_dir)

if __name__ == '__main__':
    export_ptl()
