local currentHours = 0
local currentMinutes = 0
local freezeTime = false
local lockDayTime = false
local activeWeather = {}
local lastZone = 0
local currentWeather = "none"

RegisterNetEvent('drp/sync:time')
AddEventHandler('drp/sync:time', function(cHr, cMin, freeze)
    currentHours = cHr
    currentMinutes = cMin
end)

Citizen.CreateThread(function()
  while true do
    if lockDayTime then
      Citizen.Wait(0)
      NetworkOverrideClockTime(12, 0, 0)
    else
      if freezeTime then
        Citizen.Wait(0)
        NetworkOverrideClockTime(currentHours, currentMinutes, 0)
      else
        Citizen.Wait(2000)
        currentMinutes = currentMinutes + 1
        if currentMinutes > 59 then
          currentHours = currentHours + 1
          currentMinutes = 0
        end
        if currentHours > 23 then
          currentHours = 0
        end
        NetworkOverrideClockTime(currentHours, currentMinutes, 0)
      end
    end
  end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('drp/sync:request')
end)

RegisterCommand("lockday", function()
  lockDayTime = true
end)

RegisterCommand("unlockday", function()
  lockDayTime = false
end)

RegisterNetEvent("drp/sync:weather")
AddEventHandler("drp/sync:weather", function(activeWeathers)
  activeWeather = activeWeathers
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000)
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(PlayerId())))
    local zone = GetNameOfZone(x, y, z)
    if activeWeather[zone] ~= currentWeather then
      ClearOverrideWeather()
      ClearWeatherTypePersist()
      SetWeatherTypeOverTime(wx, 25.0)
      Citizen.Wait(25000)
      SetWeatherTypePersist(wx)
      SetWeatherTypeNow(wx)
      SetWeatherTypeNowPersist(wx)
      lastZone = zone
      currentWeather = wx
    end
  end
end)