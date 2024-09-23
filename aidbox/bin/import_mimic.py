#!/usr/bin/env python
import json
import requests
import glob
import os
import gzip
import re
import datetime
import click


def resource_from_file(file):
    with gzip.open(file, 'rt') as f:
        match = re.search(r'"resourceType":\s*"([^"]+)"', f.readline().strip())
        return match.group(1) if match else None


@click.command()
@click.option('--mimic-ds-dir', type = str, required=True, help='Directory with the specific MIMIC dataset relative to the root directory')
@click.option('--aidbox-url', default='http://localhost:8080', help='Aidbox URL')
@click.option('--mimic-base-url', default='file:///data/hb-mimic-iv', help='Base URL for MIMIC FHIR resources')
@click.option('--mimic-root-dir', default='/Volumes/{hb-mimic-iv}',
              help='The root directory with the MIMIC FHIR resources')
@click.option('--auth-username', default=None, type=str, help='Basic auth credentials username')
@click.option('--auth-password', default=None, type=str, help='Basic auth credentials password')
def import_mimic(aidbox_url, mimic_base_url, mimic_root_dir, mimic_ds_dir, auth_username, auth_password):

    mimic_fhir_dir = os.path.join(mimic_root_dir, mimic_ds_dir)
    mimic_ds_base_url = os.path.join(mimic_base_url, mimic_ds_dir)

    click.echo(f"For: {aidbox_url} \nImporting resources from: {mimic_ds_base_url}\nIndex at: {mimic_fhir_dir}")

    mimic_resources = [(os.path.basename(p), resource_from_file(p)) for p in
                       glob.glob(os.path.join(mimic_fhir_dir, '*.ndjson.gz'))]
    # current time in yyyymmddhhmmss format
    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    import_request = dict(
        id=f'mimic4-{timestamp}',
        contentEncoding='gzip',
        inputs=[
            dict(resourceType=resource, url=os.path.join(mimic_ds_base_url, filename)) for filename, resource in
            mimic_resources
        ],
    )
    # This is not very efficient, but it's the simplest way to load the data
    import_endpoint = os.path.join(aidbox_url, 'v2/fhir/$import')
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'  # Set Accept header to application/yaml if you expect a YAML response
    }
    auth = (auth_username, auth_password) if auth_username and auth_password else None
    click.echo(f"Endpoint: {import_endpoint}")
    click.echo("Request:")
    click.echo(json.dumps(import_request, indent=2))
    response = requests.post(import_endpoint, headers=headers, json=import_request, auth=auth)
    if response.status_code != 200:
        click.echo(f"Failed to import data, response status: {response.status_code}, response text: {response.text}")
        exit(1)
    else:
        click.echo(f"Success, response status: {response.status_code}, response text: {response.text}")

if __name__ == '__main__':
    import_mimic()
