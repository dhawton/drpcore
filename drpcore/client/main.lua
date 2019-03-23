RegisterNetEvent("drp:update")

local FirstSpawn = true
PlayerData = nil
local hasSetupBank = false
local oldpos = nil
local isDead = false
local Pickups = {}

Citizen.CreateThread(function()
  while DRP.Items == nil do
    TriggerServerEvent("drp/core:items")
    Citizen.Wait(100)
  end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local pos = GetEntityCoords(PlayerPedId())

		if(oldPos ~= pos)then
			TriggerServerEvent('drp/updatePositions', pos.x, pos.y, pos.z)
			oldPos = pos
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
    for i = 0,64 do
      if NetworkIsPlayerActive(i) then
        SetCanAttackFriendly(GetPlayerPed(i), true, true)
        NetworkSetFriendlyFireOption(true)
      end
    end
	end
end)

Citizen.CreateThread(function()
  local x = 0
	while x == 0 do
		Citizen.Wait(0)

		if NetworkIsSessionStarted() then
			TriggerServerEvent('drp:joined')
      x = 1
			return
		end
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)
		
		-- if there's no nearby pickups we can wait a bit to save performance
		if next(Pickups) == nil then
			Citizen.Wait(500)
		end

		for k,v in pairs(Pickups) do

			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.coords.x, v.coords.y, v.coords.z, true)
			local closestPlayer, closestDistance = DRP.Game.GetClosestPlayer()

			if distance <= 5.0 then
				DRP.Game.Utils.DrawText3D({
					x = v.coords.x,
					y = v.coords.y,
					z = v.coords.z + 0.25
				}, v.label)
			end

			if (closestDistance == -1 or closestDistance > 3) and distance <= 1.0 and not v.inRange and not IsPedSittingInAnyVehicle(playerPed) then
				TriggerServerEvent('drp/onPickup', v.id)
				PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
				v.inRange = true
			end

		end

	end
end)

RegisterNetEvent("drp/core:items")
AddEventHandler("drp/core:items", function(data) DRP.Items = data end)

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    BringUpUI()
  end
end)

RegisterCommand("test", function()
  TriggerServerEvent("drp/test")
end)

AddEventHandler('drp/getSharedObject', function(cb)
	cb(DRP)
end)

local firstSpawn = true
AddEventHandler("playerSpawned", function()
  TriggerServerEvent('playerSpawn', firstSpawn)
  if firstSpawn then
    BringUpUI()
--[[ if we ever decide to show native cash balances
    N_0xc2d15bef167e27bc()
    Citizen.InvokeNative(0x170F541E1CADD1DE, true)
    SetMultiplayerBankCash()
    Citizen.InvokeNative(0x170F541E1CADD1DE, true)
    SetPlayerCashChange(1, 1)
    Citizen.Wait(100)
    SetPlayerCashChange(-1, -1) ]]
    firstSpawn = false
  end
  isDead = false
end)

AddEventHandler('drp/onPlayerDeath', function()
	isDead = true
end)

function BringUpUI()
    FirstSpawn = true
    SwitchOutPlayer(GetPlayerPed(-1), 0, 1)

    SendNUIMessage(
        {
            type = "SHOW"
        }
    )
    SetNuiFocus(true, true)
    TriggerServerEvent("drp/identity:userData")
end

RegisterNetEvent("drp/identity:characters")
AddEventHandler("drp/identity:characters", function(data)
  SendNUIMessage({
    type = "DH_SEND_CHARACTERS",
    data = data
  }) 
end)
RegisterNetEvent("drp/identity:characterscad")
AddEventHandler("drp/identity:characterscad", function(data)
  SendNUIMessage({
    type = "DH_SEND_CHARACTERS_CAD",
    data = data
  })
end)

RegisterNUICallback(
  "editCharacter",
  function(data, cb)
    SendNUIMessage({
      type = "DH_DISABLE_ALL_UI"
    })
    TriggerServerEvent("drp/identity:client/editCharacter", data)
  end
)
RegisterNUICallback(
  "createCharacter",
  function(data, cb)
    SendNUIMessage({
      type = "DH_DISABLE_ALL_UI"
    })
    TriggerServerEvent("drp/identity:client/createCharacter", data)
  end
)
RegisterNUICallback(
  "deleteCharacter",
  function(data, cb)
    SendNUIMessage({
      type = "DH_DISABLE_ALL_UI"
    })
    TriggerServerEvent("drp/identity:client/deleteCharacter", data)
  end
)

RegisterNUICallback(
  "selectCharacter",
  function(data, cb)
    Citizen.CreateThread(function()
      local x = 0.0
      local y = 0.0
      local z = 0.0
      local h = 0.0
      local station = data.station
      local character = data.character
      TriggerServerEvent("drp/identity:client/selectCharacter", character)
      if character.job_name ~= "highway" and character.job_name ~= "sheriff" and character.job_name ~= "police" and character.job_name ~= "fire" then
        TriggerServerEvent("drp/identity:client/spawnCiv", character.id, station)
      end
      SetNuiFocus(false, false)
      SendNUIMessage(
        {
          type = "DH_DISABLE_UI"
        }
      )
      if data.station == "BCSO" then
          -- -424.46 6023.38 31.48 106.9
          x = -424.46
          y = 6023.38
          z = 31.48
          h = 106.9
      elseif data.station == "SASP" then
          -- 395.95 -1601.25 28.29 135.4
          x = 395.95
          y = -1601.25
          z = 28.29
          h = 135.4
      elseif data.station == "MissionRow" then
          x = 424.32
          y = -973.4
          z = 29.71
          h = 235.2
      elseif data.station == "Vinewood" then
          x = 647.87
          y = -8.68
          z = 81.74
          h = 41.1
      elseif data.station == "Vespucci" then
          x = -1056.81
          y = -826.13
          z = 18.22
          h = 87.9
      elseif data.station == "Fire1" then
        x = -662.83
        y = -72.88
        z = 38.55
        h = 208.1
      elseif data.station == "Fire2" then
        x = 218.05
        y = -1637.36
        z = 30.42
        h = 149.27
      elseif data.station == "Fire3" then
        x = 1200.93
        y = -1454.38
        z = 34.97
        h = 185.65
      elseif data.station == "Fire4" then
        x = -1098.48
        y = -2365.7
        z = 13.95
        h = 279.49
      elseif data.station == "Fire5" then
        x = -2115.21
        y = 2848.29
        z = 32.81
        h = 162.31
      elseif data.station == "Fire6" then
        x = -2115.21
        y = 2848.29
        z = 32.81
        h = 162.31
      elseif data.station == "Fire7" then
        x = -387.17
        y = 6125.44
        z = 31.48
        h = 222.95
      end

      if x ~= 0.0 then
        SetEntityCoords(PlayerPedId(), x, y, z)
        if (h > 0.0) then
          SetEntityHeading(PlayerPedId(), h)
        end
      end

      Citizen.Wait(1000)
      SwitchInPlayer(GetPlayerPed(-1))
      Citizen.Wait(3000)
      TriggerServerEvent("drp/identity:spawned")
    end)
  end
)

RegisterNetEvent("drp/teleportTransition")
AddEventHandler("drp/teleportTransition", function(x,y,z,h)
  SwitchOutPlayer(GetPlayerPed(-1), 0, 1)
  Citizen.Wait(3000)
  SetEntityCoords(GetPlayerPed(-1), x, y, z)
  if h ~= nil then
    SetEntityHeading(GetPlayerPed(-1), h)
  end
  Citizen.Wait(500)
  SwitchInPlayer(GetPlayerPed(-1))
  Citizen.Wait(3000)
end)

RegisterNetEvent("drp/teleport")
AddEventHandler("drp/teleport", function (x, y, z, h)
  DoScreenFadeOut(500)
  SetEntityCoords(GetPlayerPed(-1), x, y, z)
  if z ~= nil then
    SetEntityHeading(GetPlayerPed(-1), h)
  end
  Citizen.Wait(1500)
  DoScreenFadeIn(500)
end)

RegisterNetEvent("drp/identity:setLocation")
AddEventHandler(
    "drp/identity:setLocation",
    function(x, y, z, h)
        local playerPed = PlayerPedId()
        SetEntityCoords(playerPed, x, y, z)
        SetEntityHeading(playerPed, h)

        if FirstSpawn then
            -- Check if in property and set instance?

            FirstSpawn = false
        end
    end
)

RegisterNetEvent("drp/initial")
AddEventHandler("drp/initial", function(data)
  PlayerData = data
  -- This is where we need to loop through loadout and change our weapon loadout
  -- and also setup our skin
end)

RegisterNetEvent("drp/update")
AddEventHandler("drp/update", function(data)
  PlayerData = data
end)

RegisterNetEvent("drp/addedMoney")
AddEventHandler("drp/addedMoney", function(amt)
  PlayerData.playerData.money = PlayerData.playerData.money + math.floor(amt)
end)

RegisterNetEvent("drp/removedMoney")
AddEventHandler("drp/removedMoney", function(amt)
  PlayerData.playerData.money = PlayerData.playerData.money - math.floor(abs(amt))
end)

RegisterNetEvent('drp/addedBank')
AddEventHandler('drp/addedBank', function(amt)
  PlayerData.playerData.bank = PlayerData.playerData.bank + math.floor(amt)
end)

RegisterNetEvent('drp/removedBank')
AddEventHandler('drp/removedBank', function(amt)
  PlayerData.playerData.bank = PlayerData.playerData - math.floor(abs(amt))
end)

RegisterNetEvent("drp/inventory:addInventoryItem")
AddEventHandler("drp/inventory:addInventoryItem", function(item, count)
  if PlayerData.playerData.inventory[item] == nil then
    PlayerData.playerData.inventory[item] = 0
  end
  PlayerData.playerData.inventory[item] = PlayerData.playerData.inventory[item] + count

  DRP.ShowNotification("Received x" .. count .. " of " .. DRP.GetItemLabel(item))
  if DRP.UI.Menu.IsOpen('default', 'drpcore', 'inventory') then
		DRP.ShowInventory()
	end
end)

RegisterNetEvent("drp/inventory:removeInventoryItem")
AddEventHandler("drp/inventory:removeInventoryItem", function(item, count)
  if PlayerData.playerData.inventory[item] == nil then
    PlayerData.playerData.inventory[item] = 0
  end
  PlayerData.playerData.inventory[item] = PlayerData.playerData.inventory[item] - count

  DRP.ShowNotification("Removed x" .. count .. " of " .. DRP.GetItemLabel(item))

  if DRP.UI.Menu.IsOpen('default', 'drpcore', 'inventory') then
		DRP.ShowInventory()
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1000)

		if PlayerData ~= nil then
			local playerPed = PlayerPedId()
			local coords    = GetEntityCoords(playerPed)

			if not IsEntityDead(playerPed) then
				PlayerData.playerData.lastPosition = {x = coords.x, y = coords.y, z = coords.z}
			end
		end

	end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)

    local playerId = PlayerId()
    if GetPlayerWantedLevel(playerId) ~= 0 then
      SetPlayerWantedLevel(playerId, 0, false)
      SetPlayerWantedLevelNow(playerId, false)
    end
  end
end)
  
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(10)

		-- Inventory key: ` / INPUT_ENTER_CHEAT_CODE (next to 1)
		if IsControlJustReleased(0, 243) and GetLastInputMethod(2) and not isDead and not DRP.UI.Menu.IsOpen('default', 'drpcore', 'inventory') then
			DRP.ShowInventory()
		end

	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)
		local currTime = GetGameTimer()

		for i=1, #DRP.TimeoutCallbacks, 1 do

			if DRP.TimeoutCallbacks[i] ~= nil then
				if currTime >= DRP.TimeoutCallbacks[i].time then
					DRP.TimeoutCallbacks[i].cb()
					DRP.TimeoutCallbacks[i] = nil
				end
			end

		end

	end
end)

Citizen.CreateThread(function()
	local isDead = false

	while true do
		Citizen.Wait(0)

		local player = PlayerId()

		if NetworkIsPlayerActive(player) then
			local playerPed = PlayerPedId()

			if IsPedFatallyInjured(playerPed) and not isDead then
				isDead = true

				local killer, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
				local killerServerId = NetworkGetPlayerIndexFromPed(killer)
		
				if killer ~= playerPed and killerServerId ~= nil and NetworkIsPlayerActive(killerServerId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerServerId), killerServerId, killerWeapon)
				else
					PlayerKilled()
				end

			elseif not IsPedFatallyInjured(playerPed) then
				isDead = false
			end
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, killerWeapon)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance     = GetDistanceBetweenCoords(victimCoords, killerCoords, true)

	local data = {
		victimCoords = victimCoords,
		killerCoords = killerCoords,

		killedByPlayer = true,
		deathCause     = killerWeapon,
		distance       = ESX.Math.Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('drp/onPlayerDeath', data)
	TriggerServerEvent('drp/onPlayerDeath', data)
end

function PlayerKilled()
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(PlayerPedId())

	local data = {
		victimCoords = victimCoords,

		killedByPlayer = false,
		deathCause     = GetPedCauseOfDeath(playerPed)
	}

	TriggerEvent('drp/onPlayerDeath', data)
	TriggerServerEvent('drp/onPlayerDeath', data)
end

RegisterNetEvent("drp/core:showNotification")
AddEventHandler("drp/core:showNotification", function(text)
  DRP.ShowNotification(text)
end)

RegisterNetEvent('drp/pickup')
AddEventHandler('drp/pickup', function(id, label, player)
	local ped     = GetPlayerPed(GetPlayerFromServerId(player))
	local coords  = GetEntityCoords(ped)
	local forward = GetEntityForwardVector(ped)
	local x, y, z = table.unpack(coords + forward * -2.0)

	DRP.Game.SpawnLocalObject('prop_money_bag_01', {
		x = x,
		y = y,
		z = z - 2.0,
	}, function(obj)
		SetEntityAsMissionEntity(obj, true, false)
		PlaceObjectOnGroundProperly(obj)

		Pickups[id] = {
			id = id,
			obj = obj,
			label = label,
			inRange = false,
			coords = {
				x = x,
				y = y,
				z = z
			}
		}
	end)
end)

RegisterNetEvent('drp/removePickup')
AddEventHandler('drp/removePickup', function(id)
	DRP.Game.DeleteObject(Pickups[id].obj)
	Pickups[id] = nil
end)