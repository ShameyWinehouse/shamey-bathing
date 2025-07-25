--Class for characters statuses
function CharacterStatuses(source, identifier, charIdentifier, cleanliness)
    local self = {}

    self.identifier = identifier
    self.charIdentifier = charIdentifier
    self.cleanliness = cleanliness
    self.source = source

    
    self.Identifier = function()
        return self.identifier
    end

    self.CharIdentifier = function(value)
        if value ~= nil then
            self.charIdentifier = value
        end
        return self.charIdentifier
    end

    self.Cleanliness = function(value)
        if value ~= nil then self.cleanliness = value end
        return self.cleanliness
    end

    self.Source = function(value)
        if value ~= nil then
            self.source = value
        end
        return self.source
    end

    self.SaveNewCharacterStatusesInDb = function(cb)
        if Config.DebugPrint then print("self.SaveNewCharacterStatusesInDb") end
        MySQL.query("INSERT INTO character_statuses(`identifier`,`charidentifier`,`cleanliness`) VALUES (?,?,?)"
            ,
            { self.identifier, self.charIdentifier, tonumber(self.cleanliness) },
            function(character)
                cb(character.insertId)
            end)
    end

    self.SaveCharacterStatusesInDb = function()
        if Config.DebugPrint then print("self.SaveCharacterStatusesInDb") end
        MySQL.update("UPDATE character_statuses SET `cleanliness` = @cleanliness WHERE `identifier` = @identifier AND `charidentifier` = @charidentifier"
            ,
            { ["cleanliness"] = tonumber(self.cleanliness), ["identifier"] = tostring(self.identifier), ["charidentifier"] = self.charIdentifier }
        )
    end

    return self
end