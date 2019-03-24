Config = {}
Config.Weather = {}
Config.Weather = setmetatable(Config.Weather, {})
Config.Weather.Types = {
  "CLEAR",        -- 1
  "EXTRASUNNY",   -- 2
  "CLOUDS",       -- 3
  "OVERCAST",     -- 4
  "RAIN",         -- 5
  "CLEARING",     -- 6
  "THUNDER",      -- 7
  "SMOG",         -- 8
  "FOGGY",        -- 9
  "XMAS",         -- 10
  "SNOWLIGHT",    -- 11
  "BLIZZARD"      -- 12
}

Config.Weather.Time = 15 * 60 * 1000 -- 15 minutes
Config.Weather.Systems = {
  {
    {
      "TERMINA", "ELYSIAN", "AIRP", "BANNING", "DELSOL", "RANCHO", "STRAW", "CYPRE", "SANAND", "VINE",
      "MURRI", "LMESA", "SKID", "LEGSQU", "TEXTI", "PBOX", "KOREAT",
      "MIRR", "EAST_V", "DTVINE", "ALTA", "HAWICK", "BURTON", "ROCKF", "MOVIE", "DELPE", "MORN", "RICHM", "GOLF", "WVINE", "DTVINE", "HORS", "LACT", "LDAM",
      "CHIL", "GREATC", "RGLEN", "TONGVAV", "DAVIS", "EBURO", "LOSPUER", "STAD", "ZP_ORT", "VINE", "DOWNT"
    },
    { Config.Weather.Types[10] },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[3],
      Config.Weather.Types[4], Config.Weather.Types[5], Config.Weather.Types[6],
      Config.Weather.Types[7], Config.Weather.Types[8], Config.Weather.Types[9],
      Config.Weather.Types[11], Config.Weather.Types[12] 
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[3],
      Config.Weather.Types[4], Config.Weather.Types[5], Config.Weather.Types[6],
      Config.Weather.Types[7], Config.Weather.Types[8], Config.Weather.Types[9]
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[3],
      Config.Weather.Types[4], Config.Weather.Types[5], Config.Weather.Types[6],
      Config.Weather.Types[9], Config.Weather.Types[11], Config.Weather.Types[12] 
    },
  },
  {
    {
      "BEACH", "VESP", "VCANA", "DELBE", "PBLUFF",
      "BANHAMC", "BANHAMCA", "CHU", "TONGVAH",
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[3], Config.Weather.Types[4], Config.Weather.Types[5], Config.Weather.Types[6]
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[3], Config.Weather.Types[4], Config.Weather.Types[5], Config.Weather.Types[6]
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[3], Config.Weather.Types[4], Config.Weather.Types[6]
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[3], Config.Weather.Types[4], Config.Weather.Types[5], Config.Weather.Types[6]
    },
  },
  {
    {
      "PALMPOW", "WINDF", "JAIL", "DESRT", "SANDY", "ZQ_UAR", "HUMLAB", "SANCHIA", "GRAPES", "ALAMO", "SLAB", "CALAFAB", "NOOSE"
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[6], Config.Weather.Types[7]
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[6], Config.Weather.Types[7]
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[6], Config.Weather.Types[7]
    },
    {
      Config.Weather.Types[1], Config.Weather.Types[2], Config.Weather.Types[6], Config.Weather.Types[7]
    },
  },
  {
    { "LAGO", "ARMYB", "NCHU", "CANNY", "MTJOSE", "HARMO", "RTRACK", "ZANCUDO", "CCREAK", "CHAMH", "CANNY", "TATAMO", "ZANCUDO", "PALHIGH" },
    {
      Config.Weather.Types[9],Config.Weather.Types[8],Config.Weather.Types[1],Config.Weather.Types[3],Config.Weather.Types[4],Config.Weather.Types[5],Config.Weather.Types[11]
    },
    {
      Config.Weather.Types[9],Config.Weather.Types[8],Config.Weather.Types[1],Config.Weather.Types[3],Config.Weather.Types[4],Config.Weather.Types[5],Config.Weather.Types[6]
    },
    {
      Config.Weather.Types[9],Config.Weather.Types[8],Config.Weather.Types[1],Config.Weather.Types[3],Config.Weather.Types[4],Config.Weather.Types[5]
    },
    {
      Config.Weather.Types[9],Config.Weather.Types[8],Config.Weather.Types[1],Config.Weather.Types[3],Config.Weather.Types[4],Config.Weather.Types[5],Config.Weather.Types[11]
    },
  }, -- Zancudo
  {
    { 
      "MTGORDO", "ELGORL", "BRADP", "BRADT", "MTCHIL", "GALFISH",
      "CMSW", "PALCOV", "OCEANA", "PALFOR", "PALETO", "PROCOB"
    },
    {
      Config.Weather.Types[10]
    },
    {
      Config.Weather.Types[9],Config.Weather.Types[8],Config.Weather.Types[1],Config.Weather.Types[3],Config.Weather.Types[4],Config.Weather.Types[5],Config.Weather.Types[11]
    },
    {
      Config.Weather.Types[9],Config.Weather.Types[8],Config.Weather.Types[1],Config.Weather.Types[3],Config.Weather.Types[4],Config.Weather.Types[5]
    },
    {
      Config.Weather.Types[9],Config.Weather.Types[8],Config.Weather.Types[1],Config.Weather.Types[3],Config.Weather.Types[4],Config.Weather.Types[5],Config.Weather.Types[11]
    },
  },
}

Config.Weather.Seasons = {
  {12}, -- Winter 1
  {1, 2, 3, 4}, -- Spring 2
  {5, 6, 7, 8}, -- Summer 3
  {9, 10, 11} -- Fall
}