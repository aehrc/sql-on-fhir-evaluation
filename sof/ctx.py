from typing import NamedTuple


class SqlCtx(NamedTuple):
    spark: 'SparkSession'
    ds: 'DataSource'

    def sql(self, sql):
        for line in sql.split(';'):
            if line.strip():
                self.spark.sql(line.strip())


