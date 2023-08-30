-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Dungeon"                ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API
  RegisterObservableContent = API.RegisterObservableContent,

  IsInScenario                        = C_Scenario.IsInScenario,
  GetInfo                             = C_Scenario.GetInfo,
  GetStepInfo                         = C_Scenario.GetStepInfo,
  GetCriteriaInfo                     = C_Scenario.GetCriteriaInfo,
  GetActiveKeystoneInfo               = C_ChallengeMode.GetActiveKeystoneInfo
}

DUNGEON_CONTENT_SUBJECT = RegisterObservableContent("dungeon", DungeonContentSubject)


__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START" "SCENARIO_UPDATE" "ZONE_CHANGE"
function BecomeActiveOn(self)
  local inInstance, type = IsInInstance()
  return inInstance and (type == "party") and IsInScenario() and GetActiveKeystoneInfo() == 0  
end


function OnActive(self)
  self:LoadAndUpdate()
end


function LoadAndUpdate(self)
  local name, _, numObjectives = GetStepInfo()
  DUNGEON_CONTENT_SUBJECT.name = name 
  DUNGEON_CONTENT_SUBJECT.numObjectives = numObjectives

  local objectiveCount = 0
  if numObjectives > 0 then 
    for index = 1, numObjectives do 
      local description, criteriaType, completed, quantity, totalQuantity,
      flags, assetID, quantityString, criteriaID, duration, elapsed,
      failed, isWeightProgress = GetCriteriaInfo(index)

      local objectiveData = DUNGEON_CONTENT_SUBJECT:AcquireObjective(objectiveCount + 1)
      objectiveCount = objectiveCount + 1

      objectiveData.text = description
      objectiveData.isCompleted = completed
    end
  end

  DUNGEON_CONTENT_SUBJECT:SetObjectivesCount(objectiveCount)
end

__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_UPDATE"
function DUNGEON_UPDATE()
  _M:LoadAndUpdate()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(DUNGEON_CONTENT_SUBJECT, "Dungeon Content Subject")