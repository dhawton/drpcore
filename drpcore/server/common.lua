DRP = {}
DRP.Items = {}
DRP.UsableItemsCallbacks = {}
DRP.Users = {}
DRP.Pickups = {}
DRP.PickupId = 0

AddEventHandler('drp:getSharedObject', function(cb)
	cb(DRP)
end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for i=1, #result, 1 do
			DRP.Items[result[i].name] = {
				label     = result[i].label,
				limit     = result[i].limit,
				canRemove = (result[i].can_remove == 1 and true or false),
				usable = false
			}
		end
	end)
end)
