MenuData = {}
TriggerEvent('redemrp_menu_base:getData',function(call)
	MenuData = call
end)


BathingPed = nil
inTub = false
local isScriptedCamChosen = true
local currentTown

Citizen.CreateThread(function()
	-- CreateBlips()
	-- CloseBathDoors()
	if RegisterPrompts() then
		local bath = nil

		while true do
			bath = GetClosestConsumer()

			if loaded and bath then
				if not PromptsEnabled then TogglePrompts({ "START_BATHING" }, true) end
				if PromptsEnabled then
					if IsPromptCompleted("START_BATHING") then
						Action("START_BATHING", bath)
					end
				end
			else 
				if PromptsEnabled then TogglePrompts({ "START_BATHING" }, false) end
				Citizen.Wait(250) 
			end

			Citizen.Wait(100)
		end
	end
end)

local playerCoords = nil
GetClosestConsumer = function()
	playerCoords = GetEntityCoords(PlayerPedId())

	for townName,data in pairs(Config.BathingZones) do
        if #(playerCoords - data.consumer) < 1.3 then
			return townName
		end
    end
	return nil
end


CreateThread(function()
    while true do
        
        local sleep = 500

        if inTub then

            sleep = 0

            -- Block inputs
            DisableAllControlActions(0)
            EnableControlAction(0, Config.Keys.TakeABath)
            EnableControlAction(0, `INPUT_SHOP_BUY`)
            EnableControlAction(0, `INPUT_CONTEXT_X`)
            EnableControlAction(0, `INPUT_INTERACT_NEG`)
            EnableControlAction(0, `INPUT_FRONTEND_RIGHT`)
            EnableControlAction(0, `INPUT_NEXT_CAMERA`)

            -- For selecting Deluxe Assistant:
            EnableControlAction(0, `INPUT_FRONTEND_UP`)
            EnableControlAction(0, `INPUT_FRONTEND_DOWN`)
            EnableControlAction(0, `INPUT_FRONTEND_ACCEPT`)

            EnableControlAction(0, 0x4BC9DABB, true) -- Enable push-to-talk
			EnableControlAction(0, 0xF3830D8E, true) -- Enable J for jugular
            -- Re-enable mouse
            EnableControlAction(0, `INPUT_LOOK_UD`, true) -- INPUT_LOOK_UD
            EnableControlAction(0, `INPUT_LOOK_LR`, true) -- INPUT_LOOK_LR
            -- For Admin Menu:
            EnableControlAction(0, `INPUT_CREATOR_RT`, true) -- PAGE DOWN

        end

        Wait(sleep)

    end
end)

CreateThread(function()
	Wait(5 * 1000)
    while true do
        
        local sleep = 3000

        if inTub then

			sleep = 500

			local isPlayerOccupied = not RainbowCore.CanPedStartInteraction(PlayerPedId())
			local isPlayerLassoed = IsPedLassoed(PlayerPedId()) ~= 0
			if Config.DebugPrint then print("isPlayerOccupied", isPlayerOccupied) end
			if Config.DebugPrint then print("isPlayerLassoed", isPlayerLassoed) end
            if isPlayerOccupied or isPlayerLassoed then
				print("abort bath")
				emergencyExitBath()
			end

        end

        Wait(sleep)

    end
end)



--------

RegisterNetEvent('rdr-bathing:StartBath')
AddEventHandler('rdr-bathing:StartBath', function(town)

	currentTown = town

	if Config.DebugPrint then print("rdr-bathing:canEnterBath", town) end

	inTub = true
	SetIsBathing(true)
	if Config.BathingZones[town] then
		SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true, 0, true, true)

		LoadAllStreamings()

		LoadModel(`P_CS_RAG02X`)
		local rag = CreateObject(`P_CS_RAG02X`, GetEntityCoords(PlayerPedId()), false, false, false, false, true)
		table.insert(Config.CreatedEntries, { type = "PED", handle = rag })
		SetModelAsNoLongerNeeded(`P_CS_RAG02X`)

		SetPedCanLegIk(PlayerPedId(), false)
		SetPedLegIkMode(PlayerPedId(), 0)
		ClearPedTasksImmediately(PlayerPedId(), true, true)

		local animscene = Citizen.InvokeNative(0x1FCA98E33C1437B3, Config.BathingZones[town].dict, 0, "s_regular_intro", false, true)
		SetAnimSceneEntity(animscene, "ARTHUR", PlayerPedId(), 0)
		SetAnimSceneEntity(animscene, "Door", N_0xf7424890e4a094c0(Config.BathingZones[town].door, 0), 0)
		
		LoadAnimScene(animscene)  
		while not Citizen.InvokeNative(0x477122B8D05E7968, animscene, 1, 0) do Citizen.Wait(10) end --// _IS_ANIM_SCENE_LOADED

		TriggerMusicEvent("MG_BATHING_START")
		StartAnimScene(animscene)

		while Citizen.InvokeNative(0x3FBC3F51BF12DFBF, animscene, Citizen.ResultAsFloat()) <= 0.3 do Citizen.Wait(0) end
		UndressCharacter()

		while not Citizen.InvokeNative(0xD8254CB2C586412B, animscene, true) do Citizen.Wait(0) end

		local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
		table.insert(Config.CreatedEntries, { type = "CAM", handle = cam })

		N_0x69d65e89ffd72313(true, true)
        SetCamCoord(cam, GetFinalRenderedCamCoord(), 0.0, 0.4, 0.5)
        SetCamRot(cam, GetFinalRenderedCamRot(1), 1)
        SetCamFov(cam, GetFinalRenderedCamFov())
        RenderScriptCams(true, true, 0, true, false, 0)
		isScriptedCamChosen = true

		TogglePrompts({ "STOP_BATHING", "REQUEST_DELUXE_BATHING", "SCRUB", "CAMERA" }, true)

		TriggerEvent("rdr-bathing:TASK_MOVE_NETWORK_BY_NAME_WITH_INIT_PARAMS", { PlayerPedId(), "Script_Mini_Game_Bathing_Regular", `CLIPSET@MINI_GAMES@BATHING@REGULAR@ARTHUR`, `DEFAULT`, "BATHING" })
		TriggerEvent("rdr-bathing:TASK_MOVE_NETWORK_ADVANCED_BY_NAME_WITH_INIT_PARAMS", { rag, "Script_Mini_Game_Bathing_Regular", `CLIPSET@MINI_GAMES@BATHING@REGULAR@RAG`, `DEFAULT`, "BATHING", { Config.BathingZones[town].rag.x, Config.BathingZones[town].rag.y, Config.BathingZones[town].rag.z }, Config.BathingZones[town].rag.w })	
		ForceEntityAiAndAnimationUpdate(rag, true);
		Citizen.InvokeNative(0x55546004A244302A, PlayerPedId())

		jo.notif.right("Tip: Hold down 'Scrub' non-stop through the entire bath.", "rpg_textures", "rpg_agitation", "COLOR_WHITE", 6 * 1000)

		local holdTime, bathMode = 0, 1
		while DoesCamExist(cam) do
			while not IsTaskMoveNetworkReadyForTransition(PlayerPedId()) do Citizen.Wait(100) end

			if IsPromptEnabled("SCRUB") and bathMode == #Config.BathingModes+1 then TogglePrompts({ "SCRUB" }, false) end
			if IsControlPressed(0, `INPUT_CONTEXT_X`) and IsPromptEnabled("SCRUB") then
				if IsPromptEnabled("REQUEST_DELUXE_BATHING") then TogglePrompts({ "REQUEST_DELUXE_BATHING" }, false) end

				while GetTaskMoveNetworkState(PlayerPedId()) ~= "Scrub_Idle" do
					RequestTaskMoveNetworkStateTransition(PlayerPedId(), "Scrub_Idle");
					RequestTaskMoveNetworkStateTransition((DoesEntityExist(BathingPed) and BathingPed) or rag, "Scrub_Idle");
					ClearPedEnvDirt(PlayerPedId())
					ClearPedBloodDamage(PlayerPedId())
					N_0xe3144b932dfdff65(PlayerPedId(), 0.0, -1, 1, 1)
					ClearPedDamageDecalByZone(PlayerPedId(), 10, "ALL")
					Citizen.InvokeNative(0x7F5D88333EE8A86F, PlayerPedId(), 1)
					Citizen.InvokeNative(0x9C720776DAA43E7E, PlayerPedId())
					Citizen.Wait(200)
				end

				while IsControlPressed(0, `INPUT_CONTEXT_X`) do
					if IsPromptCompleted("SCRUB") then
						if DoesEntityExist(BathingPed) and not Config.BathingModes[bathMode].deluxe then 
							bathMode = bathMode+1	
						end
						
						holdTime = holdTime + (Config.BathingModes[bathMode].hold_power or 0.01)

						if GetTaskMoveNetworkState(PlayerPedId()) ~= Config.BathingModes[bathMode].transition then
							SetCurrentCleaniest(rag, 0.0)
							ClearPedEnvDirt(PlayerPedId())
							ClearPedBloodDamage(PlayerPedId())
							N_0xe3144b932dfdff65(PlayerPedId(), 0.0, -1, 1, 1)
							ClearPedDamageDecalByZone(PlayerPedId(), 10, "ALL")
							Citizen.InvokeNative(0x7F5D88333EE8A86F, PlayerPedId(), 1)
							Citizen.InvokeNative(0x9C720776DAA43E7E, PlayerPedId())
							RequestTaskMoveNetworkStateTransition(PlayerPedId(), Config.BathingModes[bathMode].transition);
							RequestTaskMoveNetworkStateTransition((DoesEntityExist(BathingPed) and BathingPed) or rag, Config.BathingModes[bathMode].transition);					
						end

						SetTaskMoveNetworkSignalFloat(PlayerPedId(), "scrub_freq", Config.BathingModes[bathMode].scrub_freq);
						SetTaskMoveNetworkSignalFloat((DoesEntityExist(BathingPed) and BathingPed) or rag, "scrub_freq", Config.BathingModes[bathMode].scrub_freq);

						SetCurrentCleaniest(rag, holdTime)

						if holdTime >= 1.0 then
							holdTime = 0.0

							if bathMode+1 > #Config.BathingModes then

								jo.notif.rightSuccess("You are now clean as a whistle! You can exit, or stay & relax.")

								--GAME.PostToastNotification("bath_house", "Jesteś już czysty/a jak łza!", "Możesz opuścić wannę lub zostać i się odpręyć w gorącej wodzie.")  // link own notifications
								TogglePrompts({ "REQUEST_DELUXE_BATHING", "SCRUB" }, false)		

								IncreaseCleanliness(100)

								bathMode = #Config.BathingModes+1
								if DoesEntityExist(BathingPed) then
									Citizen.Wait(750) ExitPremiumBath(animscene, town, cam, true)
								end
							else
								bathMode = bathMode+1
								IncreaseCleanliness(20)
							end

							break 
						end
					end

					Citizen.Wait(100)
				end
				while not IsTaskMoveNetworkReadyForTransition(PlayerPedId()) do Citizen.Wait(10) end

				local resetTo = (((bathMode == #Config.BathingModes+1) or DoesEntityExist(BathingPed)) and "Bathing" or "Scrub_Idle")
				while GetTaskMoveNetworkState(PlayerPedId()) ~= resetTo do
					SetCurrentCleaniest(rag, 1.0)
					
					while GetTaskMoveNetworkState(PlayerPedId()) ~= "Scrub_Idle" do
						RequestTaskMoveNetworkStateTransition(PlayerPedId(), "Scrub_Idle");
						RequestTaskMoveNetworkStateTransition((DoesEntityExist(BathingPed) and BathingPed) or rag, "Scrub_Idle");
						-- ClearPedEnvDirt(PlayerPedId())
						-- ClearPedBloodDamage(PlayerPedId())
						-- N_0xe3144b932dfdff65(PlayerPedId(), 0.0, -1, 1, 1)
						-- ClearPedDamageDecalByZone(PlayerPedId(), 10, "ALL")
						-- Citizen.InvokeNative(0x7F5D88333EE8A86F, PlayerPedId(), 1)
						-- Citizen.InvokeNative(0x9C720776DAA43E7E, PlayerPedId())
						Citizen.Wait(200)
					end

					if resetTo ~= "Scrub_Idle" and (DoesEntityExist(BathingPed) and not IsControlPressed(0, `INPUT_CONTEXT_X`) or not DoesEntityExist(BathingPed)) then
						RequestTaskMoveNetworkStateTransition(PlayerPedId(), "Bathing");
						RequestTaskMoveNetworkStateTransition((DoesEntityExist(BathingPed) and BathingPed) or rag, "Bathing");
					elseif resetTo ~= "Scrub_Idle" and DoesEntityExist(BathingPed) and IsControlPressed(0, `INPUT_CONTEXT_X`) then
						resetTo = "Scrub_Idle"
					end

					Citizen.Wait(500)
				end
			end

			if IsPromptCompleted("REQUEST_DELUXE_BATHING") then
				if Config.DebugPrint then print("PromptCompleted: REQUEST_DELUXE_BATHING") end
				Action("REQUEST_DELUXE_BATHING", animscene, town, cam) 
				-- ClearPedEnvDirt(PlayerPedId())
				-- ClearPedBloodDamage(PlayerPedId())
				-- N_0xe3144b932dfdff65(PlayerPedId(), 0.0, -1, 1, 1)
				-- ClearPedDamageDecalByZone(PlayerPedId(), 10, "ALL")
				-- Citizen.InvokeNative(0x7F5D88333EE8A86F, PlayerPedId(), 1)
				-- Citizen.InvokeNative(0x9C720776DAA43E7E, PlayerPedId())
			end

			if IsPromptCompleted("STOP_BATHING") then
				Action("STOP_BATHING", animscene, town, cam)
				-- ClearPedEnvDirt(PlayerPedId())
				-- ClearPedBloodDamage(PlayerPedId())
				-- N_0xe3144b932dfdff65(PlayerPedId(), 0.0, -1, 1, 1)
				-- ClearPedDamageDecalByZone(PlayerPedId(), 10, "ALL")
				-- Citizen.InvokeNative(0x7F5D88333EE8A86F, PlayerPedId(), 1)
				-- Citizen.InvokeNative(0x9C720776DAA43E7E, PlayerPedId())
			end

			if IsPromptCompleted("CAMERA") then
				TogglePrompts({ "CAMERA" }, false)
				if isScriptedCamChosen == true then
					isScriptedCamChosen = false
					RenderScriptCams(false, false, 0, true, false, 0)
				else
					isScriptedCamChosen = true
					RenderScriptCams(true, true, 0, true, false, 0)
				end
				Wait(500)
				TogglePrompts({ "CAMERA" }, true)
			end

			Citizen.Wait(10)
		end
	end
end)

-- RegisterCommand("exitbath", function(source, args)
-- 	if inTub then 
-- 		RenderScriptCams(false, false, 0, true, false, 0)
-- 		DestroyCam(cam) 
-- 		ExecuteCommand('rc')
-- 		ExecuteCommand('sa')
-- 		SetEntityCoords(PlayerPedId(),-320.5,762.26,116.43)
-- 		UnloadAllStreamings()
-- 		TriggerMusicEvent("MG_BATHING_STOP")
-- 		TriggerServerEvent("rdr-bathing:setBathAsFree", town)
-- 		TogglePrompts("ALL", false)
-- 		N_0x69d65e89ffd72313(false, false)
-- 		Citizen.InvokeNative(0x704C908E9C405136, PlayerPedId())
-- 		SetPedCanLegIk(PlayerPedId(), true)
-- 		SetPedLegIkMode(PlayerPedId(), 2)
-- 		inTub = false
-- 		SetIsBathing(false)
-- 	end
-- end)



function emergencyExitBath()

	inTub = false
	SetIsBathing(false)

	RenderScriptCams(false, false, 0, true, false, 0)
	DestroyCam(cam)
	-- ExecuteCommand('rc')

	-- SetEntityCoords(PlayerPedId(),-320.5,762.26,116.43)

	UnloadAllStreamings()
	TriggerMusicEvent("MG_BATHING_STOP")
	TriggerServerEvent("rdr-bathing:setBathAsFree", currentTown)
	TogglePrompts("ALL", false)

	N_0x69d65e89ffd72313(false, false) -- RequestLetterBoxNow
	Citizen.InvokeNative(0x704C908E9C405136, PlayerPedId())

	SetPedCanLegIk(PlayerPedId(), true)
	SetPedLegIkMode(PlayerPedId(), 2)
	
	currentTown = nil
end

ExitBathing = function(animscene, town, cam)
	
	if DoesEntityExist(BathingPed) then
		ExitPremiumBath(animscene, town, cam)
		return
	end

	if Citizen.InvokeNative(0x25557E324489393C, animscene) then 
		Citizen.InvokeNative(0x84EEDB2C6E650000, animscene) --// _DELETE_ANIM_SCENE
	end

	local animscene = Citizen.InvokeNative(0x1FCA98E33C1437B3, Config.BathingZones[town].dict, 0,  "s_regular_outro", false, true)
	SetAnimSceneEntity(animscene, "ARTHUR", PlayerPedId(), 0)
	SetAnimSceneEntity(animscene, "Door", N_0xf7424890e4a094c0(Config.BathingZones[town].door, 0), 0)

	LoadAnimScene(animscene)  
	while not Citizen.InvokeNative(0x477122B8D05E7968, animscene, 1, 0) do Citizen.Wait(10) end --// _IS_ANIM_SCENE_LOADED
	StartAnimScene(animscene)

	if DoesCamExist(cam) then 
		RenderScriptCams(false, false, 0, true, false, 0)
		DestroyCam(cam) 
	end

	while Citizen.InvokeNative(0x3FBC3F51BF12DFBF, animscene, Citizen.ResultAsFloat()) <= 0.35 do Citizen.Wait(1) end
	DressCharacter()

	while not Citizen.InvokeNative(0xD8254CB2C586412B, animscene, true) do Citizen.Wait(10) end --// _IS_ANIM_SCENE_FINISHED
	
	UnloadAllStreamings()
	N_0x69d65e89ffd72313(false, false)
	TriggerMusicEvent("MG_BATHING_STOP")
	Citizen.InvokeNative(0x704C908E9C405136, PlayerPedId())
	TriggerServerEvent("rdr-bathing:setBathAsFree", town)

	if DoesEntityExist(Citizen.InvokeNative(0xE5822422197BBBA3, animscene, "Female", false)) then
		DeletePed(Citizen.InvokeNative(0xE5822422197BBBA3, animscene, "Female", false))
	end

	SetPedCanLegIk(PlayerPedId(), true)
	SetPedLegIkMode(PlayerPedId(), 2)

	inTub = false
	SetIsBathing(false)
	currentTown = nil
end


RegisterNetEvent('rdr-bathing:StartDeluxeBath')
AddEventHandler('rdr-bathing:StartDeluxeBath', function(animscene, town, cam)

	if Config.DebugPrint then print("rdr-bathing:StartDeluxeBath") end

	-- Prompt for which model to use

	-- MENU

	MenuData.CloseAll()
	
	local elements = {}
	
	for k,v in pairs(Config.TubHotties) do
		table.insert(elements, {label = v.name, value = v.ped, desc = v.name})
	end
	
	MenuData.Open('default', GetCurrentResourceName(), 'TubAssistantMenu', {
		title    = "Assistants",
		subtext    = '',
		align    = 'top-right',
		elements = elements,
	},

	function(data, menu)

		if Config.DebugPrint then print("rdr-bathing:StartDeluxeBath - selection: ",data.current.value) end

		menu.close()

		StartDeluxeBath(animscene, town, cam, data.current.value)

	end,
			
	function(data, menu)
		menu.close()
	end) 

end)

function StartDeluxeBath(animscene, town, cam, assistantPed)

	if Config.DebugPrint then print("StartDeluxeBath", animscene, town, cam, assistantPed) end

	local assistantPedHash = GetHashKey(assistantPed)

	if not Citizen.InvokeNative(0x25557E324489393C, animscene) then return end
	Citizen.InvokeNative(0x84EEDB2C6E650000, animscene) --// _DELETE_ANIM_SCENE

	local animscene = Citizen.InvokeNative(0x1FCA98E33C1437B3, Config.BathingZones[town].dict, 0,  "s_deluxe_intro", false, true)
	SetAnimSceneEntity(animscene, "ARTHUR", PlayerPedId(), 0)
	SetAnimSceneEntity(animscene, "Door", N_0xf7424890e4a094c0(Config.BathingZones[town].door, 0), 0)
	
	LoadModel(assistantPedHash)
	BathingPed = CreatePed(assistantPedHash, GetEntityCoords(PlayerPedId())-vector3(0.0, 0.0, -5.0), 0.0, false, false, true, true)

	table.insert(Config.CreatedEntries, { type = "PED", handle = BathingPed })
	Citizen.InvokeNative(0x283978A15512B2FE, BathingPed, true)
	SetAnimSceneEntity(animscene, "Female", BathingPed, 0)
	SetModelAsNoLongerNeeded(assistantPedHash)

	LoadAnimScene(animscene)  
	while not Citizen.InvokeNative(0x477122B8D05E7968, animscene, 1, 0) do Citizen.Wait(10) end --// _IS_ANIM_SCENE_LOADED
	PlaySoundFrontend("BATHING_DOOR_KNOCK_MASTER", 0, true, 0)
	Citizen.Wait(1000)
	StartAnimScene(animscene)

	RenderScriptCams(false, false, 0, true, false, 0)

	while not Citizen.InvokeNative(0xD8254CB2C586412B, animscene, true) do Citizen.Wait(10) end --// _IS_ANIM_SCENE_FINISHED
	Citizen.InvokeNative(0x84EEDB2C6E650000, animscene) --// _DELETE_ANIM_SCENE

	TriggerEvent("rdr-bathing:TASK_MOVE_NETWORK_BY_NAME_WITH_INIT_PARAMS", { PlayerPedId(), "Script_Mini_Game_Bathing_Deluxe", `CLIPSET@MINI_GAMES@BATHING@DELUXE@ARTHUR`, `DEFAULT`, "BATHING" })
	TriggerEvent("rdr-bathing:TASK_MOVE_NETWORK_BY_NAME_WITH_INIT_PARAMS", { BathingPed, "Script_Mini_Game_Bathing_Deluxe", `CLIPSET@MINI_GAMES@BATHING@DELUXE@MAID`, `DEFAULT`, "BATHING" })	
		
	TogglePrompts({ "STOP_BATHING", "SCRUB", "CAMERA" }, true)

	RenderScriptCams(true, true, 0, true, false, 0)

end

RegisterNetEvent('rdr-bathing:HideDeluxePrompt')
AddEventHandler('rdr-bathing:HideDeluxePrompt', function()
	TogglePrompts({ "REQUEST_DELUXE_BATHING" }, false)
end)

ExitPremiumBath = function(animscene, town, cam, disableScrub)
	local animscene = Citizen.InvokeNative(0x1FCA98E33C1437B3, Config.BathingZones[town].dict, 0,  "s_deluxe_outro", false, true)
	SetAnimSceneEntity(animscene, "ARTHUR", PlayerPedId(), 0)
	SetAnimSceneEntity(animscene, "Female", BathingPed, 0)
	SetAnimSceneEntity(animscene, "Door", N_0xf7424890e4a094c0(Config.BathingZones[town].door, 0), 0)

	LoadAnimScene(animscene)  
	while not Citizen.InvokeNative(0x477122B8D05E7968, animscene, 1, 0) do Citizen.Wait(10) end --// _IS_ANIM_SCENE_LOADED
	StartAnimScene(animscene)

	RenderScriptCams(false, false, 0, true, false, 0)

	while not Citizen.InvokeNative(0xD8254CB2C586412B, animscene, true) do Citizen.Wait(10) end --// _IS_ANIM_SCENE_FINISHED

	TriggerEvent("rdr-bathing:TASK_MOVE_NETWORK_BY_NAME_WITH_INIT_PARAMS", { PlayerPedId(), "Script_Mini_Game_Bathing_Regular", `CLIPSET@MINI_GAMES@BATHING@REGULAR@ARTHUR`, `DEFAULT`, "BATHING" })
	--TriggerEvent("rdr-bathing:TASK_MOVE_NETWORK_ADVANCED_BY_NAME_WITH_INIT_PARAMS", { rag, "Script_Mini_Game_Bathing_Regular", `CLIPSET@MINI_GAMES@BATHING@REGULAR@RAG`, `DEFAULT`, "BATHING", { Config.BathingZones[town].rag.x, Config.BathingZones[town].rag.y, Config.BathingZones[town].rag.z }, Config.BathingZones[town].rag.w })	
		
	TogglePrompts({ "STOP_BATHING", "SCRUB" }, true)
	if IsPromptEnabled("SCRUB") and disableScrub then TogglePrompts({ "SCRUB" }, false) end

	RenderScriptCams(true, true, 0, true, false, 0)
	DeletePed(BathingPed)
end

LoadModel = function(model)
	while not HasModelLoaded(model) do RequestModel(model) Citizen.Wait(10) end
end

LoadAllStreamings = function()
	RequestAnimDict("MINI_GAMES@BATHING@REGULAR@ARTHUR");
	RequestAnimDict("MINI_GAMES@BATHING@REGULAR@RAG");
	RequestAnimDict("MINI_GAMES@BATHING@DELUXE@ARTHUR");
	RequestAnimDict("MINI_GAMES@BATHING@DELUXE@MAID");

	RequestClipSet("CLIPSET@MINI_GAMES@BATHING@REGULAR@ARTHUR");
	RequestClipSet("CLIPSET@MINI_GAMES@BATHING@REGULAR@RAG");
	RequestClipSet("CLIPSET@MINI_GAMES@BATHING@DELUXE@ARTHUR");
	RequestClipSet("CLIPSET@MINI_GAMES@BATHING@DELUXE@MAID");

	Citizen.InvokeNative(0x2B6529C54D29037A, "Script_Mini_Game_Bathing_Regular");
	Citizen.InvokeNative(0x2B6529C54D29037A, "Script_Mini_Game_Bathing_Deluxe");
end

UnloadAllStreamings = function()
	RemoveAnimDict("MINI_GAMES@BATHING@REGULAR@ARTHUR");
	RemoveAnimDict("MINI_GAMES@BATHING@REGULAR@RAG");
	RemoveAnimDict("MINI_GAMES@BATHING@DELUXE@ARTHUR");
	RemoveAnimDict("MINI_GAMES@BATHING@DELUXE@MAID");

	RemoveClipSet("CLIPSET@MINI_GAMES@BATHING@REGULAR@ARTHUR");
	RemoveClipSet("CLIPSET@MINI_GAMES@BATHING@REGULAR@RAG");
	RemoveClipSet("CLIPSET@MINI_GAMES@BATHING@DELUXE@ARTHUR");
	RemoveClipSet("CLIPSET@MINI_GAMES@BATHING@DELUXE@MAID");

	Citizen.InvokeNative(0x57A197AD83F66BBF, "Script_Mini_Game_Bathing_Regular");
	Citizen.InvokeNative(0x57A197AD83F66BBF, "Script_Mini_Game_Bathing_Deluxe");
end

UndressCharacter = function() --// link own undress logic
	ExecuteCommand('undress')
end

DressCharacter = function() --// link own dress logic
	ExecuteCommand('rc')
end

SetCurrentCleaniest = function(rag, value)
	SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Cleanliness_Right_Arm", value);
	SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Cleanliness_Left_Arm", value);
	SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Cleanliness_Left_Leg", value);
	SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Cleanliness_Right_Leg", value);
	SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Cleanliness_Head", value);

	SetTaskMoveNetworkSignalFloat(rag, "Cleanliness_Right_Arm", value);
	SetTaskMoveNetworkSignalFloat(rag, "Cleanliness_Left_Arm", value);
	SetTaskMoveNetworkSignalFloat(rag, "Cleanliness_Left_Leg", value);
	SetTaskMoveNetworkSignalFloat(rag, "Cleanliness_Right_Leg", value);
	SetTaskMoveNetworkSignalFloat(rag, "Cleanliness_Head", value);

	if DoesEntityExist(BathingPed) then
		SetTaskMoveNetworkSignalFloat(BathingPed, "Cleanliness_Right_Arm", value);
		SetTaskMoveNetworkSignalFloat(BathingPed, "Cleanliness_Left_Arm", value);
		SetTaskMoveNetworkSignalFloat(BathingPed, "Cleanliness_Left_Leg", value);
		SetTaskMoveNetworkSignalFloat(BathingPed, "Cleanliness_Right_Leg", value);
		SetTaskMoveNetworkSignalFloat(BathingPed, "Cleanliness_Head", value);
	end
end

Action = function(name, p1, p2, p3)
	TogglePrompts("ALL", false)

	if (name == "START_BATHING") then

		-- Check not "occupied"
		local isPlayerOccupied = not RainbowCore.CanPedStartInteraction(PlayerPedId())
		if isPlayerOccupied then
			VORPcore.NotifyRightTip("You cannot take a bath while occupied.", 6 * 1000)
			return
		else
			TriggerServerEvent("rdr-bathing:canEnterBath", p1)
		end
		
	elseif (name == "REQUEST_DELUXE_BATHING") then
		if Config.DebugPrint then print("Action: REQUEST_DELUXE_BATHING") end
		TriggerServerEvent("rdr-bathing:canEnterDeluxeBath", p1 , p2 , p3)
	elseif (name == "STOP_BATHING") then
		ExitBathing(p1, p2, p3)
	end

	Citizen.Wait(500)
end

--[[ Prompts ]]--
RegisterPrompts = function()
    local newTable = {}

    for i=1, #Config.Prompts do
        local prompt = Citizen.InvokeNative(0x04F97DE45A519419, Citizen.ResultAsInteger())
        Citizen.InvokeNative(0x5DD02A8318420DD7, prompt, CreateVarString(10, "LITERAL_STRING", Config.Prompts[i].label))
        Citizen.InvokeNative(0xB5352B7494A08258, prompt, Config.Prompts[i].control or 0xDFF812F9)
        Citizen.InvokeNative(0x94073D5CA3F16B7B, prompt, Config.Prompts[i].time or 1000)

        Citizen.InvokeNative(0xF7AA2696A22AD8B9, prompt)

        Citizen.InvokeNative(0x8A0FB4D03A630D21, prompt, false)
        Citizen.InvokeNative(0x71215ACCFDE075EE, prompt, false)

        table.insert(Config.CreatedEntries, { type = "PROMPT", handle = prompt })
        newTable[Config.Prompts[i].id] = prompt
    end

    Config.Prompts = newTable
    return true
end
TogglePrompts = function(data, state)
    for index,prompt in pairs((data ~= "ALL" and data) or Config.Prompts) do
        if Config.Prompts[(data ~= "ALL" and prompt) or index] then
            Citizen.InvokeNative(0x8A0FB4D03A630D21, (data ~= "ALL" and Config.Prompts[prompt]) or prompt, state)
            Citizen.InvokeNative(0x71215ACCFDE075EE, (data ~= "ALL" and Config.Prompts[prompt]) or prompt, state)
        end
    end
    PromptsEnabled = state
end
IsPromptCompleted = function(name)
    if Config.Prompts[name] then
        return Citizen.InvokeNative(0xE0F65F0640EF0617, Config.Prompts[name])
    end return
end
IsPromptEnabled = function(name)
    if Config.Prompts[name] then
		return PromptIsEnabled(Config.Prompts[name])
    end return
end

--[[ Blips ]]--
CreateBlips = function()
	for townName,data in pairs(Config.BathingZones) do
        Citizen.Wait(10)
        local blip = Citizen.InvokeNative(0x554D9D53F696D002, 0xB04092F8, data.consumer)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, CreateVarString(10, "blip_bath_house"))
        SetBlipSprite(blip, `blip_bath_house`)

        table.insert(Config.CreatedEntries, { type = "BLIP", handle = blip })
    end
end

--[[ Doors ]]--
CloseBathDoors = function()
	for townName,data in pairs(Config.BathingZones) do
        if data.door then
			if not IsDoorRegisteredWithSystem(data.door) then
                Citizen.InvokeNative(0xD99229FE93B46286, data.door, 1, 1, 0, 0, 0, 0)
				DoorSystemSetDoorState(data.door, 1)     
            end
		end
    end	  
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        for i=1, #Config.CreatedEntries do
            if Config.CreatedEntries[i].type == "PED" then
                if DoesEntityExist(Config.CreatedEntries[i].handle) then DeleteEntity(Config.CreatedEntries[i].handle) end
            elseif Config.CreatedEntries[i].type == "BLIP" then
                RemoveBlip(Config.CreatedEntries[i].handle)
            elseif Config.CreatedEntries[i].type == "PROMPT" then
                Citizen.InvokeNative(0x00EDE88D4D13CF59, Config.CreatedEntries[i].handle)
			elseif Config.CreatedEntries[i].type == "CAM" then
				if DoesCamExist(Config.CreatedEntries[i].handle) then RenderScriptCams(false, false, 0, false, false, false) DestroyCam(Config.CreatedEntries[i].handle) end
            end
        end

		N_0x69d65e89ffd72313(false, false)
	end
end)