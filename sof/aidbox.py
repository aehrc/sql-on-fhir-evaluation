from .alchemy import AlchemySqlCtx
import requests
import os
from sqlalchemy import create_engine

class AidboxSqlCtx(AlchemySqlCtx):

    def __init__(self, base_url, db_url, auth = None):
        super().__init__(create_engine(db_url, isolation_level='AUTOCOMMIT').connect())
        self._base_url = base_url
        self._auth = auth

    def sof(self, sof_view):
        view_id = sof_view['name']
        # create a view in the database
        response = requests.put(os.path.join(self._base_url, 'ViewDefinition', view_id),
                                 json = sof_view, auth = self._auth)
        print(response.status_code)


