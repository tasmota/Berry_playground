## Files in this folder are random user examples relating to the use of Google API from Tasmota.

[return to googleapi](../README.md)
[Home](../../README.md)

The google API documentation is not great - it's quite hard to find out how to use it without using a library.  So if you use some feature you think is useful for someone else, please contribute an example resulting from your hours of research to help others.

### Files:

#### [gdrivepics.be](./gdrivepics.be)

* Stability: very unstable.  Do not expect this to work on your Tas.  Expect changes.  Use as example code only.

Grab pictures from a prototype modified webcam driver, and save them to Google Drive.  Uses bytes referencing native memory in Tas to grab image files as jpeg, and write them to a subfolder of the shared folder in google drive.

Requires [this driver](https://github.com/btsimonh/Tasmota/blob/webcam2023/tasmota/tasmota_xdrv_driver/xdrv_99_esp32_webcamberry.ino) which I hope to PR to Tas soon.

Features used:
* google_drive readdir/mkdir/writefile - query and file fields, binary write from bytes
* introspect/bytes from addr/len -> ismapped()=true
* tasmota.cmd()

Very prototype; may soon be updated to be a timelpase capture and  motion sensing capture in one.
