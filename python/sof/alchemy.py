import pandas as pd
from sqlalchemy import create_engine, text

from . import SqlCtx
from .ctx import SqlView

class AlchemySqlView(SqlView):

    def show(self):
        print("\n".join(map(str, self.as_cursor().fetchmany(10))))

    def to_pandas(self):
        return pd.read_sql_query(f"SELECT * FROM {self._name}", self._sql_ctx._conn)

    def to_csv(self, path):
        self.to_pandas().to_csv(path, index=False)

    def as_cursor(self):
        return self._sql_ctx.select(f"SELECT * FROM {self._name}")


class AlchemySqlCtx(SqlCtx):
    def __init__(self, conn):
       self._conn = conn

    def sql(self, sql):
        self._conn.execute(text(sql))

    def query(self, view_def):
        return AlchemySqlView(view_def, self)

    def select(self, sql):
        return self._conn.execute(text(sql))

    @classmethod
    def from_url(cls, url):
        return cls(create_engine(url, isolation_level='AUTOCOMMIT').connect())