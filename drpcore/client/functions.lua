DRP                           = {}
DRP.Game											= {}
DRP.Game.Utils                = {}
DRP.Items											= nil
DRP.UI                        = {}
DRP.UI.Menu                   = {}
DRP.UI.Menu.RegisteredTypes   = {}
DRP.UI.Menu.Opened            = {}
DRP.TimeoutCallbacks          = {}

DRP.SetTimeout = function(msec, cb)
	table.insert(DRP.TimeoutCallbacks, {
		time = GetGameTimer() + msec,
		cb   = cb
	})
	return #DRP.TimeoutCallbacks
end

DRP.ClearTimeout = function(i)
	DRP.TimeoutCallbacks[i] = nil
end

DRP.GetItemLabel = function(item)
	return DRP.Items[item].label
end

DRP.ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(false, true)
end

DRP.ShowAdvancedNotification = function(title, subject, msg, icon, iconType)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	SetNotificationMessage(icon, icon, false, iconType, title, subject)
	DrawNotification(false, false)
end

DRP.ShowHelpNotification = function(msg)
	if not IsHelpMessageOnScreen() then
		SetTextComponentFormat('STRING')
		AddTextComponentString(msg)
		DisplayHelpTextFromStringLabel(0, 0, 1, -1)
	end
end

DRP.ShowInventory = function()
	local playerPed = PlayerPedId()
	local elements  = {}

	if PlayerData.playerData.money > 0 then
		local formattedMoney = "$" .. PlayerData.playerData.money

		table.insert(elements, {
			label     = ('%s: <span style="color:lightgreen;">%s</span>'):format("Cash", formattedMoney),
			count     = PlayerData.playerData.money,
			type      = 'item_money',
			value     = 'money',
			usable    = false,
			rare      = false,
			canRemove = true
		})
	end

	table.insert(elements, {
		label     = ('%s: <span style="color:#e57373;">%s</span>'):format("Dirty Money", "$" .. PlayerData.playerData.dirty),
		count     = PlayerData.playerData.dirty,
		type      = 'item_dirty',
		value     = "dirty",
		usable    = false,
		rare      = false,
		canRemove = true
	})

	for k, v in pairs(PlayerData.playerData.inventory) do
		if PlayerData.playerData.inventory[k] > 0 then
			table.insert(elements, {
				label = DRP.GetItemLabel(k) .. " x" .. PlayerData.playerData.inventory[k],
				count = PlayerData.playerData.inventory[k],
				type = "item",
				value = k,
				usable = DRP.Items[k].usable,
				canRemove = DRP.Items[k].canRemove
			})
		end
	end

	for i=1, #Weapons, 1 do
		local weaponHash = GetHashKey(Weapons[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and Config.Weapons[i].name ~= 'WEAPON_UNARMED' then
			local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
			table.insert(elements, {
				label     = Weapons[i].label .. ' [' .. ammo .. ']',
				count     = 1,
				type      = 'weapon',
				value     = Weapons[i].name,
				ammo      = ammo,
				usable    = false,
				rare      = false,
				canRemove = true
			})
		end
	end

	DRP.UI.Menu.CloseAll()

	DRP.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory',
	{
		title    = "Inventory",
		align    = 'top-right',
		elements = elements,
	}, function(data, menu)
		menu.close()
		local player, distance = DRP.Game.GetClosestPlayer()
		local elements = {}

		if data.current.usable then
			table.insert(elements, {label = "Use", action = 'use', type = data.current.type, value = data.current.value})
		end

		if data.current.canRemove then
			if player ~= -1 and distance <= 3.0 then
				table.insert(elements, {label = "Give", action = 'give', type = data.current.type, value = data.current.value})
			end

			table.insert(elements, {label = "Drop", action = 'remove', type = data.current.type, value = data.current.value})
		end

		if data.current.type == 'item_weapon' and data.current.ammo > 0 and player ~= -1 and distance <= 3.0 then
			table.insert(elements, {label = "Give", action = 'giveammo', type = data.current.type, value = data.current.value})
		end

		table.insert(elements, {label = "Return", action = 'return'})
		DRP.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory_item',
		{
			title    = data.current.label,
			align    = 'top-right',
			elements = elements,
		}, function(data1, menu1)

			local item = data1.current.value
			local type = data1.current.type
			local playerPed = PlayerPedId()
			if data1.current.action == "give" then
				local player, distance = DRP.Game.GetClosestPlayer()
				if player ~= -1 then
					-- Give it to them
					if type == "item" then
						menu1.close()
						DRP.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', {
							title = "Amount"
						}, function(data3, menu3)
							local quantity = tonumber(data3.value)
							local closestPlayer, closestDistance = DRP.Game.GetClosestPlayer()
							local closestPed = GetPlayerPed(closestPlayer)
							if closestPlayer ~= -1 and closestDistance < 3.0 then
								if quantity ~= nil then
									TriggerServerEvent("drp/invetory:give", GetPlayerServerId(closestPlayer), type, item, quantity)
									menu3.close()
									menu2.close()
									menu1.close()
								else
									DRP.ShowNotification("Invalid quantity")
								end
							else
								DRP.ShowNotification("No players nearby.")
							end
						end, function(data3, menu3)
							menu3.close()
						end)
					elseif type == "weapon" then
						local player, distance = DRP.Game.GetClosestPlayer()
						if player ~= -1 and distance < 3.0 then
							TriggerServerEvent("drp/inventory:give", GetPlayerServerId(player), type, item, GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(item)))
							menu2.close()
							menu1.close()
						else
							DRP.ShowNotification("No players close enough.")
							return
						end
					end
				else
					DRP.ShowNotification("No players close enough.")
					return
				end
			elseif data1.current.action == "remove" then
				-- We need to handle removing and dropping
				if type == "weapon" then
					TriggerServerEvent("drp/inventory:remove", type, item, nil)
					DRP.UI.Menu.CloseAll()
				else
					menu1.close()
					DRP.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_remove', {
						title = "Amount"
					}, function(data2, menu2)
						local quantity = tonumber(data2.value)

						if quantity == nil then
							ESX.ShowNotification(_U('amount_invalid'))
						else
							TriggerServerEvent('drp/inventory:remove', type, item, quantity)
							DRP.UI.Menu.CloseAll()
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				end
			elseif data1.current.action == "use" then
				TriggerServerEvent("drp/inventory:use", item)
			elseif data1.current.action == "return" then
				DRP.UI.Menu.CloseAll()
				DRP.ShowInventory()
			elseif data1.current.action == 'giveammo' then
				local closestPlayer, closestDistance = DRP.Game.GetClosestPlayer()
				local closestPed = GetPlayerPed(closestPlayer)
				local pedAmmo = GetAmmoInPedWeapon(playerPed, GetHashKey(item))

				if closestPlayer ~= -1 and closestDistance < 3.0 then
					if pedAmmo > 0 then

						DRP.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', {
							title = _U('amountammo')
						}, function(data2, menu2)

							local quantity = tonumber(data2.value)

							if quantity ~= nil then
								if quantity <= pedAmmo and quantity >= 0 then

									local finalAmmoSource = math.floor(pedAmmo - quantity)
									SetPedAmmo(playerPed, item, finalAmmoSource)
									AddAmmoToPed(closestPed, item, quantity)

									DRP.ShowNotification(_U("You gave %s ammo to %s.", quantity, GetPlayerName(closestPlayer)))
									-- todo notify target that he received ammo
									menu2.close()
									menu1.close()
								else
									DRP.ShowNotification("No ammo to give.")
								end
							else
								DRP.ShowNotification("Invalid quantity.")
							end

						end, function(data2, menu2)
							menu2.close()
						end)
					else
						DRP.ShowNotification("No ammo to give.")
					end
				else
					DRP.ShowNotification("No players nearby.")
				end
			end
		end, function(data1, menu1)
			DRP.UI.Menu.CloseAll()
			DRP.ShowInventory()
		end)
	end, function(data, menu)
		menu.close()
	end)
end

DRP.Game.GetPlayers = function()
	local players = {}
	for i = 0, 64, 1 do
		if DoesEntityExist(GetPlayerPed(i)) then
			table.insert(players, i)
		end
	end

	return players
end

DRP.Game.GetClosestPlayer = function(coords)
	local players         = DRP.Game.GetPlayers()
	local closestDistance = -1
	local closestPlayer   = -1
	local coords          = coords
	local usePlayerPed    = false
	local playerPed       = PlayerPedId()
	local playerId        = PlayerId()

	if coords == nil then
		usePlayerPed = true
		coords       = GetEntityCoords(playerPed)
	end

	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])

		if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
			local targetCoords = GetEntityCoords(target)
			local distance     = GetDistanceBetweenCoords(targetCoords.x, targetCoords.y, targetCoords.z, coords.x, coords.y, coords.z, true)

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer   = players[i]
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance
end

DRP.Game.GetPlayersInArea = function(coords, area)
	local players       = DRP.Game.GetPlayers()
	local playersInArea = {}

	for i=1, #players, 1 do
		local target       = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)
		local distance     = GetDistanceBetweenCoords(targetCoords.x, targetCoords.y, targetCoords.z, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end

DRP.Game.Utils.DrawText3D = function(coords, text, size)
	local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
	local camCoords      = GetGameplayCamCoords()
	local dist           = GetDistanceBetweenCoords(camCoords.x, camCoords.y, camCoords.z, coords.x, coords.y, coords.z, 1)
	local size           = size

	if size == nil then
		size = 1
	end

	local scale = (size / dist) * 2
	local fov   = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov

	if onScreen then
		SetTextScale(0.0 * scale, 0.55 * scale)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry('STRING')
		SetTextCentre(1)

		AddTextComponentString(text)
		DrawText(x, y)
	end
end

DRP.UI.Menu.RegisterType = function(type, open, close)
	DRP.UI.Menu.RegisteredTypes[type] = {
		open   = open,
		close  = close,
	}
end

DRP.UI.Menu.Open = function(type, namespace, name, data, submit, cancel, change, close)
	local menu = {}

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel
	menu.change    = change

	menu.close = function()

		DRP.UI.Menu.RegisteredTypes[type].close(namespace, name)

		for i=1, #DRP.UI.Menu.Opened, 1 do
			if DRP.UI.Menu.Opened[i] ~= nil then
				if DRP.UI.Menu.Opened[i].type == type and DRP.UI.Menu.Opened[i].namespace == namespace and DRP.UI.Menu.Opened[i].name == name then
					DRP.UI.Menu.Opened[i] = nil
				end
			end
		end

		if close ~= nil then
			close()
		end

	end

	menu.update = function(query, newData)

		for i=1, #menu.data.elements, 1 do
			local match = true

			for k,v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				for k,v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end
		end

	end

	menu.refresh = function()
		DRP.UI.Menu.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end

	table.insert(DRP.UI.Menu.Opened, menu)
	DRP.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

	return menu
end

DRP.UI.Menu.Close = function(type, namespace, name)
	for i=1, #DRP.UI.Menu.Opened, 1 do
		if DRP.UI.Menu.Opened[i] ~= nil then
			if DRP.UI.Menu.Opened[i].type == type and DRP.UI.Menu.Opened[i].namespace == namespace and DRP.UI.Menu.Opened[i].name == name then
				DRP.UI.Menu.Opened[i].close()
				DRP.UI.Menu.Opened[i] = nil
			end
		end
	end
end

DRP.UI.Menu.CloseAll = function()
	for i=1, #DRP.UI.Menu.Opened, 1 do
		if DRP.UI.Menu.Opened[i] ~= nil then
			DRP.UI.Menu.Opened[i].close()
			DRP.UI.Menu.Opened[i] = nil
		end
	end
end

DRP.UI.Menu.GetOpened = function(type, namespace, name)
	for i=1, #DRP.UI.Menu.Opened, 1 do
		if DRP.UI.Menu.Opened[i] ~= nil then
			if DRP.UI.Menu.Opened[i].type == type and DRP.UI.Menu.Opened[i].namespace == namespace and DRP.UI.Menu.Opened[i].name == name then
				return DRP.UI.Menu.Opened[i]
			end
		end
	end
end

DRP.UI.Menu.GetOpenedMenus = function()
	return DRP.UI.Menu.Opened
end

DRP.UI.Menu.IsOpen = function(type, namespace, name)
	return DRP.UI.Menu.GetOpened(type, namespace, name) ~= nil
end

DRP.Game.SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, true, true)

		if cb ~= nil then
			cb(obj)
		end
	end)
end

DRP.Game.DeleteObject = function(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end