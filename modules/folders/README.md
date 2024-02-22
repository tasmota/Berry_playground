# Google API usage from Tasmote via Berry

[return to modules](../README.md)
[Home](../../README.md)

[Download this 'folders' folder complete](https://download-directory.github.io/?url=https://github.com/tasmota/Berry_playground/tree/main/modules/folders)

Originator: btsimonh

For [Questions and Discussion about this module](https://github.com/tasmota/Berry_playground/discussions/22) see this topic

Tas/Berry/Other features used:
* Tas filesystem

Any and all contributions welcome without specific consultation.  I don't consider this module to be production quality.

## Files in this folder relate to the use of folders from Berry in Tasmota.


### Requirements

Latest development version

### Files:

#### [zap.be](./zap.be)
This provides a zap(folder) function which will delete a folder and all content

* Stability: Fairly stable, pending feedback.

Usage:

zap(folder)

or 

zap(folder, true) - to get more feedback in logs


#### [testzap.be](./testzap.be)

Creates some folders and files and then zap them.

Example of usage of path.mkdir() and path.rmdir(), plus other file features.


### Acknowledgements


### Alternative approaches

None.  There was no folder manipulation in TAS.
