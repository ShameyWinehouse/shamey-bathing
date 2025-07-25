

BathingSessions = {}


RegisterServerEvent("rdr-bathing:canEnterBath")
AddEventHandler("rdr-bathing:canEnterBath", function(town)
    local _source = source

    if Config.DebugPrint then print("rdr-bathing:canEnterBath", town) end

    if not BathingSessions[town] then
        if takeMoney(_source, Config.NormalTubPrice) then
            BathingSessions[town] = _source
            TriggerClientEvent("rdr-bathing:StartBath", _source, town)
        end
    else
        VORPcore.NotifyRightTip(_source, "This bathtub is currently occupied.", 6 * 1000)
    end
end)


RegisterServerEvent("rdr-bathing:canEnterDeluxeBath")
AddEventHandler("rdr-bathing:canEnterDeluxeBath", function(animscene, town, cam)
    local _source = source

    if Config.DebugPrint then print("rdr-bathing:canEnterDeluxeBath", animscene, town, cam) end

    if BathingSessions[town] == _source then

        if takeMoney(_source, Config.DeluxeTubPrice) then
            TriggerClientEvent("rdr-bathing:StartDeluxeBath", _source, animscene, town, cam)
        else
            TriggerClientEvent("rdr-bathing:HideDeluxePrompt", _source)
        end

    end
end)

RegisterServerEvent("rdr-bathing:setBathAsFree")
AddEventHandler("rdr-bathing:setBathAsFree", function(town)
    local _source = source

    if Config.DebugPrint then print("rdr-bathing:setBathAsFree", town) end

    if BathingSessions[town] == _source then
        BathingSessions[town] = nil
    end
end)

AddEventHandler("playerDropped", function()
    local _source = source

    for town,player in pairs(BathingSessions) do
        if player == _source then
            BathingSessions[town] = nil
        end
    end
end)



--------

function takeMoney(targetNetId, amount)
    local Character = VORPcore.getUser(targetNetId).getUsedCharacter
    local money = Character.money

    amount = tonumber(amount)

    -- Check that they have the schmoney
    if money < amount then
        VORPcore.NotifyRightTip(targetNetId, string.format("You don't have $%.2f!", amount), 20 * 1000)
        return false
    end

    Character.removeCurrency(0, amount)

    -- VORPcore.NotifyRightTip(targetNetId, string.format("You have paid $%.2f.", amount), 6 * 1000)

    return true
end


--------

