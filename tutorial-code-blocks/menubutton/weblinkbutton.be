import webserver

class weblinkbutton
    var link
    def init(url, text, newpage)
        var js = "window.open('" .. url .."'"
        if newpage
            js  = js .. ",'_blank'" 
        else
            js  = js .. ",'_self'" 
        end
        js = js .. ")"

        self.link = '<p></p><button onclick="' .. js .. '">' .. text .. '</button>'
        print(self.link)
    end

    def web_add_main_button()
        webserver.content_send(self.link)
    end
end


if global.link1
    tasmota.remove_driver(global.link1)
end
if global.link2
    tasmota.remove_driver(global.link2)
end

global.link1 = weblinkbutton('/bc?', 'Berry Console')
tasmota.add_driver(global.link1)
global.link2 = weblinkbutton('https://google.com', 'Google', 1)
tasmota.add_driver(global.link2)
