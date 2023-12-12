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
  GetDeathCount                       = C_ChallengeMode.GetDeathCount,
  GetMapUIInfo                        = C_ChallengeMode.GetMapUIInfo,
  GetActiveChallengeMapID             = C_ChallengeMode.GetActiveChallengeMapID,
  GetInstanceTextureFileID            = Utils.GetInstanceTextureFileID
}

KEYSTONE_CONTENT_SUBJECT              = RegisterObservableContent("keystone", KeystoneContentSubject)
GET_ACCURATE_TIMER_TASK_RUNNING       = false

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START"
function BecomeActiveOn(self)
  return GetActiveKeystoneInfo() > 0
end

__Async__()
function OnActive(self)
  self:UpdateKeystoneInfo()
  self:UpdateDungeonTexture()
  self:UpdateObjectives()
  self:UpdateDeathCounter()

  if self:IsActivateByEvent("PLAYER_ENTERING_WORLD") then
    -- IMPORTANT !!!
    -- During a reload, elapsed returned by GetWorldElapsedTime(1) don't change even
    -- after some seconds, causing a desync on the timer. 
    -- This problem seems occur on the event triggered before 'LOADING_SCREEN_DISABLED' (itself included)
    -- so 'PLAYER_ENTERING_WORLD' is also affected.
    --
    -- FROM 'UPDATE_INSTANCE_INFO' event, the elpased become correct so this is why
    -- we wait this event is tiggered for getting the timer after a reload.
    Wait("UPDATE_INSTANCE_INFO")
    self:GetAccurateTimer()
  end
end

function OnInactive(self)
  GET_ACCURATE_TIMER_TASK_RUNNING = false
  KEYSTONE_CONTENT_SUBJECT:ResetDataProperties()
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

__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_UPDATE"
function KEYSTONE_UPDATE()
  _M:UpdateDungeonTexture()
  _M:UpdateObjectives()
end

__SystemEvent__()
__Async__() function CHALLENGE_MODE_START()
  KEYSTONE_CONTENT_SUBJECT.startTime = GetTime() + 10
  KEYSTONE_CONTENT_SUBJECT.started = false

  -- When the player exists the instance then re-enters it, 'CHALLENGE_MODE_START'
  -- is triggered, followed by 'WORLD_STATE_TIMER_START'.
  -- In this case, we call 'GetAccurateTimer' for setting an accurate timer.
  local arg1 = Wait(1, "WORLD_STATE_TIMER_START")
  if arg1 and arg1 == "WORLD_STATE_TIMER_START" then 
    _M:GetAccurateTimer()
    return
  end

  -- If we are here, this is because:
  -- 1. The player just starts a key.
  -- or 2. The player login in the instance while the key is running as WORLD_STATE_TIMER_START isn't called after CHALLENGE_MODE_START

  -- We need only to handle the second case as the first case will be handled by 'WORLD_STATE_TIMER_START' callback.
  local elapsed = select(2, GetWorldElapsedTime(1))
  if elapsed and elapsed > 0 then 
    _M:GetAccurateTimer()
  end
end

--- This function can be called only once by run or reload. 
__Async__() function GetAccurateTimer()
  local _, elapsed, type = GetWorldElapsedTime(1)

  if not type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then 
    return 
  end

  if GET_ACCURATE_TIMER_TASK_RUNNING then 
    return 
  end

  GET_ACCURATE_TIMER_TASK_RUNNING = true
  
  local nextElapsed = elapsed + 1
  local nextTime 

  while GET_ACCURATE_TIMER_TASK_RUNNING and elapsed ~= nextElapsed do 
    _, elapsed = GetWorldElapsedTime(1)
    nextTime = GetTime()

    Next()
  end

  KEYSTONE_CONTENT_SUBJECT.started    = true
  KEYSTONE_CONTENT_SUBJECT.startTime  = nextTime - elapsed
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
