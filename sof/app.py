import glob
from sof import SOFView, SQLView


class ResultView:
    def __init__(self, view_def, sql_ctx):
        self._view_def = view_def
        self._name = view_def.name
        self._sql_ctx = sql_ctx

    @property
    def name(self):
        return self._name

    def show(self):
        self.select().show()

    def to_pandas(self):
        return self.select().toPandas()

    def to_csv(self, path):
        self.to_pandas().to_csv(path)

    def select(self):
        return self._sql_ctx.spark.sql(f"SELECT * FROM {self._name}")

class ViewCtx:

    class Builder:
        def __init__(self, sql_ctx):
            self._sql_ctx = sql_ctx
            self._view_defs = []

        def with_view(self, view_def):
            self._view_defs.append(view_def)
            return self

        def with_views(self, views_def):
            self._view_defs.extend(views_def)
            return self

        def load_sof(self, view_glob):
            return self.with_views([SOFView.from_file(view_file)
                                    for view_file in glob.glob(view_glob)])

        def load_sql(self, view_glob):
            return self.with_views([SQLView.from_file(view_file)
                                    for view_file in glob.glob(view_glob)])

        def build(self):
            return ViewCtx(self._sql_ctx, self._view_defs)

    def __init__(self, sql_ctx, view_defs):
        self._sql_ctx = sql_ctx
        self._view_defs = {view_def.name: view_def for view_def in view_defs}
        self._views = {}


    def get_definition(self, view_name):
        return self._view_defs[view_name]


    def _instantiate_view(self, view_name):
        if view_name not in self._views:
            view_def = self.get_definition(view_name)
            # recursively instantiate dependencies
            for dep in view_def.depends_on or []:
                self._instantiate_view(dep)
            view_def.run(self._sql_ctx)
            self._views[view_name] = ResultView(view_def, self._sql_ctx)

    def get_view(self, view_name):
        self._instantiate_view(view_name)
        return self._views[view_name]

