import duckdb

from . import SqlCtx
from .ctx import SqlView

class DuckDBSqlView(SqlView):

    def show(self):
        self.as_query().show()

    def to_pandas(self):
        return self.as_query().to_df()

    def to_csv(self, path):
        self.as_query().to_csv(path)

    def as_query(self):
        return self._sql_ctx.select(f"SELECT * FROM {self._name}")


class DuckDBSqlCtx(SqlCtx):
    def __init__(self, init_sql=None):
        if init_sql:
            duckdb.sql(init_sql)

    def sql(self, sql):
        duckdb.sql(sql)

    def query(self, view_def):
        return DuckDBSqlView(view_def, self)

    def select(self, sql):
        return duckdb.sql(sql)
