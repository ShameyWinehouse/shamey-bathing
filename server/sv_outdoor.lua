


-------- THREADS

Citizen.CreateThread(function()
    -- register single soap item
	--Citizen.Wait(2000)
    --VorpInv.RegisterUsableItem(Config.ItemNameSoap, function(data)
    --    if Config.DebugPrint then print("RegisterUsableItem - data:", data) end
    --    TriggerClientEvent("rainbow_bathing:SoapUseAttempt", data.source, data)
    --    VorpInv.CloseInv(data.source)
    --end)

    -- for loop to register each item in arr
    for _, v in pairs(Config.ItemNameSoaps) do
        Citizen.Wait(2000)
        VorpInv.RegisterUsableItem(v, function(data)
            if Config.DebugPrint then print("RegisterUsableItem - data:", data) end
            TriggerClientEvent("rainbow_bathing:SoapUseAttempt", data.source, data)
            VorpInv.CloseInv(data.source)
        end)
    end
end)



-------- EVENTS

RegisterNetEvent("rainbow_bathing:Server:SoapUseSuccess", function(data)
    local _source = source

    if Config.DebugPrint then print("rainbow_bathing:Server:SoapUseSuccess", _source, data) end

    TriggerEvent("vorpCore:subItem", data.source, data.item.item, 1)
    VORPcore.NotifyRightTip(_source, string.format("You have used one %s.", data.item.label), 6 *
            1000)
end)