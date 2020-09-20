-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                       "SylingTracker.Scenario"                       ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
-- TODO: Clear the model when the player is no longer in a scenario
-- TODO: Implement the bonus objectives and the timer 
-- ========================================================================= --
RegisterContentType = API.RegisterContentType
RegisterModel = API.RegisterModel
-- ========================================================================= --
IsInScenario                      = C_Scenario.IsInScenario
GetInfo                           = C_Scenario.GetInfo
GetStepInfo                       = C_Scenario.GetStepInfo
GetCriteriaInfo                   = C_Scenario.GetCriteriaInfo
GetBonusSteps                     = C_Scenario.GetBonusSteps
GetCriteriaInfoByStep             = C_Scenario.GetCriteriaInfoByStep
GetBasicCurrencyInfo              = C_CurrencyInfo.GetBasicCurrencyInfo
IsInInstance                      = IsInInstance
-- ========================================================================= --
_ScenarioModel = RegisterModel(Model, "scenario-data")
NIL_DATA       = Model.NIL_DATA
-- ========================================================================= --
RegisterContentType({
  ID = "scenario",
  DisplayName = "Scenario",
  Description = "Display the scenario",
  DefaultOrder = 5,
  DefaultModel = _ScenarioModel,
  DefaultViewClass = ScenarioContentView,
  Events = { "PLAYER_ENTERING_WORLD", "SCENARIO_POI_UPDATE", "SCENARIO_UPDATE"},
  Status = function()
    -- Prevent the scenario content to be shown in dungeon
    local inInstance, type = IsInInstance()
    if inInstance and (type == "party") then 
      return false 
    end 

    return IsInScenario()
  end 
})


__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  _M:UpdateScenario()
  _M:UpdateObjectives()

  _ScenarioModel:Flush()
end

__SystemEvent__ "SCENARIO_POI_UPDATE" "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_COMPLETED"
function OBJECTIVES_UPDATE()
  _M:UpdateObjectives()

  _ScenarioModel:Flush()
end

__SystemEvent__()
function SCENARIO_UPDATE(...)
  _M:UpdateScenario(...)
  _M:UpdateObjectives()

  _ScenarioModel:Flush()
end

function UpdateScenario(self, isNewStage)
  local title, currentStage, numStages, flags, _, _, _, xp, money, scenarioType = GetInfo()
  local scenarioData = {
    title         = title,
    name          = title,
    currentStage  = currentStage,
    numStages     = numStages,
    flags         = flags,
    xp            = xp, 
    money         = money,
    scenarioType  = scenarioType
  }

  _ScenarioModel:AddData(scenarioData, "scenario")
end 

function UpdateObjectives(self)
  local stageName, stageDescription, numObjectives, _, _, _, _, numSpells, spellInfo, weightedProgress, rewardQuestID, widgetSetID = GetStepInfo()
  local scenarioData = {
    stageName = stageName,
    stageDescription = stageDescription,
    numObjectives = numObjectives,
    numSpells = numSpells,
    spellInfo = spellInfo,
    weightedProgress = weightedProgress,
    rewardQuestID = rewardQuestID,
    widgetSetID = widgetSetID
  }

  if weightedProgress then 
    -- NOTE: Some scenario (e.g: 7.2 Broken shode introduction, invasion scenario )
    -- can have an objective progress even if it say numObjectives == 0 so
    -- we need checking if te step info has weightedProgress.
    -- If the stage has a weightedProgress, show only this one even if the
    -- numObjectives say >= 1
    scenarioData.objectives = {
      [1] = {
        text            = stageDescription,
        isCompleted     = false,
        hasProgressBar  = true,
        progress        = weightedProgress,
        minProgress     = 0,
        maxProgress     = 100,
        progressText    = PERCENTAGE_STRING:format(progress)
      }
    }
  else
    if numObjectives > 0 then 
      local objectivesData = {}
      for index = 1, numObjectives do
        local description, criteriaType, completed, quantity, totalQuantity,
        flags, assetID, quantityString, criteriaID, duration, elapsed,
        failed, isWeightProgress = GetCriteriaInfo(index)

        local data = {
          text              = description,
          criteriaType      = criteriaType,
          isCompleted       = completed,
          quantity          = quantity,
          totalQuantity     = totalQuantity,
          flags             = flags,
          assetID           = assetID,
          quantityString    = quantityString,
          criteriaID        = criteriaID,
          duration          = duration,
          elapsed           = elapsed,
          failed            = failed,
          isWeightProgress  = isWeightProgress
        }

        objectivesData[index] = data 
      end
      scenarioData.objectives = objectivesData
    end

    -- Bonus objectives
    local tblBonusSteps = GetBonusSteps()
    local numBonusObjectives = #tblBonusSteps
    if numBonusObjectives > 0 then 
      local bonusObjectivesData = {}
      for index = 1, numBonusObjectives do 
        local bonusStepIndex = tblBonusSteps[index]
        local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, 
        flags, assetID, quantityString, criteriaID, duration, elapsed, 
        criteriaFailed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, 1)

        local data = {
          text              = criteriaString,
          criteriaType      = criteriaType,
          isCompleted       = criteriaCompleted,
          quantity          = quantity,
          totalQuantity     = totalQuantity,
          flags             = flags,
          assetID           = assetID,
          quantityString    = quantityString,
          criteriaID        = criteriaID,
          duration          = duration,
          elapsed           = elapsed,
          failed            = criteriaFailed,
          isWeightProgress  = isWeightProgress
        }

        -- Hide the timer if the criteria has been complated or failed
        if duration and duration > 0 and not criteriaFailed and not criteriaCompleted then
          data.hasTimer = true 
          data.startTime = GetTime() - elapsed
        else
          data.hasTimer = NIL_DATA
          data.startTime = NIL_DATA
        end

        bonusObjectivesData[index] = data
      end
      scenarioData.bonusObjectives = bonusObjectivesData
    end 
  end

  _ScenarioModel:AddData(scenarioData, "scenario")
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_ScenarioModel, "ScenarioModel")
end
