RegisterServerEvent("drp/getSharedObject")
AddEventHandler('drp/getSharedObject', function(cb)
	cb(DRP)
end)

RegisterServerEvent("drp/test")
AddEventHandler("drp/test", function()
	print(json.encode(source))
end)

RegisterServerEvent("drp/core:items")
AddEventHandler("drp/core:items", function()
	TriggerClientEvent("drp/core:items", source, DRP.Items)
end)

RegisterNetEvent("drp:update")

AddEventHandler('playerConnecting', function(name, setKickReason)
	local Source = source
	local id
	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			id = v
			break
		end
	end

	if not id then
		setKickReason("Couldn't find Steam ID. Please make sure to start steam before connecting to the server.")
		CancelEvent()
	end
end)

RegisterServerEvent("drp:joined")
AddEventHandler("drp:joined", function()
	DRP.Users[source] = CreateUser(source, GetPlayerIdentifiers(source)[1])
end)

RegisterServerEvent("drp/identity:userData")
AddEventHandler("drp/identity:userData", function ()
	local identifier = GetPlayerIdentifiers(source)[1]

	userData(source, identifier)
end)

function userData(source, identifier)
	MySQL.Async.fetchAll('SELECT * FROM users WHERE `identifier`=@identifier', {['@identifier'] = identifier}, function(users)
		if users[1] then
			local user = {
				firewhitelisted = users[1].fire_whitelisted,
				firegrade = users[1].fire_grade,
				leowhitelisted = users[1].leo_whitelisted,
				leograde = users[1].leo_grade
			}
			DRP.Users[source].permissions = user
			MySQL.Async.fetchAll('SELECT new_characters.*, jobs.label as "label_job", job_grades.label as "label_grade" FROM new_characters left join jobs on new_characters.job_name = jobs.name left join job_grades on new_characters.job_grade=job_grades.grade and new_characters.job_name=job_grades.job_name where `identifier`=@identifier', {['@identifier'] = identifier}, function (characters)
				user.characters = characters
				TriggerClientEvent("drp/identity:characters", source, user)
			end)
		end
	end)

	PerformHttpRequest("http://cad.rpcad.devel/data/users/" .. identifier .. "/characters" , function (errorCode, resultData, resultHeaders)
		TriggerClientEvent("drp/identity:characterscad", source, json.decode(resultData))
	end)
end

RegisterServerEvent("drp/identity:client/editCharacter")
AddEventHandler("drp/identity:client/editCharacter", function(data)
		local identifier = GetPlayerIdentifiers(source)[1]
		local Source = source
		local jobname;
		local jobgrade = 0;
		if (data.dept == "highway" or data.dept == "sheriff" or data.dept == "police") and DRP.Users[Source].permissions.leowhitelisted then
			jobname = data.dept
			jobgrade = DRP.Users[Source].permissions.leograde
		elseif data.dept == "fire" and DRP.Users[Source].firewhitelisted then
			jobname = data.dept
			jobgrade = DRP.Users[Source].permissions.firegrade
		else
			jobname = "unemployed"
			jobgrade = 0
		end

		MySQL.Async.execute("UPDATE `new_characters` SET `firstname`=@firstname, `lastname`=@lastname, `job_name`=@jobname, `job_grade`=@jobgrade WHERE `id`=@id AND `identifier`=@identifier",
		{
			["@id"] = data.id,
			["@identifier"] = identifier,
			['@firstname'] = data.firstname,
			['@lastname'] = data.lastname,
			['@jobname'] = jobname,
			['@jobgrade'] = jobgrade
		},function()
			userData(Source, identifier)
		end)
end)
RegisterServerEvent("drp/identity:client/createCharacter")
AddEventHandler("drp/identity:client/createCharacter", function(data)
		local identifier = GetPlayerIdentifiers(source)[1]
		local Source = source

		local jobname;
		local jobgrade = 0;
		if (data.dept == "highway" or data.dept == "sheriff" or data.dept == "police") and DRP.Users[source].leowhitelisted then
			jobname = data.dept
			jobgrade = DRP.Users[source].leograde
		elseif data.dept == "fire" and DRP.Users[source].firewhitelisted then
			jobname = data.dept
			jobgrade = DRP.Users[source].firegrade
		else
			jobname = "unemployed"
			jobgrade = 0
		end

		MySQL.Async.execute("INSERT INTO `new_characters`(`identifier`,`firstname`,`lastname`,`job_name`,`job_grade`,`loadout`,`skin`,`home`) VALUES (@identifier, @firstname, @lastname, @jobname, @jobgrade, '[]', '{}', '{}')",
		{
			["@identifier"] = identifier,
			['@firstname'] = data.firstname,
			['@lastname'] = data.lastname,
			['@jobname'] = jobname,
			['@jobgrade'] = jobgrade
		},function()
			userData(Source, identifier)
		end)
end)

RegisterServerEvent("drp/identity:client/deleteCharacter")
AddEventHandler("drp/identity:client/deleteCharacter", function(data)
		local identifier = GetPlayerIdentifiers(source)[1]
		local Source = source

		MySQL.Async.execute("DELETE FROM new_characters WHERE id=@id AND identifier=@identifier",
		{
			["@id"] = data.id,
			["@identifier"] = identifier
		},function()
			userData(Source, identifier)
		end)
end)

RegisterServerEvent("drp/identity:client/selectCharacter")
AddEventHandler("drp/identity:client/selectCharacter", function(data)
	-- We need to prep the character, loadout, skin, money, job, etc here.
	-- data is the character structure
	local Source = source
	MySQL.Async.fetchAll("SELECT users.money, users.bank, users.dirty, users.phone_number, jobs.label AS joblabel, job_grades.label AS gradelabel, job_grades.salary AS salary, new_characters.loadout AS loadout, new_characters.skin AS skin, new_characters.inventory AS inventory, new_characters.phone_number AS phone_number FROM users left join jobs on jobs.name=@jobname left join job_grades on job_grades.job_name=@jobname and job_grades.grade=@jobgrade left join new_characters on new_characters.id=@id AND new_characters.identifier=users.identifier where users.identifier=@identifier",
	{
		["@id"] = data.id,
		["@identifier"] = GetPlayerIdentifiers(source)[1],
		["@jobname"] = data.job_name,
		["@jobgrade"] = data.job_grade
	}, function(result)
		DRP.Users[Source].job.name = data.job_name
		DRP.Users[Source].job.label = result[1].joblabel
		DRP.Users[Source].job.grade = data.job_grade
		DRP.Users[Source].job.grade_label = result[1].gradelabel
		DRP.Users[Source].job.salary = result[1].salary
		DRP.Users[Source].playerData = {
			money = result[1].money,
			bank = result[1].bank,
			dirty = result[1].dirty,
			loadout = json.decode(result[1].loadout),
			skin = json.decode(result[1].skin),
			inventory = json.decode(result[1].inventory),
			character_id = data.id,
			coords = { x = 0.0, y = 0.0, z = 0.0 }
		}
		DRP.Users[Source].permissions.characters = {}
		TriggerClientEvent("drp/initial", Source, DRP.Users[Source])
	end)
	return
end)

RegisterServerEvent("drp/identity:client/spawnCiv")
AddEventHandler("drp/identity:client/spawnCiv", function(id, location)
		local _source = source
		local identifier = GetPlayerIdentifiers(source)[1]
		local x = 0.0
		local y = 0.0
		local z = 0.0
		local h = 0.0

		if location == "home" then
			MySQL.Async.fetchAll(
				"SELECT home FROM `new_characters` WHERE id = @id AND identifier = @identifier",
				{
					["@id"] = id,
					["@identifier"] = identifier
				},
				function(result)
					if result[1] == nil or (result[1].home == "{}") then
						x = 25.75
						y = 6575.84
						z = 30.59
						h = 220.7
					else
						local c = json.decode(result[1].home)
						x = c.x
						y = c.y
						z = c.z
						h = c.h
					end

					TriggerClientEvent("drp/identity:setLocation", _source, x, y, z, h)
				end
			)
		else
			MySQL.Async.fetchAll(
				"SELECT position FROM `new_characters` WHERE id = @id AND identifier = @identifier",
				{
					["@id"] = id,
					["@identifier"] = identifier
				},
				function(result)
					if result[1] == nil or result[1].position == "{}" or result[1].position == nil then
						x = 25.75
						y = 6575.84
						z = 30.59
						h = 220.7
					else
						local c = json.decode(result[1].position)
						x = c.x
						y = c.y
						z = c.z
						h = c.h
					end

					TriggerClientEvent("drp/identity:setLocation", _source, x, y, z, h)
				end
			)
		end
end)

RegisterServerEvent("drp/identity:spawned")

RegisterServerEvent('drp/updatePositions')
AddEventHandler('drp/updatePositions', function(x, y, z)
	if(DRP.Users[source])then
		DRP.Users[source].setCoords(x, y, z)
	end
end)

RegisterServerEvent('drp/inventory:remove')
AddEventHandler('drp/inventory:remove', function(type, itemName, itemCount)
	local _source = source

	if type == 'item' then
		if itemCount == nil or itemCount <= 0 then
			TriggerClientEvent('drp/core:showNotification', _source, "Invalid quantity.")
		else

			local dPlayer   = DRP.Users[_source].playerData
			local foundItem = nil

			for k, v in pairs(dPlayer.inventory) do
				if k == itemName then
					foundItem = k
					break
				end
			end

			if itemCount > dPlayer.inventory[foundItem] then
				TriggerClientEvent('drp/core:showNotification', _source, "Invalid quantity.")
			else
				local remainingCount = dPlayer.inventory[foundItem]
				local total          = itemCount

				if remainingCount < itemCount then
					total = remainingCount
				end

				if total > 0 then
					DRP.Users[_source].removeInventoryItem(foundItem, total)
					DRP.CreatePickup('item', itemName, total, DRP.Items[foundItem].label .. ' [' .. itemCount .. ']', _source)
					TriggerClientEvent('drp/showNotification', _source, 'Dropped ' .. DRP.Items[foundItem].label .. ' x' .. total)
				end
			end

		end
--[[ 
	elseif type == 'item_money' then

		if itemCount == nil or itemCount <= 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		else

			local xPlayer = ESX.GetPlayerFromId(source)

			if itemCount > xPlayer.player.get('money') then
				TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
			else
				local remainingCount = xPlayer.player.get('money')
				local total          = itemCount

				if remainingCount < itemCount then
					total = remainingCount
				end

				if total > 0 then
					xPlayer.removeMoney(total)
					ESX.CreatePickup('item_money', 'money', total, 'Cash' .. ' [' .. itemCount .. ']', _source)
					TriggerClientEvent('esx:showNotification', _source, _U('threw') .. ' [Cash] $' .. total)
				end
			end

		end

	elseif type == 'item_account' then

		if itemCount == nil or itemCount <= 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		else

			local xPlayer = ESX.GetPlayerFromId(source)

			if itemCount > xPlayer.getAccount(itemName).money then
				TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
			else
				local remainingCount = xPlayer.getAccount(itemName).money
				local total          = itemCount

				if remainingCount < itemCount then
					total = remainingCount
				end

				if total > 0 then
					xPlayer.removeAccountMoney(itemName, total)
					ESX.CreatePickup('item_account', itemName, total, Config.AccountLabels[itemName] .. ' [' .. itemCount .. ']', _source)
					TriggerClientEvent('esx:showNotification', _source, _U('threw') .. ' [Cash] $' .. total)
				end
			end

		end

	elseif type == 'item_weapon' then

		local xPlayer      = ESX.GetPlayerFromId(source)
		local weaponName   = itemName
		local weaponLabel  = ESX.GetWeaponLabel(weaponName)
		local weaponPickup = 'PICKUP_' .. weaponName
		
		xPlayer.removeWeapon(itemName)
		if Config.EnableWeaponPickup then
			TriggerClientEvent('esx:pickupWeapon', _source, weaponPickup, weaponName, itemCount)
		end

		TriggerClientEvent('esx:showNotification', _source, _U('threw_weapon', weaponLabel, itemCount)) ]]
	end
end)

RegisterServerEvent('drp/onPickup')
AddEventHandler('drp/onPickup', function(id)
	local _source = source
	local pickup  = DRP.Pickups[id]
	local dPlayer = DRP.GetUserBySource(_source)

	if pickup.type == 'item' then
		local item      = DRP.Items[pickup.name]
		local canTake   = ((item.limit == -1) and (pickup.count)) or ((item.limit - dPlayer.playerData.inventory[pickup.name] > 0) and (item.limit - dPlayer.playerData.inventory[pickup.name])) or 0
		local total     = pickup.count < canTake and pickup.count or canTake
		local remaining = pickup.count - total

		TriggerClientEvent('drp/removePickup', -1, id)

		if total > 0 then
			dPlayer.addInventoryItem(pickup.name, total)
		end

		if remaining > 0 then
			TriggerClientEvent('drp/showNotification', _source, "You cannot pick all of this up, you don't have enough room")
			DRP.CreatePickup('item_standard', pickup.name, remaining, item.label .. ' [' .. remaining .. ']', _source)
		end

--[[ 	elseif pickup.type == 'item_money' then
		TriggerClientEvent('esx:removePickup', -1, id)
		xPlayer.addMoney(pickup.count) ]]
	end
end)
