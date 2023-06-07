

var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");
var gdrive = google_drive(auth)
gdrive.cleanservicefiles(true)

