# Google API usage from Tasmote via Berry

[return to modules](../README.md)
[Home](../../README.md)

[Download this googleapis folder complete](https://download-directory.github.io/?url=https://github.com/tasmota/Berry_playground/tree/main/modules/googleapis)
For [Questions and Discussion about this module](https://github.com/tasmota/Berry_playground/discussions/15) see this topic


Originator: btsimonh, guidance/tas-dev by s-hadinger

Tas/Berry/Other features used:
* Tas crypto
* Tas filesystem
* json/map/class
* base64 (url form!)
* JWT token creation
* webclient GET/POST/PATCH/DELETE, headers
* Tas rtc()

Any and all contributions welcome without specific consultation.  I don't consider this module to be production quality.

There is a [Discussion](https://github.com/tasmota/Berry_playground/discussions/15) - a good place to make suggestions, observations, etc. - please note there if you use the code, and if so, what for?

## Files in this folder relate to the use of Google APIs from Tasmota.

_This is not necessarily the best approach to write to google drive from Tas (see Alternative approaches below), but it's about the journey not the result, and the generality of being able to access any google API opens a range of possibilities, google drive being only one of many._

From information gleaned from [here](https://medium.com/@nschairer/automating-google-drive-uploads-with-google-drive-api-curl-196989ffb6ce) we find that you can authorise access to google APIs using a service account.  I'll not repeat the procudure for creating a service account here...

With a focus on wanting to upload images to a folder in my personal Google Drive, I persued this.  Following the link above, first you create a Service account in the Google cloud console, add the google APIs you wish to use (in my case, drive) to a 'project', give the service account access to the project.  For google drive, I then shared a folder (editor access) from my personal gdrive with the service account email.  Then from the service account, add an API key, and download the JSON file.

I stored this json file in the Tasmota filesystem.  From the content of the JSON, we create a JWT, and sign it with one of the keys in the JSON file (thankyou to @s-hadinger for adding the required signing features in latest dev branch).  This JWT is then used to request an access token from google, with which you can then access the APIs.

The google API documentation is not great - it's quite hard to find out how to use it without using a library, as there are very few REST examples.

### Requirements

Ensure that yout TAS is latest dev branch, and has at least:
```
#define USE_BERRY_CRYPTO_RSA
#define USE_WEBCLIENT_HTTPS
#define USE_WEBCLIENT
```
(USE_BERRY_CRYPTO_RSA is new, my webcam based config was missing USE_WEBCLIENT, USE_WEBCLIENT_HTTPS?)

### Files:

#### [googleoauth.be](./googleoauth.be)
This provides the authorisation features.  Load the file into Berry.  Save your JSON key file to the TAS filesystem.

* Stability: Fairly stable, pending feedback.

Usage:

Create an auth object using `var auth = google_oauth(<json filename>, <desired scope(s)>)` e.g.:

`var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");`

_Note: this will do nothing until auth.add_access_key(client) is called.  You can test or pre-get a token using `auth.get_oath_token(3600) print(auth.access_token)`_

[see here for scopes?](https://developers.google.com/identity/protocols/oauth2/scopes) - It appears you may have multiple, comma delimited, scopes - I have not tried this.

For google drive use, the auth object is passed into a google_drive object to provide for getting an access token when needed.  Internally, the google_drive module calls auth.add_access_key(client) to add the auth header to a webclient instance.  A new access_token is only obtained when required, so an auth object can be long lived.  By default, 1 hour is requested on a token.  If the token is with ~10s of expirey, the auth module asks for a new one.

You may create multiple auth objects for different purposes.

Note: various places suggest you can get an equivalent token by creating an APP, and using a single time OAuth mechanism to give access to your personal Google Drive.  However, I've not looked into this, and other posts suggest you can no longer do this easily.  If you try and succeed with this method, please PR a description. _(if you do this, be VERY careful with google_drive.cleanservicefiles(confirm), as it is capable of deleting your entire drive contents)._

#### [googledrive/](./googledrive/)

This folder contains files related to use with google drive.

#### [examples/](./examples/)

This folder contains random examples of use.  Please contribute...


### Acknowledgements

Thanks go to @s-hadinger who added RS256 signature capability to Berry, making this achievable.

### Alternative approaches

in the [original discussion](https://github.com/arendst/Tasmota/discussions/18758) @barbudor highlighted a much lower impact approach documented [here as text](https://www.electroniclinic.com/esp32-cam-send-images-to-google-drive-iot-security-camera/) and [here on youtube](https://youtu.be/9BOYOMEJXUg)
This is to create a Google Apps Script which accepts images on a public URL, and saves them to your personal drive.  I'm sure the code could be improved to have some simple 'authentication' and to be more efficient by accepting binary images, but it is a working example of avoiding the complexity of google APIs drive direct from Tas Berry.
