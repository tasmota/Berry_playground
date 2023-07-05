#-----------------------------------
 dynamic class
     add dynamically at run time members to a class.
  Please read also 'virtual members' at https://berry.readthedocs.io/en/latest/source/en/Chapter-8.html#module-undefined     
------------------------------------#
class DynClass
    var xmap

    def init()
        self.xmap = {}
    end

    def setmember(name, value)
        self.xmap[name] = value
    end

    def member(name)
        if self.xmap.contains(name)
            return self.xmap[name]
        else
            import undefined
            return undefined
        end
    end

    # return members as json-string
    def toJson()
        return json.dump(self.xmap)
    end

    # load new members from json-string
    def loadJson(jsonString)
        self.xmap = json.load(jsonString)
    end
end