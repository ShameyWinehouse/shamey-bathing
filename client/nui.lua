NUIEvents = {}


NUIEvents.UpdateHUD = function(cleanliness)

	-- if Config.DebugPrint then print("NUIEvents.UpdateHUD", cleanliness) end

	if not cleanliness then return end

	SendNUIMessage({
        type = "update",
        cleanliness = cleanliness,
    })
end

NUIEvents.HideHUD = function()

	-- if Config.DebugPrint then print("NUIEvents.HideHUD") end

	SendNUIMessage({
        type = "hide",
    })
end
