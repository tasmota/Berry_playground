## Files in this folder relate to the use of Google Drive API from Tasmota.

[return to googleapi](../README.md)
[Home](../../README.md)

The google API documentation is not great - it's quite hard to find out how to use it without using a library.

**BEWARE - files written are OWNED b the service account. i.e. they are NOT 'in' your drive - they are in the service account's drive.  Hence if you remove them from your drive, they still exist...  and I don't know if as a user, you can delete them manually?**

**Edit: note new delete functions, and cleanservicefiles**

### Files:

#### [gdrive.be](./gdrive.be)
This provides the Google Drive features.  Load the file into Berry.

* Stability: unstable, pending discussion.  Expect changes

Consider this prototype, suiting my use case of creating folders and files within a shared folder of my personal GDrive for the purpose of uploading timelapse images and motion detected images from a modified webcam driver.  Also as a full example of googleoauth use.

TODO: 
* there is a mix of v3 and v2 api calls.  Replace all with v3 and re-test.
* get feedback on function parameters and returns, discuss and rationalise

### Usage:

Create an auth object using `var auth = google_oauth(<json filename>, "https://www.googleapis.com/auth/drive")` e.g.:

`var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");`

Create a gdrive object using `var gdrive = google_drive(auth)` 

#### `gdrive.write(folder_id, 'mytestfile.txt', "text text or bytes")`
Write a file to a folder which has been shared with your service account - you need the folderID (the number in the link when you look at the folder in google drive).

Currently returns google's response as a string.  If the write fails, it will print() the response, and print() failure

Files written will be visible to you in your gdrive (if in a shared folder or subfolder), but are owned by the service account.

#### `gdrive.delete(fileId)`
Returns true on success, else false and print() failure details

#### `gdrive.readdir(folderid, query, fields, pageSize, pageToken)`
* query - optional, should be urlencoded, prepended with `q=`
* fields - optional, note style `file(id,name)`, changes the fields returned per file.
* pageSize - optional, count of files to retrieve in one hit.  Defaults to 10
* pageToken - optional, to continue a list, pass in nextPageToken from response (see [./gdrivetest.be](./gdrivetest.be) for an example)
_Note: pass `nil` for optional arguments if you need an argument later in the list_

Returns the google response as a map.  like { files:[{name:"fred", id:"12345577",kind:"drive#file", mimeType:"xyz"}], nextPageToken } 

#### `gdrive.getparents(fileid)`
Get the folder(s) that a file is in. (not really required, since you can use `readdir(folderid, "name%20=%20%27<filename>%27", "files(parents,<other fields>)")`.

Returns the google response as a map.

#### `gdrive.mkdir(infolderid, name)`
* infolderid should be the id of the folder to create it in.  For example a folder shared from your personal GDrive.
* folders created inside your shared folder will be visible to you, but are owned by the service account.

Returns id of new folder or nil.  print() on success or failure.

#### `gdrive.getfiledetails(fileid)`
Returns the google response as a map - a File object on success.  print() on failure.

#### `gdrive.readfileasstring(fileid)`
Returns the file contents as a string or nil on failure. print() on failure

(no way to currently get binary data in Tas Berry) ...)

#### `gdrive.cleanservicefiles(confirm)`
*** BEWARE - if used from a USER account, this could empty your GDrive ***
Deletes the first 10 files/folders which are owned by the authorising account, and are in the 'root' folder.

Rational: The files created here are owned by the service account.  As a user you cannot delete them, only de-reference them.  The service account also cannot change the ownership to your user account.  Therefore, we need some way to remove unused files from the service account.  Once, as a user, you have 'deleted' the files or folder, they appear in the service user's root folder (if they are in a folder, they do NOT appear in the service root folder).  So by finding files which are in the service root folder, and owned by the service, we know we can delete them (assuming you did create them inside a shared folder originally).  Also, if you delete a folder as a user without deletign the files, then the folder is in service root, but the files not - until the foolder is deleted.

You can call this function regularly to keep the service account clean.  But understand it first...

_(files in the 'root' folder of the service account are not in any folder.  i.e. have been removed from the Consumer user's GDrive)_

Call with confirm false to print() the files which would be deleted.

Call with confirm true to delete the files.

### Example:
```
var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");
var gdrive = google_drive(auth)
var resp = gdrive.write(folder_id, 'mytestfile.txt', "text text or bytes")
print(resp)
```
#### [gdrivetest.be](./gdrivetest.be)

A number of example calls setup so they can be run simply - a kind of tester.

**NOTE: Change the shared folder ID before you call anything!!!**
