VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)
RainbowCore = exports["rainbow-core"]:initiate()


BODY_PARTS = {
    ["IDLE"] = "IDLE",
    ["HEAD"] = "HEAD",
    ["LEFT_ARM"] = "LEFT_ARM",
    ["RIGHT_ARM"] = "RIGHT_ARM",
}


local selectedCharacter = false
loaded = false
CharacterStatuses = {}

playerCoords = nil
playerIsInWater = true
isBathing = false

local fliesHandles = {}



if Config.DebugCommands then 

	RegisterCommand("startbathing", function(source, args)
		TriggerServerEvent("rainbow_bathing:GetStatus")
	end)

    RegisterCommand("debug:SetCleanliness", function(source, args)
		TriggerServerEvent("rainbow_bathing:Debug:SetCleanliness", args[1])
	end)

end


-------- THREADS

CreateThread(function()
    Wait(5000)
    while true do
        Wait(2000)

        if loaded then

            playerCoords = GetEntityCoords(PlayerPedId())

            local water = Citizen.InvokeNative(0x5BA7A68A346A5A91, playerCoords.x+3, playerCoords.y+3, playerCoords.z) -- GetWaterMapZoneAtCoords

            if IsEntityInWater(PlayerPedId()) and (water == 231313522 or 2005774838 or -1287619521 or -196675805 or -1308233316 or 1755369577 or -2040708515 or -557290573 or -247856387 or 370072007 or -1504425495 or -1369817450 or -1356490953 or -1781130443 or -1300497193 or -1276586360 or -1410384421 or 650214731 or 592454541 or -804804953 or 1245451421 or -218679770 or -1817904483 or -811730579 or -1229593481 or -105598602) then
                playerIsInWater = true
            else
                playerIsInWater = false
            end

            -- DEBUG
            -- 16 = SA_DIRTINESS
            -- 17 = SA_DIRTINESSHAT
            -- 22 = SA_DIRTINESSSKIN
            -- if Config.DebugPrint then print("GetAttributePoints - SA_DIRTINESS", GetAttributePoints(PlayerPedId(), 16)) end
            -- if Config.DebugPrint then print("GetAttributeRank - SA_DIRTINESS", GetAttributeRank(PlayerPedId(), 16)) end
            -- if Config.DebugPrint then print("GetAttributePoints - SA_DIRTINESSHAT", GetAttributePoints(PlayerPedId(), 17)) end
            -- if Config.DebugPrint then print("GetAttributeRank - SA_DIRTINESSHAT", GetAttributeRank(PlayerPedId(), 17)) end
            -- if Config.DebugPrint then print("GetAttributePoints - SA_DIRTINESSSKIN", GetAttributePoints(PlayerPedId(), 22)) end
            -- if Config.DebugPrint then print("GetAttributeRank - SA_DIRTINESSSKIN", GetAttributeRank(PlayerPedId(), 22)) end

            -- if Config.DebugPrint then print("GetPedDamageCleanliness", GetPedDamageCleanliness(PlayerPedId())) end

        end

    end
end)

function StartBathingUpdaterThread()
	-- Cleanliness decrement
    CreateThread(function()
        while true do

            Wait(Config.CleanlinessUpdateIntervalInSeconds * 1000)

            if loaded and playerCoords and not isBathing then
                
                -- Get the SA_DIRTINESS Attribute Rank
                local dirtnessOutOfEighty = GetAttributeRank(PlayerPedId(), 16)
                local newCleanliness = convertDirtinessRankToCleanliness(dirtnessOutOfEighty)

                -- Only *decrease* cleanliness
                if (newCleanliness < CharacterStatuses.cleanliness) then
                    TriggerServerEvent("rainbow_bathing:UpdateCleanliness", newCleanliness)
                end

                -- if Config.DebugPrint then print("dirtnessOutOfEighty, cleanliness", dirtnessOutOfEighty, newCleanliness) end

            end

        end
    end)
end

function StartBathingSaveDBThread()
    CreateThread(function()
        while true do

            if loaded then

                Wait(Config.DbUpdateIntervalInSeconds * 1000)

                TriggerServerEvent("rainbow_bathing:SaveLastStatus")

            end

        end
    end)
end

function StartRadarControlHudThread()
    CreateThread(function()
        while true do
            
            if loaded then

                Wait(1000)
                if (inTub == false and ((IsRadarHidden()) or (IsPauseMenuActive()) or (NetworkIsInSpectatorMode()) or (IsHudHidden()))) then
                    NUIEvents.HideHUD()
                else
                    NUIEvents.UpdateHUD(CharacterStatuses.cleanliness)
                end

            end

        end
    end)
end

if Config.DebugVisual then

    CreateThread(function()

        while true do

            Wait(500)

            TriggerEvent("rainbow_core:VisualDebugTool", {
                ["loaded"] = loaded,
                ["cleanliness"] = (CharacterStatuses and CharacterStatuses.cleanliness) or "?",
                ["isBathing"] = isBathing,
                ["isBathingOutdoors"] = isBathingOutdoors,
                ["playerIsInWater"] = playerIsInWater,
                -- ["shouldHaveFlies"] = shouldHaveFlies,
                ["inTub"] = inTub,
                ["SA_DIRTINESS"] = GetAttributeRank(PlayerPedId(), 16),
            })

        end
    end)
end



-------- EVENTS

RegisterNetEvent("vorp:SelectedCharacter", function(charId)

    -- It gets called twice for some reason?
    if selectedCharacter == true then
        return
    end

    selectedCharacter = true

    if Config.DebugPrint then print("vorp:SelectedCharacter") end

    if not loaded then
        CreateThread(function()
            Wait(15 * 1000)
            if not loaded then
                if Config.DebugPrint then print("triggering rainbow_bathing:GetStatus") end
                TriggerServerEvent("rainbow_bathing:GetStatus")
            end
        end)
    end
end)

RegisterNetEvent("rainbow_bathing:StartFunctions", function(_CharacterStatuses)

	if Config.DebugPrint then print("rainbow_bathing:StartFunctions", _CharacterStatuses) end

	CharacterStatuses = _CharacterStatuses

    -- Set the dirtiness Attribute points of the ped (from DB-saved)
    local dirtinessRank = convertCleanlinessToDirtinessRank(CharacterStatuses.cleanliness)
    local dirtinessPoints = dirtinessRank * 100
    SetAttributePoints(PlayerPedId(), 16, dirtinessPoints)

    Wait(200)

    -- Kick off the threads
	StartBathingUpdaterThread()
	StartBathingSaveDBThread()
	StartRadarControlHudThread()

    loaded = true
end)

RegisterNetEvent("rainbow_bathing:UpdateFliesList", function(stinkyPeople)

    if Config.DebugPrint then print("rainbow_bathing:UpdateFliesList", stinkyPeople) end

    for source,hasFlies in pairs(stinkyPeople) do

        if hasFlies == true then
            -- Check if not on list at all OR is on list but false
            if fliesHandles[source] == nil or fliesHandles[source] == false then
                local targetPed = GetPlayerPed(GetPlayerFromServerId(source))
                if Config.DebugPrint then print("rainbow_bathing:UpdateFliesList - targetPed", targetPed) end
                if targetPed and targetPed > 0 then
                    local fliesParticleFxHandle = RainbowCore.StartParticleFxSpecific(targetPed, "core", "ent_amb_insect_fly_swarm_shit", 0.0, -0.4, 0.3, -90.0, 0.0, 0.0, 0.8, 0, 0, 0)
                    fliesHandles[source] = fliesParticleFxHandle
                end
            -- else: they already have flies
            end
        else
            -- Remove and clear, if on list
            if fliesHandles[source] then
                if Config.DebugPrint then print("rainbow_bathing:UpdateFliesList - should remove", source) end
                if DoesParticleFxLoopedExist(fliesHandles[source]) then
                    RainbowCore.StopThisParticleFx(fliesHandles[source])
                end
                fliesHandles[source] = nil
            end
        end

    end

end)

RegisterNetEvent("rainbow_bathing:UpdateCharacterStatuses", function(_CharacterStatuses)

	if Config.DebugPrint then print("rainbow_bathing:UpdateCharacterStatuses", _CharacterStatuses) end

    CharacterStatuses = _CharacterStatuses

end)



-------- FUNCTIONS

function IncreaseCleanliness(amount)
    local newCleanliness = CharacterStatuses.cleanliness + amount
    TriggerServerEvent("rainbow_bathing:UpdateCleanliness", newCleanliness)

    if newCleanliness >= 100 then
        CompletelyClean()
    else
        -- Set the dirtiness Attribute points of the ped
        local dirtinessRank = convertCleanlinessToDirtinessRank(newCleanliness)
        local dirtinessPoints = dirtinessRank * 100
        SetAttributePoints(PlayerPedId(), 16, dirtinessPoints)
    end
end

function CompletelyClean()
    local playerPedId = PlayerPedId()
    Citizen.InvokeNative(0x6585D955A68452A5, playerPedId) -- ClearPedEnvDirt
    Citizen.InvokeNative(0x9C720776DAA43E7E, playerPedId) -- ClearPedWetness
    Citizen.InvokeNative(0x8FE22675A5A45817, playerPedId) -- ClearPedBloodDamage
    N_0xe3144b932dfdff65(playerPedId, 0.0, -1, 1, 1) -- SetPedDirtCleaned
    ClearPedDamageDecalByZone(playerPedId, 10, "ALL")
    Citizen.InvokeNative(0x7F5D88333EE8A86F, playerPedId, 1) -- ClearPedBloodDamageFacial
end

function DisarmPlayer()
	-- Unarm the player so the weapon doesn't interfere
	Citizen.InvokeNative(0xFCCC886EDE3C63EC, PlayerPedId(), 2, true) -- HidePedWeapons
end

function convertDirtinessRankToCleanliness(dirtnessOutOfEighty)
    local dirtnessScaled = math.ceil(dirtnessOutOfEighty * 1.25)
    local cleanliness = 100 - dirtnessScaled
    -- if Config.DebugPrint then print("convertDirtinessRankToCleanliness", dirtnessOutOfEighty, cleanliness) end
    return cleanliness
end

function convertCleanlinessToDirtinessRank(cleanlinessOutOfOneHundred)
    local cleanlinessScaled = math.floor(cleanlinessOutOfOneHundred / 1.25)
    local dirtinessRank = 80 - cleanlinessScaled
    -- if Config.DebugPrint then print("convertCleanlinessToDirtinessRank", cleanlinessOutOfOneHundred, dirtinessRank) end
    return dirtinessRank
end

function SetIsBathing(_isBathing)
    isBathing = _isBathing
    LocalPlayer.state.isBathing = _isBathing
end


--------

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() == resourceName then

        -- TODO
        -- shouldHaveFlies = false
        -- fliesParticleFxHandle = nil
        fliesHandles = {}
        ClearPedTasks(PlayerPedId())
        
    end

end)