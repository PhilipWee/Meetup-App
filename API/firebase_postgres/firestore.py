import firebase_postgres

def client(app=None):
    if app is None:
        return firebase_postgres.get_app()