local freezeTime = false
local blackout = false
local newWeatherTimer = 10
local currentMinutes = 0
local currentHours = 0
local timeSyncCooldown = 0

RegisterServerEvent('drp/sync:request')
AddEventHandler('drp/sync:request', function()
    TriggerClientEvent('drp/sync:time', -1, currentHours, currentMinutes, freezeTime)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(2000)
    currentMinutes = currentMinutes+1
    if currentMinutes > 59 then
      currentHours = currentHours + 1
      currentMinutes = 0
    end
    if currentHours > 23 then
      currentHours = 0
    end
    -- Update clients every 5 seconds or so
    if GetGameTimer() - timeSyncCooldown > 5000 then
      TriggerClientEvent("drp/sync:time", -1, currentHours, currentMinutes, freezeTime)
      timeSyncCooldown = GetGameTimer()
    end
end)
