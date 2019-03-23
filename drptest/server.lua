DRP = nil

TriggerEvent('drp/getSharedObject', function(obj)
  DRP = obj 
end)

RegisterNetEvent("drp/test:print")
AddEventHandler("drp/test:print", function()
  local dPlayer = DRP.GetUserBySource(source)
  dPlayer.addInventoryItem("gold", 1)
  dPlayer.removeInventoryItem("wool", 1)
end)