# Google API usaged from Tasmote via Berry

[return to modules](../README.md)
[Home](../../README.md)

[Download this googleapis folder complete](https://download-directory.github.io/?url=https://github.com/tasmota/Berry_playground/tree/main/modules/googleapis)

Originator: btsimonh

Any and all contributions welcome without specific consultation.  I don't consider this module to be production quality.

There is a [Discussion](https://github.com/tasmota/Berry_playground/discussions/15) - a good place to make suggestions, observations, etc. - please note there it you use the code, and if so, what for?


## Files in this folder relate to the use of Google APIs from Tasmota.

From information gleaned from [here](https://medium.com/@nschairer/automating-google-drive-uploads-with-google-drive-api-curl-196989ffb6ce) we find that you can authorise access to google APIs using a service account.

With a focus on wanting to upload images to a folder in my personal Google Drive, I persued this.  Following the link above, first you create a Service account in the Google cloud console, then share a folder from your personal drive with the service account email.  Then from the service account, add an API key, and download the JSON file.

I stored this json file in the Tasmota filesystem.  From the content of the JSON, we create a JWT, and sign it with one of the keys in the JSON file (thankyou to @s-hadinger for adding the required signing features in latest dev branch).  This JWT is then used to request an access token from google, with which you can then access the APIs.

The google API documentation is not great - it's quite hard to find out how to use it without using a library.

### Requirements

Ensure that yout TAS is latest dev branch, and has at least:
```
#define USE_BERRY_CRYPTO_RSA
#define USE_WEBCLIENT_HTTPS
#define USE_WEBCLIENT
```
(USE_BERRY_CRYPTO_RSA is new, my webcam based one was missing USE_WEBCLIENT, USE_WEBCLIENT_HTTPS?)


### Files:

#### [googleoauth.be](./googleoauth.be)
This provides the authorisation features.  Load the file into Berry.  Save your JSON key file to the TAS filesystem.

Usage:

Create an auth object using `var auth = google_oauth(<json filename>, <desired scope>)` e.g.:

`var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");`

For google drive use, the auth object is passed into a google_drive object to provide for getting an access token when needed.  Internally, the google_drive module calls auth.add_access_key(client) to add the auth header to a webclient instance.  A new access_token is only obtained when required, so an auth object can be long lived.  By default, 1 hour is requested on a token.  If the token is with ~10s of expirey, the auth module asks for a new one.

Note: various places suggest you can get an equivalent token by creating an APP, and using a single time OAuth mechanism to give access to your personal Google Drive.  However, I've not looked into this, and other posts suggest you can no longer do this easily.

#### [googledrive/](./googledrive/)

This folder contains files related to use with google drive.

#### [examples/](./examples/)

This folder contains random examples of use.  Please contribute...


### Acknowledgements

Without @s-hadinger adding RS256 signature capability to Berry, this would not be achievable.
