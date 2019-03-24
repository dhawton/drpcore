local freezeTime = false
local blackout = false
local newWeatherTimer = 10
local currentMinutes = 0
local currentHours = 0
local timeSyncCooldown = 0
local activeWeatherSystems = {}


print("Math random is seeded.")

RegisterCommand("randomizeweather", function()
  randomizeSystems()
  TriggerClientEvent("drp/sync:weather", -1, activeWeatherSystems)
end)

RegisterServerEvent('drp/sync:request')
AddEventHandler('drp/sync:request', function()
  TriggerClientEvent("drp/sync:weather", source, activeWeatherSystems)
  TriggerClientEvent('drp/sync:time', source, currentHours, currentMinutes, freezeTime)
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
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    randomizeSystems()
    TriggerClientEvent("drp/sync:weather", -1, activeWeatherSystems)
    Citizen.Wait(Config.Weather.Time)
  end
end)

function getCurrentSeason()
  for i, Season in ipairs(Config.Weather.Seasons) do
    for k, month in ipairs(Config.Weather.Seasons[i]) do
      if month == os.date("*t").month then
        return i
      end
    end
  end
end

function randomizeSystems()
  for i, weatherSystem in ipairs(Config.Weather.Systems) do
    local currentSeason = getCurrentSeason()
    local availableWeathers = weatherSystem[currentSeason + 1]
    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()
    local r = math.random(1, #availableWeathers)
    local pickedWeather = availableWeathers[r]
    for _, weatherZone in ipairs(weatherSystem[1]) do
      activeWeatherSystems[weatherZone] = pickedWeather
    end
  end
end