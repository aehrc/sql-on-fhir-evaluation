from . duckdb import DuckDBSqlCtx
import requests
import os
class AidboxSqlCtx(DuckDBSqlCtx):

    def __init__(self, base_url, auth = None):
        super().__init__()
        self._base_url = base_url
        self._auth = auth

    def sof(self, sof_view):
        view_id = sof_view['name']
        # create a view in the database
        response = requests.put(os.path.join(self._base_url, 'ViewDefinition', view_id),
                                 json = sof_view, auth = self._auth)
        print(response.status_code)


