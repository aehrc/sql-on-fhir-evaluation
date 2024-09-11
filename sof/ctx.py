class SqlView:
    def __init__(self, view_def, sql_ctx):
        self._view_def = view_def
        self._name = view_def.name
        self._sql_ctx = sql_ctx

    @property
    def name(self):
        return self._name

    def show(self):
        raise NotImplementedError()

    def to_pandas(self):
        raise NotImplementedError()

    def to_csv(self, path):
        raise NotImplementedError()


class SqlCtx:

    def sof(self, sof_view):
        raise NotImplementedError()

    def sql(self, sql):
        raise NotImplementedError()

    def query(self, view_def):
        raise NotImplementedError()
