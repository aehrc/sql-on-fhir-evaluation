from setuptools import setup, find_packages

setup(
    name='mimic-sof',
    version='0.1.0',
    author='Piotr Szul',
    author_email='Piotr.Szul@csiro.au',
    description='Helper classes for running Sql on FHIR and SQL views on different providers.',
    packages=find_packages(),
    install_requires=[
        "duckdb>=1.0.0",
        "pyspark==3.5.2",
        "click>=8.1.7",
        "pandas>=2.2.2",
        "SQLAlchemy>=2.0.35",
        "psycopg2-binary>=2.9.9"
        #ALSO: an unreleased version of pathling
    ],
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.8',
)