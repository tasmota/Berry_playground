# Menu Buttons examples

[return to tutorial-code-blocks](../README.md) - [home](/README.md)

[Discussion about menubutton](https://github.com/tasmota/Berry_playground/discussions/23) - [download all of menubutton](https://download-directory.github.io/?url=https://github.com/tasmota/Berry_playground/tree/main/tutorial-code-blocks/menubutton)

## [weblinkbutton.be](weblinkbutton.be)

This short class adds a button to the main Tasmota menu, which when clicked, opens a link, either in the same or a new tab.

It simply demonstrates a practical use of maoin menu buttons.

Example which adds a direct link to the Berry console, opening in the same tab, and a link to google opening a new tab:

```
# remove the 'drivers' if they existed.
if global.link1 tasmota.remove_driver(global.link1) end
if global.link2 tasmota.remove_driver(global.link2) end

# add 'drivers', one for each button, and store in glbal variavbles so they can be removed/replaced
global.link1 = weblinkbutton('/bc?', 'Berry Console')
tasmota.add_driver(global.link1)
global.link2 = weblinkbutton('https://google.com', 'Google', 1)
tasmota.add_driver(global.link2)

```
