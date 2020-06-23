# --------------------------------------REQUIREMENTS--------------------------------------

import psycopg2
import json

# --------------------------------------REQUIREMENTS--------------------------------------

# --------------------------------------CONSTANTS-----------------------------------------
_DEFAULT_APP_NAME = 'default'
# --------------------------------------CONSTANTS-----------------------------------------


_apps = {}


def initialize_app(credential=None):
    if credential is not None:
        app = App(credential)
        _apps[_DEFAULT_APP_NAME] = app
    else:
        print('Credentials must be provided!')


def get_app(name=_DEFAULT_APP_NAME):
    if name in _apps:
        return _apps[name]

    if name == _DEFAULT_APP_NAME:
        raise ValueError(
            'The default Firebase app does not exist. Make sure to initialize '
            'the SDK by calling initialize_app().')


class App:
    def __init__(self, credential):
        # --------------------------------------CONNECT TO DATABASE-------------------------------
        try:
            print("Connecting to the data database")
            conn_string = "host=" + credential.PGHOST + " port=" + "5432" + " dbname=" + credential.PGUSERDATADATABASE + " user=" + credential.PGUSER \
                + " password=" + credential.PGPASSWORD
            self.data_conn = psycopg2.connect(conn_string)
            print("Connected!")
        except:
            try:
                # We may be on the server, try connecting to that instead
                conn_string = "host=" + credential.PGAWSHOST + " port=" + "5432" + " dbname=" + credential.PGUSERDATADATABASE + " user=" + credential.PGUSER \
                    + " password=" + credential.PGPASSWORD
                self.data_conn = psycopg2.connect(conn_string)
                print("Connected!")
            except:
                raise Exception(
                    "Unable to connect to the userdata database, check postgres is running and IP address is correct")
        # --------------------------------------CONNECT TO DATABASE-------------------------------\

    def collection(self, collection_name):
        return Collection(collection_name, self.data_conn)


class Collection:
    def __init__(self, collection_name, data_conn):
        self.data_conn = data_conn
        self.collection_name = collection_name

    def document(self, document_id):
        return Document(document_id, self.collection_name, self.data_conn)


class Document:
    def __init__(self, document_id, collection_name, data_conn):
        self.document_id = document_id
        self.collection_name = collection_name
        self.data_conn = data_conn

    def get(self):
        # Pull the data
        return DocumentData(self.document_id, self.collection_name, self.data_conn)
    
    def update(self,dct):
        if len(dct) > 1:
            print("Error: The update dict can only have one key")
            return
        cur = self.data_conn.cursor()
        dct_key = list(dct.keys())[0]
        string_formatter = {
            'collec_name': self.collection_name,
            'doc_id': self.document_id,
            'json_data': json.dumps(dct[dct_key]),
            'dct_key':dct_key
        }
        command_string = """UPDATE {collec_name} 
        SET data = jsonb_set(data,\'{{{dct_key}}}\',\'{json_data}\')
        WHERE id = \'{doc_id}\'
            """.format(**string_formatter)
        print(command_string)
        cur.execute(command_string)
        self.data_conn.commit()
        cur.close()
        return None

    def set(self, data):
        cur = self.data_conn.cursor()
        string_formatter = {
            'collec_name': self.collection_name,
            'doc_id': self.document_id,
            'json_data': json.dumps(data)
        }
        command_string = """INSERT INTO public."{collec_name}" (id, data)
            VALUES (\'{doc_id}\',\'{json_data}\')
            ON CONFLICT (id)
            DO
            UPDATE
            SET data= EXCLUDED.data
            """.format(**string_formatter)
        print(command_string)
        cur.execute(command_string)
        self.data_conn.commit()
        cur.close()
        return None


class DocumentData:
    def __init__(self, document_id, collection_name, data_conn):
        self.document_id = document_id
        self.collection_name = collection_name
        self.data_conn = data_conn

    def get(self, path):
        cur = self.data_conn.cursor()
        cur.execute('SELECT data->\'{}\' FROM public."{}" WHERE ID = \'{}\''.format(
            path,self.collection_name, self.document_id))
        result = cur.fetchone()
        cur.close()
        return result[0]

    def to_dict(self):
        cur = self.data_conn.cursor()
        cur.execute('SELECT data FROM public."{}" WHERE ID = \'{}\''.format(
            self.collection_name, self.document_id))
        result = cur.fetchone()
        cur.close()
        if result:
            return result[0]
        else:
            return None


# data = db.collection(u'userData').document(request.args["username"]).get().to_dict()
# db.collection(u'sessions').document(session_id)
# db.collection(u'userData').document(details['uuid']).get().to_dict()
# db.collection(u'userData').document(details['uuid']).set(data)
# db.collection(u'sessions').document(session_id)
