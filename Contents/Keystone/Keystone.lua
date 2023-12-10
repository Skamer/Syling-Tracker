-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Keystone"                         ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API 
  RegisterObservableContent           = API.RegisterObservableContent,

  -- WoW API & Utils
  GetInfo                             = C_Scenario.GetInfo,
  GetStepInfo                         = C_Scenario.GetStepInfo,
  GetCriteriaInfo                     = C_Scenario.GetCriteriaInfo,
  GetActiveKeystoneInfo               = C_ChallengeMode.GetActiveKeystoneInfo,
  GetAffixInfo                        = C_ChallengeMode.GetAffixInfo,
  GetDeathCount                       =  C_ChallengeMode.GetDeathCount,
  GetMapUIInfo                        = C_ChallengeMode.GetMapUIInfo,
  GetActiveChallengeMapID             = C_ChallengeMode.GetActiveChallengeMapID,
  GetInstanceTextureFileID            = Utils.GetInstanceTextureFileID
}

KEYSTONE_CONTENT_SUBJECT = RegisterObservableContent("keystone", KeystoneContentSubject)

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START"
function BecomeActiveOn(self)
  return GetActiveKeystoneInfo() > 0
end

function OnActive(self)
  self:UpdateKeystoneInfo()
  self:UpdateDungeonTexture()
  self:UpdateObjectives()
  self:UpdateDeathCounter()
end

function UpdateObjectives(self)
  local name, _, numObjectives = GetStepInfo()
  KEYSTONE_CONTENT_SUBJECT.name = name

  KEYSTONE_CONTENT_SUBJECT:StartObjectivesCounter()
  if numObjectives > 0 then 
    for index = 1, numObjectives do 
      local description, criteriaType, completed, quantity, totalQuantity,
      flags, assetID, quantityString, criteriaID, duration, elapsed,
      failed, isWeightProgress = GetCriteriaInfo(index)

      if not isWeightProgress then 
        local objectiveData = KEYSTONE_CONTENT_SUBJECT:AcquireObjective()
        objectiveData.text = description
        objectiveData.isCompleted = completed
      else 
        -- if there is weight progress, we can say this is 'Enemy Forces'
        local quantity = tonumber(strsub(quantityString, 1, -2))
        KEYSTONE_CONTENT_SUBJECT.enemyForcesQuantity = quantity
        KEYSTONE_CONTENT_SUBJECT.enemyForcesTotalQuantity = totalQuantity
      end
    end
  end
  KEYSTONE_CONTENT_SUBJECT:StopObjectivesCounter()
end

function UpdateDungeonTexture()
  local textureFileID
  local currentMapID = select(8, GetInstanceInfo())
  if currentMapID then
    textureFileID = GetInstanceTextureFileID(currentMapID)
  end

  KEYSTONE_CONTENT_SUBJECT.textureFileID = textureFileID
end


function UpdateKeystoneInfo()
  local level, affixes, wasEnergized = GetActiveKeystoneInfo()
  local challengeMapID = GetActiveChallengeMapID()

  if not challengeMapID then 
    return 
  end

  local _, _, timeLimit = GetMapUIInfo(challengeMapID)

  KEYSTONE_CONTENT_SUBJECT.level = level
  KEYSTONE_CONTENT_SUBJECT.timeLimit = timeLimit

  KEYSTONE_CONTENT_SUBJECT:StartAffixesCounter()
  for index, affixID in ipairs(affixes) do 
    local name, description, texture = GetAffixInfo(affixID)
    local affixData = KEYSTONE_CONTENT_SUBJECT:AcquireAffix()
    
    affixData.affixID = affixID
    affixData.name = name
    affixData.texture = texture
    affixData.description = description 
  end
  KEYSTONE_CONTENT_SUBJECT:StopAffixesCounter()
end

function UpdateDeathCounter()
  local death, timeLost = GetDeathCount()
  KEYSTONE_CONTENT_SUBJECT.deathCount = death
end

--- IMPORTANT !!!
--- During a reload, elapsed returned by GetWorldElapsedTime(1) don't change even
--- after some seconds, causing a desync on the timer. 
--- This problem seems occur on the event triggered before 'LOADING_SCREEN_DISABLED' (itself included)
--- so 'PLAYER_ENTERING_WORLD' is also affected.
---
--- FROM 'UPDATE_INSTANCE_INFO' event, the elpased become correct so this is best 
--- place for getting the timer after a reload.
__SystemEvent__()
function UPDATE_INSTANCE_INFO()
  local _, elapsed, type = GetWorldElapsedTime(1)

  if not type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then 
    return 
  end
  
  if KEYSTONE_CONTENT_SUBJECT.started  then 
    return 
  end

  local nextElapsed = elapsed + 1
  local nextTime 

  while elapsed ~= nextElapsed do 
    _, elapsed = GetWorldElapsedTime(1)
    nextTime = GetTime()
  end

  KEYSTONE_CONTENT_SUBJECT.started    = true
  KEYSTONE_CONTENT_SUBJECT.startTime  = nextTime - elapsed
end

__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_UPDATE"
function KEYSTONE_UPDATE()
  _M:UpdateDungeonTexture()
  _M:UpdateObjectives()
end

__SystemEvent__()
function CHALLENGE_MODE_START()
  KEYSTONE_CONTENT_SUBJECT.startTime = GetTime() + 10
  KEYSTONE_CONTENT_SUBJECT.started = false
end


__SystemEvent__()
function WORLD_STATE_TIMER_START(timerID)
  -- For unknow reasons, 'WORLD_STATE_TIMER_START' is triggered when someone die
  -- causing the timer to reset. This is why we need to check if the run is started.
  if not KEYSTONE_CONTENT_SUBJECT.started then 
    KEYSTONE_CONTENT_SUBJECT.startTime = GetTime()
    KEYSTONE_CONTENT_SUBJECT.started = true
  end
end

__SystemEvent__()
function WORLD_STATE_TIMER_STOP(timerID)
  KEYSTONE_CONTENT_SUBJECT.completed = true
  KEYSTONE_CONTENT_SUBJECT.started = false
end

__SystemEvent__()
function CHALLENGE_MODE_DEATH_COUNT_UPDATED()
  _M:UpdateDeathCounter()

  local _, elapsed, type = GetWorldElapsedTime(1)
  -- We reduce the start time for advancing the timer of '5' seconds.
  KEYSTONE_CONTENT_SUBJECT.startTime = KEYSTONE_CONTENT_SUBJECT.startTime - 5
end

__SystemEvent__()
function SylingTracker_ENEMY_PULL_COUNT_CHANGED(total)
  KEYSTONE_CONTENT_SUBJECT.enemyForcesPendingQuantity = total
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(KEYSTONE_CONTENT_SUBJECT, "Keystone Content Subject")
