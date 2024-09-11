import json
from typing import NamedTuple

from . import SqlCtx
from .ctx import SqlView


class PtlDBSqlView(SqlView):

    def show(self):
        self.as_df().show()

    def to_pandas(self):
        return self.as_df().toPandas()

    def to_csv(self, path):
        self.to_pandas().to_csv(path)

    def as_df(self):
        return self._sql_ctx.select(f"SELECT * FROM {self._name}")


class PtlSqlCtx(SqlCtx):

    def __init__(self, spark, ds):
        self._spark = spark
        self._ds = ds

    def sof(self, sof_view):
        view_name = sof_view['name']
        view_df = self._ds.view(json=json.dumps(sof_view))
        view_df.cache().createOrReplaceTempView(view_name)

    def sql(self, sql):
        for line in sql.split(';'):
            if line.strip():
                self._spark.sql(line.strip())

    def query(self, view_def):
        return PtlDBSqlView(view_def, self)

    def select(self, sql):
        return self._spark.sql(sql)
