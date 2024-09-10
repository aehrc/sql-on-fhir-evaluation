import json
import re
from xml.etree.ElementPath import prepare_self


class SOFView:
    def __init__(self, view_def, name=None):
        self._view_def = view_def
        self._name = name or view_def['name']

    @property
    def name(self):
        return self._name

    @property
    def depends_on(self):
        return  None

    def run(self, view_ctx):
        print(f"Creating SOF view {self._name}")
        view = view_ctx.ds.view(json=json.dumps(self._view_def))
        view.cache().createOrReplaceTempView(self._name)

    def select(self, view_ctx):
        return view_ctx.spark.sql(f"SELECT * FROM {self._name}")

    @classmethod
    def from_file(cls, file_path):
        with open(file_path) as f:
            view_def = json.load(f)
        return cls(view_def)


class SQLView:
    def __init__(self, sql, name, depends_on=None):
        self._sql = sql
        self._name = name
        self._depends_on = depends_on

    @property
    def name(self):
        return self._name

    @property
    def depends_on(self):
        return self._depends_on

    def run(self, view_ctx):
        print(f"Creating SQL view {self._name}, depends on: {self._depends_on}")
        view_ctx.sql(self._sql)

    def select(self, view_ctx):
        return view_ctx.spark.sql(f"SELECT * FROM {self._name}")

    def cache(self, view_ctx):
        view_ctx.sql(f"CACHE TABLE {self._name}")

    def to_csv(self, view_ctx, file_path):
        self.select(view_ctx).toPandas().to_csv(file_path, index=False)

    @classmethod
    def from_file(cls, file_path):
        with open(file_path) as f:
            sql = f.read()
        match = re.search(r'CREATE OR REPLACE \w* VIEW (\w+) AS', sql)
        match = match or re.search(r'CREATE TABLE (\w+) AS', sql)
        if not match:
            raise ValueError(f"Cannot find view name in {file_path}")

        dep_match = re.search(r'^-- DEPENDS-ON: (.+)$', sql, flags=re.MULTILINE)
        depends_on =  [ dep.strip() for dep in dep_match.group(1).split(',') if dep.strip() ] if dep_match else None
        return cls(sql, match.group(1), depends_on)
