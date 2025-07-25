
local PromptGroupOutdoor
local PromptOutdoorWash
local PromptOutdoorHead
local PromptOutdoorLeftArm
local PromptOutdoorRightArm
local PromptOutdoorStop

isBathingOutdoors = false

local bathingOutdoorBodyPart = nil



-------- THREADS

CreateThread(function()

    Wait(10 * 1000)

    PromptGroupOutdoor = VORPutils.Prompts:SetupPromptGroup()
            
    PromptOutdoorWash = PromptGroupOutdoor:RegisterPrompt("Scrub", Config.Keys.Wash, 1, 1, true, "mash", {mashamount = Config.WashKeyMashAmount})
    PromptOutdoorHead = PromptGroupOutdoor:RegisterPrompt("Head", Config.Keys.Head, 1, 1, true, "click", {timedeventhash = "SHORT_TIMED_EVENT"})
    PromptOutdoorLeftArm = PromptGroupOutdoor:RegisterPrompt("Left Arm", Config.Keys.LeftArm, 1, 1, true, "click", {timedeventhash = "SHORT_TIMED_EVENT"})
    PromptOutdoorRightArm = PromptGroupOutdoor:RegisterPrompt("Right Arm", Config.Keys.RightArm, 1, 1, true, "click", {timedeventhash = "SHORT_TIMED_EVENT"})
    PromptOutdoorStop = PromptGroupOutdoor:RegisterPrompt("Finish", Config.Keys.Stop, 1, 1, true, "hold", {timedeventhash = "SHORT_TIMED_EVENT"})

    while true do
        
        local sleep = 1000

        if loaded then

            if isBathingOutdoors then

                sleep = 1

                PromptGroupOutdoor:ShowGroup("Outdoor Bathing")

                if bathingOutdoorBodyPart == BODY_PARTS.HEAD then

                    PromptSetEnabled(PromptOutdoorWash.Prompt, true)

                    PromptOutdoorHead:TogglePrompt(false)
                    PromptSetEnabled(PromptOutdoorHead.Prompt, false)

                    PromptOutdoorLeftArm:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorLeftArm.Prompt, true)

                    PromptOutdoorRightArm:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorRightArm.Prompt, true)

                elseif bathingOutdoorBodyPart == BODY_PARTS.LEFT_ARM then

                    PromptSetEnabled(PromptOutdoorWash.Prompt, true)

                    PromptOutdoorHead:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorHead.Prompt, true)

                    PromptOutdoorLeftArm:TogglePrompt(false)
                    PromptSetEnabled(PromptOutdoorLeftArm.Prompt, false)

                    PromptOutdoorRightArm:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorRightArm.Prompt, true)

                elseif bathingOutdoorBodyPart == BODY_PARTS.RIGHT_ARM then

                    PromptSetEnabled(PromptOutdoorWash.Prompt, true)

                    PromptOutdoorHead:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorHead.Prompt, true)

                    PromptOutdoorLeftArm:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorLeftArm.Prompt, true)

                    PromptOutdoorRightArm:TogglePrompt(false)
                    PromptSetEnabled(PromptOutdoorRightArm.Prompt, false)

                else

                    PromptSetEnabled(PromptOutdoorWash.Prompt, false)

                    PromptOutdoorHead:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorHead.Prompt, true)

                    PromptOutdoorLeftArm:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorLeftArm.Prompt, true)

                    PromptOutdoorRightArm:TogglePrompt(true)
                    PromptSetEnabled(PromptOutdoorRightArm.Prompt, true)

                end

                if PromptOutdoorHead:HasCompleted() then
                    OutdoorSwitchBodyPart(BODY_PARTS.HEAD)
                end

                if PromptOutdoorLeftArm:HasCompleted() then
                    OutdoorSwitchBodyPart(BODY_PARTS.LEFT_ARM)
                end

                if PromptOutdoorRightArm:HasCompleted() then
                    OutdoorSwitchBodyPart(BODY_PARTS.RIGHT_ARM)
                end

                if PromptOutdoorStop:HasCompleted() then
                    SetIsBathing(false)
                    isBathingOutdoors = false
                    ClearPedTasks(PlayerPedId())
                end
                

                if PromptOutdoorWash:HasCompleted() then
                    -- Trigger small increase in cleanliness
                    IncreaseCleanliness(Config.WashIncreaseAmount)
                end

            end

        end

        Wait(sleep)

    end
end)


-------- EVENTS

RegisterNetEvent("rainbow_bathing:SoapUseAttempt", function(data)

	if Config.DebugPrint then print("rainbow_bathing:SoapUseAttempt - data:", data) end

    if not playerCoords then
        return
    end

    -- Check not "occupied"
    local isPlayerOccupied = not RainbowCore.CanPedStartInteraction(PlayerPedId())
    if isPlayerOccupied then
        VORPcore.NotifyRightTip("You cannot wash while occupied.", 6 * 1000)
        return
    end

    if playerIsInWater then
        if IsEntityInWater(PlayerPedId()) then
            DisarmPlayer()
            TriggerServerEvent("rainbow_bathing:Server:SoapUseSuccess", data)
            StartWash()
            return
        else
            VORPcore.NotifyRightTip("You must be in water to wash.", 6 * 1000)
        end
    else
        VORPcore.NotifyRightTip("You must be in water to wash.", 6 * 1000)
    end

    
end)


-------- FUNCTIONS


function StartWash(dict, anim)

    SetIsBathing(true)
    isBathingOutdoors = true

    ClearPedTasks(PlayerPedId())

    OutdoorSwitchBodyPart(BODY_PARTS.IDLE)

end

function OutdoorPlayAnimation(dict, anim)
    -- if Config.DebugPrint then print("OutdoorPlayAnimation", dict, anim) end

    RequestAnimDict(dict)

    while not (HasAnimDictLoaded(dict)) do
        Citizen.Wait(10)
    end

    TaskPlayAnim(PlayerPedId(), dict, anim, 1.0, 1.0, -1, 25, 1.0, true, 0, false, 0, false)
end

function OutdoorSwitchBodyPart(newBodyPart)

    if Config.DebugPrint then print("OutdoorSwitchBodyPart", newBodyPart) end

    bathingOutdoorBodyPart = newBodyPart

    -- Switch animation
    local animationConfig
    if newBodyPart == BODY_PARTS.HEAD then
        animationConfig = Config.Animations.Outdoors[BODY_PARTS.HEAD]
    elseif newBodyPart == BODY_PARTS.LEFT_ARM then
        animationConfig = Config.Animations.Outdoors[BODY_PARTS.LEFT_ARM]
    elseif newBodyPart == BODY_PARTS.RIGHT_ARM then
        animationConfig = Config.Animations.Outdoors[BODY_PARTS.RIGHT_ARM]
    else
        animationConfig = Config.Animations.Outdoors[BODY_PARTS.IDLE]
    end

    OutdoorPlayAnimation(animationConfig.dict, animationConfig.name)
end