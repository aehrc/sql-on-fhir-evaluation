#!/usr/bin/env python
import os

from sof import ViewCtx
import click
from study.export import DataExporter
from sof.alchemy import AlchemySqlCtx

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')

@click.command()
@click.option('--mimic-db-url', required=True, type=str, help='MIMIC-4 DB URL')
@click.option('--output-dir', required=True, help='Output directory')
def export_psql(mimic_db_url, output_dir):
    click.echo(f"Running views on psql data from: {mimic_db_url} to: {output_dir}")
    click.echo(f"Base dir: {BASE_DIR}")
    def create_sql_ctx():
        return AlchemySqlCtx.from_url(mimic_db_url)

    view_ctx = (ViewCtx.Builder(sql_ctx=create_sql_ctx())
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-2.2/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())

    view_ctx.create_all()
    view_ctx.get_view('st_subject').show()
    view_ctx.get_view('st_reading_o2_flow').show()
    view_ctx.get_view('st_reading_so2').show()
    view_ctx.get_view('st_reading_spo2').show()
    view_ctx.get_view('st_ventilation').show()
    view_ctx.get_view('coh_reading_o2_flow').show()
    #DataExporter(view_ctx).export(output_dir)

if __name__ == '__main__':
    export_psql()
