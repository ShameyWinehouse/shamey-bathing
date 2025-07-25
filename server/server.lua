VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)

VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local characters = {}

local stinkyPeople = {}


-------- THREADS

Citizen.CreateThread(function()
    Citizen.Wait(10 * 1000)
    while true do
        Citizen.Wait(10 * 1000)

        TriggerClientEvent("rainbow_bathing:UpdateFliesList", -1, stinkyPeople)
    end
end)


-------- EVENTS

RegisterNetEvent("rainbow_bathing:UpdateCleanliness", function(newCleanliness)
    local _source = source
    local UserCharacter = VORPcore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]

    if Config.DebugPrint then print("rainbow_bathing:UpdateCleanliness", newCleanliness) end

    if not CharacterStatuses then
        return
    end

    local cleanliness = CharacterStatuses.cleanliness


    -- Limit the new cleanliness number
    if newCleanliness > 100 then
        newCleanliness = 100
    end
    if newCleanliness < 0 then
        newCleanliness = 0
    end

    -- Update the cleanliness
    characters[UserCharacter.identifier].Cleanliness(newCleanliness)

    TriggerClientEvent("rainbow_bathing:UpdateCharacterStatuses", _source, characters[UserCharacter.identifier])


    if tonumber(newCleanliness) <= tonumber(Config.FliesThreshold) then
        -- Kick off the flies
        stinkyPeople[_source] = true
    else
        stinkyPeople[_source] = false
    end

 
end)

RegisterNetEvent("rainbow_bathing:Debug:SetCleanliness", function(amount)
    local _source = source
    local UserCharacter = VORPcore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]

    if Config.DebugPrint then print("rainbow_bathing:Debug:SetCleanliness", amount) end

    characters[UserCharacter.identifier].Cleanliness(tonumber(amount))

    characters[UserCharacter.identifier].SaveCharacterStatusesInDb()

    TriggerClientEvent("rainbow_bathing:UpdateCharacterStatuses", _source, characters[UserCharacter.identifier])

    CreateThread(function()
        Wait(5000)
        if tonumber(amount) <= tonumber(Config.FliesThreshold) then
            -- Kick off the flies
            stinkyPeople[_source] = true
        else
            stinkyPeople[_source] = false
        end
    end)

end)

RegisterNetEvent("rainbow_bathing:SaveLastStatus", function()
    local _source = source
    local UserCharacter = VORPcore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]

    if Config.DebugPrint then print("rainbow_bathing:SaveLastStatus", _source) end

    if CharacterStatuses then
        CharacterStatuses.SaveCharacterStatusesInDb()
    end
    
end)

RegisterNetEvent("rainbow_bathing:GetStatus", function()
    local _source = source
    local UserCharacter = VORPcore.getUser(_source).getUsedCharacter

    if Config.DebugPrint then print("rainbow_bathing:GetStatus", _source) end

    loadCharacterStatus(_source)

    Wait(200)

    local CharacterStatuses = characters[UserCharacter.identifier]

    if Config.DebugPrint then print("rainbow_bathing:GetStatus - CharacterStatuses", CharacterStatuses) end

    if not CharacterStatuses then
        print("ERROR: Couldn't load CharacterStatuses.", _source)
        return
    end

    TriggerClientEvent("rainbow_bathing:StartFunctions", _source, CharacterStatuses)

    if CharacterStatuses and CharacterStatuses.cleanliness ~= nil then
        if tonumber(CharacterStatuses.cleanliness) <= tonumber(Config.FliesThreshold) then
            -- Kick off the flies
            stinkyPeople[_source] = true
        else
            stinkyPeople[_source] = false
        end
    end
end)



-------- FUNCTIONS

function loadCharacterStatus(_source)

    if Config.DebugPrint then print("loadCharacterStatus()", _source) end

    local UserCharacter = VORPcore.getUser(_source).getUsedCharacter

    local result_promise = promise.new()
    MySQL.single("SELECT * FROM character_statuses WHERE `identifier` = @identifier AND charidentifier = @charidentifier", 
        { ['@identifier'] = UserCharacter.identifier, ['@charidentifier'] = UserCharacter.charIdentifier }, 
        function(result)
            if Config.DebugPrint then print("loadCharacterStatus() - result", result) end

            if result then
                characters[UserCharacter.identifier] = CharacterStatuses(_source, UserCharacter.identifier, UserCharacter.charIdentifier, tonumber(result.cleanliness))
            else
                characters[UserCharacter.identifier] = CharacterStatuses(_source, UserCharacter.identifier, UserCharacter.charIdentifier, 100)
                characters[UserCharacter.identifier].SaveNewCharacterStatusesInDb(function() end)
            end
            if Config.DebugPrint then print("loadCharacterStatus() - CharacterStatuses", characters[UserCharacter.identifier]) end
            result_promise:resolve()
    end)
    return Citizen.Await(result_promise)
end