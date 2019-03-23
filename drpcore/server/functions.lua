DRP.RegisterItemCallback = function(item, cb)
  DRP.UsableItemsCallbacks[item] = cb
end

DRP.UseItem = function(source, item)
  DRP.UsableItemsCallbacks[item](source)
end

DRP.GetItemLabel = function(item)
	if DRP.Items[item] ~= nil then
		return DRP.Items[item].label
	end
end

DRP.GetUserBySource = function(source)
	for k, v in pairs(DRP.Users) do
		if DRP.Users[k].source == source then
			return DRP.Users[k]
		end
	end

	return nil
end

DRP.GetUserByIdentifier = function(identifier)
	for k, v in pairs(DRP.Users) do
		if DRP.Users[k].identifier == identifier then
			return DRP.Users[k]
		end
	end

	return nil
end

DRP.CreatePickup = function(type, name, count, label, player)
	local pickupId = (DRP.PickupId == 65635 and 0 or DRP.PickupId + 1)

	DRP.Pickups[pickupId] = {
		type  = type,
		name  = name,
		count = count
	}

	TriggerClientEvent('drp/pickup', -1, pickupId, label, player)
	DRP.PickupId = pickupId
end
