import firebase_postgres as firebase_admin
from firebase_postgres import firestore
import credentials as creds

#Testing
firebase_admin.initialize_app(creds)
db = firestore.client()
collection = db.collection('userData')
print(collection)
testing = {'hello':'world',
            'you':'gey'}
db.collection(u'userData').document('000000').set(testing)
print(db.collection(u'userData').document('000000').get().to_dict())
print(db.collection(u'userData').document('000000').get().get('hello'))