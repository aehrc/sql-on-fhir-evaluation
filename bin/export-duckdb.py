#!/usr/bin/env python
import os

import click

from sof import ViewCtx
from sof.duckdb import DuckDBSqlCtx
from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')


@click.command()
@click.option('--init-sql', required=True, type=str, help='DuckDB init SQL')
@click.option('--output-dir', required=True, help='Output directory')
def export_duckdb(init_sql, output_dir):
    click.echo(f"Running views on duckdb data with init: '{init_sql}' to: {output_dir}")
    print(f"Base dir: {BASE_DIR}")

    def create_sql_ctx():
        return DuckDBSqlCtx(init_sql)

    view_ctx = (ViewCtx.Builder(sql_ctx=create_sql_ctx())
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-2.2/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())
    DataExporter(view_ctx).export(output_dir)


if __name__ == '__main__':
    export_duckdb()
