#===============INITIALISATION START================
import firebase_admin
from firebase_admin import credentials, firestore
#===============INITIALISATION END==================

#================FIREBASE CLASS=====================
class firebase_data:
    def __init__(self):
        # Initialization.
        # include in same folder, file 'firebase_key.json' - file created on Firebase
        # cred = credentials.Certificate("C:/Users/fanda/Documents/SUTD SOAR/Meetup Mouse/meetup-mouse-265200-2bcf88fc79cc.json")
        cred = credentials.Certificate("C:/Users/Andrew/Desktop/Meetup-App/API/meetup-mouse-265200-2bcf88fc79cc.json")
        firebase_admin.initialize_app(cred)
        database = firestore.client()

        self.bugReports = database.collection(u'bugReports')          # self.bugReports = collection for bugReports

    # Function to send bug reports to firebase\
    def send_bug_report(self, content):
        report = {
            u'content': content,
            u'timestamp': firestore.SERVER_TIMESTAMP
        }
        database = firestore.client()
        database.collection(u'bugReports').add(report)
