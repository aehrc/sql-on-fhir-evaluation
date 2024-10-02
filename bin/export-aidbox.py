#!/usr/bin/env python
import os

import click

from sof import ViewCtx
from sof.aidbox import AidboxSqlCtx

from study.export import DataExporter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
VIEW_SRC_DIR = os.path.join(BASE_DIR, 'src')


@click.command()
@click.option('--aidbox-url', default='http://localhost:8080', help='Aidbox URL')
@click.option('--aidbox-db-url', default='postgresql+psycopg2://aidbox:fIF2TkhhH0@localhost:8432/aidbox',
              help='Aidbox DB URL')
@click.option('--auth-username', default='basic', help='Aidbox auth username')
@click.option('--auth-password', default='secret', help='Aidbox auth password')
@click.option("--legacy-views", type=str, default='no', help="Load legacy sof")
@click.option('--output-dir', required=True, help='Output directory')
def export_aidbox(aidbox_url, aidbox_db_url, auth_username, auth_password, legacy_views, output_dir):
    def create_sql_ctx():
        ctx = AidboxSqlCtx(
            aidbox_url,
            aidbox_db_url,
            auth=(auth_username, auth_password)
        )
        ctx.sql("""
            DROP SCHEMA IF EXISTS mimic CASCADE;
            CREATE SCHEMA IF NOT EXISTS mimic;
            CREATE SCHEMA IF NOT EXISTS sof;
            SET search_path TO mimic,sof,public;
        """)
        return ctx

    click.echo(f"Running views on Aidbox at: {aidbox_url} to: {output_dir}")
    click.echo(f"Loading legacy sof: {legacy_views}")
    click.echo(f"Base dir: {BASE_DIR}")
    view_ctx_builder = (ViewCtx.Builder(sql_ctx=create_sql_ctx()) \
                        .load_sof(os.path.join(VIEW_SRC_DIR, 'sof/*.json'))
                        .load_sql(os.path.join(VIEW_SRC_DIR, 'sof_typed.psql/*.sql')))

    if "yes" == legacy_views:
        view_ctx_builder.load_sof(os.path.join(VIEW_SRC_DIR, 'sof.legacy/*.json'))

    view_ctx = (view_ctx_builder
                .load_sql(os.path.join(VIEW_SRC_DIR, 'mimic-fhir/*.sql'))
                .load_sql(os.path.join(VIEW_SRC_DIR, 'study/*.sql'))
                .build())
    view_ctx.create_all()
    DataExporter(view_ctx).export(output_dir)


if __name__ == '__main__':
    export_aidbox()
