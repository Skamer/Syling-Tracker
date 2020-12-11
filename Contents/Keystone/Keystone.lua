-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.Keytone"                            ""
-- ========================================================================= --
import                          "SLT"
-- ========================================================================= --
_Active                           = false 
-- ========================================================================= --
RegisterContentType               = API.RegisterContentType
RegisterModel                     = API.RegisterModel
TruncateDecimal                   = Utils.Math.TruncateDecimal
-- ========================================================================= --
GetPowerLevelDamageHealthMod      = C_ChallengeMode.GetPowerLevelDamageHealthMod
GetActiveKeystoneInfo             = C_ChallengeMode.GetActiveKeystoneInfo
GetAffixInfo                      = C_ChallengeMode.GetAffixInfo
GetMapInfo                        = C_ChallengeMode.GetMapUIInfo
GetActiveChallengeMapID           = C_ChallengeMode.GetActiveChallengeMapID
GetDeathCount                     = C_ChallengeMode.GetDeathCount
GetWorldElapsedTimers             = GetWorldElapsedTimers
GetWorldElapsedTime               = GetWorldElapsedTime
EJ_GetCurrentInstance             = EJ_GetCurrentInstance
EJ_GetInstanceInfo                = EJ_GetInstanceInfo
GetInfo                           = C_Scenario.GetInfo
GetStepInfo                       = C_Scenario.GetStepInfo
GetCriteriaInfo                   = C_Scenario.GetCriteriaInfo
-- ========================================================================= --
_KeystoneModel = RegisterModel(Model, "keystone-data")
-- ========================================================================= --
RegisterContentType({
  ID = "keystone",
  DisplayName = "Keystone (Mythic +)",
  DefaultOrder = 30,
  DefaultModel = _KeystoneModel,
  DefaultViewClass = KeystoneContentView,
  Events = { "PLAYER_ENTERING_WORLD", "CHALLENGE_MODE_START" },
  Status = function()
    return GetActiveKeystoneInfo() > 0 
  end
})
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START"
function ActiveOn(self)
  return GetActiveKeystoneInfo() > 0
end
-- ========================================================================= --
function OnActive(self)
  self:UpdateKeystoneInfo()
  self:UpdateTimer()
  self:UpdateObjectives()
  self:UpdateInstanceMap()
  CHALLENGE_MODE_DEATH_COUNT_UPDATED()

  _KeystoneModel:Flush()
end

function OnInactive(self)
  _KeystoneModel:ClearData()
end
-- ========================================================================= --
-- Helper function for getting the enemy forces percentage
local function GetPercentageString(current, total)
  local decimal = 2

  if decimal == 0 then
    return format("%i%%", math.floor(current/total*100))
  elseif decimal == 1 then
    return format("%.1f%%", TruncateDecimal(current/total*100, 1))
  elseif decimal == 2 then
    return format("%.2f%%", TruncateDecimal(current/total*100, 2))
  end

  return format("%i", current/total*100)
end

__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_UPDATE" "SCENARIO_UPDATE"
function UpdateObjectives()
  local dungeonName, _, numObjectives = GetStepInfo()
  local completed = select(7, GetInfo())

  local objectivesData = {}

  for index = 1, numObjectives do
       local description, _, completed, c, totalQuantity, _, _, quantityString,
    _, _, _, _, isWeightProgress = GetCriteriaInfo(index)

    local data = {
      text        = description,
      isCompleted = completed
    }

    if isWeightProgress then 
      -- if there is weight progress, we can say this is 'Enemy Forces'
      local quantity = tonumber(strsub(quantityString, 1, -2))
      
      data.hasProgressBar = true 
      data.progress = quantity
      data.minProgress = 0
      data.maxProgress = totalQuantity
      -- data.progressText = string.format("%i/%i", quantity, totalQuantity)
      data.progressText = format("%i/%i (%s)", quantity, totalQuantity, GetPercentageString(quantity, totalQuantity))
    else 
      data.hasProgressBar = nil 
    end

    objectivesData[index] = data
  end
  
  local data = {
    name          = dungeonName,
    numObjectives = numObjectives,
    completed     = completed,
    objectives    = objectivesData
  }

  _KeystoneModel:AddData(data, "keystone")
  _KeystoneModel:Flush()
end

__SystemEvent__()
function CHALLENGE_MODE_DEATH_COUNT_UPDATED()
  _M:UpdateDeathCount()
  _KeystoneModel:Flush()
end

__Async__()
function UpdateTimer(self)
  local _, elapsed, type = GetWorldElapsedTime(1)
  if type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then 
    local nextElapsed = elapsed + 1
    local nextTime
    
    while elapsed ~= nextElapsed do
      _, elapsed = GetWorldElapsedTime(1)
      nextTime   = GetTime()
      
      Next()
    end 

    _KeystoneModel:AddData({ startTime = nextTime - elapsed}, "keystone")
    _KeystoneModel:Flush()
  end
end

__SystemEvent__()
function WORLD_STATE_TIMER_START(timerID)
  _M:UpdateTimer()
  _KeystoneModel:Flush()
end

__SystemEvent__()
function WORLD_STATE_TIMER_STOP(timerID)
  _KeystoneModel:AddData({ completed = true }, "keystone")
  _KeystoneModel:Flush()
end

function UpdateKeystoneInfo()
  local level, affixes, wasEnergized = GetActiveKeystoneInfo()
  local numAffixes = #affixes
  local affixesData = {}

  for index, affixID in ipairs(affixes) do 
    local name, desc, texture = GetAffixInfo(affixID)

    affixesData[index] = {
      name  = name,
      desc  = desc,
      texture =  texture,
      affixID = affixID
    }
  end

  _KeystoneModel:AddData({
    level = level,
    affixes = affixesData,
    numAffixes = numAffixes,
    wasEnergized = wasEnergized
  }, "keystone")
end

function UpdateInstanceMap(self)
  local mapID = GetActiveChallengeMapID()
  if mapID then
    local _, _, timeLimit, texture = GetMapInfo(mapID)
    _KeystoneModel:AddData({
      timeLimit = timeLimit,
      texture = texture
    }, "keystone")
  end
end


function UpdateDeathCount()
  local death, timeLost = GetDeathCount()
  _KeystoneModel:AddData({
    death = death,
    timeLost = timeLost,
  }, "keystone")
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_KeystoneModel, "SLT Keystone Model")
end

-----------------------------------------------------------------------------
-- Fixture DATA  --
-----------------------------------------------------------------------------
-- function LoadFixtures(self)
--   local affixesData = {}
--   for i = 1, 4 do 
--     local name, desc, texture = GetAffixInfo(i)
--     affixesData[i] = {
--       name = name,
--       desc = desc,
--       texture = texture, 
--       affixID = i 
--     }
--   end 

--   local data = {
--     icon = 1411869,
--     name = "L'Arcavia",
--     numObjectives = 5,
--     death = 2,
--     timeLost = 10,
--     level = 14,
--     affixes = affixesData,
--     objectives = {
--       [1] = { isCompleted = false,  text = "Ivanyr vaincu"},
--       [2] = { isCompleted = false,  text = "Corstilax vaincu"},
--       [3] = { isCompleted = false,  text = "General Xakal vaincu"},
--       [4] = { isCompleted = false,  text = "Nal'tira vaincue"},
--       [5] = { isCompleted = false,  text = "Conseiller Vandros vaincu"},
--       [6] = { 
--         isCompleted = false, 
--         text = "Force Enemie", 
--         hasProgressBar = true,
--         progress = 50,
--         minProgress = 0,
--         maxProgress = 250,
--         progressText = "50 / 250"
--       }
--     }
--   }

--   _KeystoneModel:AddData(data, "keystone")
--   _KeystoneModel:Flush()
-- end
