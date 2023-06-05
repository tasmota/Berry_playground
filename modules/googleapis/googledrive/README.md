## Files in this folder relate to the use of Google Drive API from Tasmota.

The google API documentation is not great - it's quite hard to find out how to use it without using a library.

**BEWARE - files written are OWNED b the service account. i.e. they are NOT 'in' your drive - they are in the service account's drive.  Hence if you remove them from your drive, they still exist...  and I don't know if as a user, you can delete them?**

**Edit: note new delete functions, and cleanservicefiles**

### Files:

#### [gdrive.be](./gdrive.be)
This provides the Google Drive features.  Load the file into Berry.

Usage:

Create an auth object using `var auth = google_oauth(<json filename>, "https://www.googleapis.com/auth/drive")` e.g.:

`var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");`

Create a gdrive object using `var gdrive = google_drive(auth)` 

To write a file to a folder which has been shared with your service account, you need the folderID (the number in the link when you look at the folder in google drive).  To write to a file, use `gdrive.write(folder_id, 'mytestfile.txt', "text text or bytes")`

To delete a file use `gdrive.delete(fileId)`

To list a folder `def readdir(folderid, query, fields, pageSize, pageToken)` (limited to 10 files if pageSize falsy)

query, fields, pageSize, pageToken are optional.  Check the source/examples for thier use.

To get the folder(s) that a file is in `gdrive.getparents(fileid)`

To create a folder `gdrive.mkdir(infolderid, name)`. infolderid should be the id of the folder to create it in.  For example a folder shared from your personal GDrive.

To read informaiton about a file `getfiledetails(fileid)`

To read file data `readfileasstring(fileid)`

To delete all files which belong to the service account, but are no longer referenced by a folder `gdrive.cleanservicefiles()` (will be slow, could blow memory away?).

Example:
```
var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");
var gdrive = google_drive(auth)
var resp = gdrive.write(folder_id, 'mytestfile.txt', "text text or bytes")
print(resp)
```

#### [gdrivetest.be](./gdrivetest.be)

A number of example calls setup so they can be run simply - a kind of tester.
