-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.Scenario"                     ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API
  RegisterObservableContent           = API.RegisterObservableContent,
  
  -- Wow API & Utils
  IsInDelve                         = Utils.IsInDelve,
  IsInScenario                      = C_Scenario.IsInScenario,
  IsInJailersTower                  = IsInJailersTower,
  GetCriteriaInfo                   = C_Scenario.GetCriteriaInfo,
  GetBonusSteps                     = C_Scenario.GetBonusSteps,
  GetCriteriaInfoByStep             = C_Scenario.GetCriteriaInfoByStep,
  IsInInstance                      = IsInInstance,
  GetScenarioInfo                   = C_ScenarioInfo.GetScenarioInfo,
  GetScenarioStepInfo               = C_ScenarioInfo.GetScenarioStepInfo
}

SCENARIO_CONTENT_SUBJECT = RegisterObservableContent("scenario", ScenarioContentSubject)

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "SCENARIO_POI_UPDATE" "SCENARIO_UPDATE"
function BecomeActiveOn(self)
  -- Prevent the scenario content to be active in torghast and in the delve
  if IsInJailersTower() or IsInDelve() then
    return false 
  end

  -- Prevent the scenario content to be active in dungeon
  local inInstance, type = IsInInstance()
  if inInstance and (type == "party") then
    return false 
  end

  return IsInScenario()
end

function OnActive(self)
  self:UpdateScenario()
end

function UpdateScenario(self)
  local scenarioInfo = GetScenarioInfo()
  if not scenarioInfo then 
    SCENARIO_CONTENT_SUBJECT.scenario = nil
    return
  end

  local scenarioData = SCENARIO_CONTENT_SUBJECT.scenario


  scenarioData.scenarioID = scenarioInfo.scenarioID
  scenarioData.name = scenarioInfo.name 
  scenarioData.currentStage = scenarioInfo.currentStage
  scenarioData.numStages = scenarioInfo.numStages
  scenarioData.flags = scenarioInfo.flags
  scenarioData.isCompleted = scenarioInfo.isComplete
  scenarioData.xp = scenarioInfo.xp 
  scenarioData.money = scenarioInfo.money
  scenarioData.type = scenarioInfo.type
  scenarioData.area = scenarioInfo.area
  scenarioData.uiTextureKit = scenarioInfo.uiTextureKit

  local scenarioStepInfo = GetScenarioStepInfo()
  if scenarioStepInfo then 
    scenarioData.stepID = scenarioStepInfo.stepID
    scenarioData.stepName = scenarioStepInfo.title 
    scenarioData.stepDescription = scenarioStepInfo.description
    scenarioData.numCriteria = scenarioStepInfo.numCriteria
    scenarioData.isStepFailed = scenarioStepInfo.stepFailed 
    scenarioData.isBonusStep = scenarioStepInfo.isBonusStep
    scenarioData.isForCurrentStepOnly = scenarioStepInfo.isForCurrentStepOnly
    scenarioData.shouldShowBonusObjective = scenarioStepInfo.shouldShowBonusObjective
    scenarioData.spells = scenarioStepInfo.spells
    scenarioData.rewardQuestID = scenarioStepInfo.rewardQuestID
    scenarioData.widgetSetID = scenarioStepInfo.widgetSetID
    scenarioData.stepID = scenarioStepInfo.stepID
    scenarioData.weightedProgress = scenarioStepInfo.weightedProgress

    scenarioData:StartObjectivesCounter()
    if scenarioStepInfo.weightedProgress then 
      -- NOTE: Some scenario (e.g: 7.2 Broken shore introductoin, invasion scenario)
      -- can have an objective progress even if it say numCriteria == 0 so 
      -- we need checking if the step info  has weightedProgress.
      -- if the stage has a weightedProgress, show only this one even if the 
      -- numCriteria say > = 1 
      local objectiveData = scenarioData:AcquireObjective()
      objectiveData.isCompleted   = false
      objectiveData.text          = scenarioStepInfo.description
      objectiveData.hasProgress   = true
      objectiveData.progress      = scenarioStepInfo.weightedProgress
      objectiveData.minProgress   = 0
      objectiveData.maxProgress   = 100
      objectiveData.progressText  = PERCENTAGE_STRING:format(scenarioStepInfo.weightedProgress)
    else
      if scenarioData.numCriteria > 0 then
        for index = 1, scenarioStepInfo.numCriteria do
          local criteriaInfo = GetCriteriaInfo(index)

          local description = criteriaInfo.description
          local completed = criteriaInfo.completed
          local quantity = criteriaInfo.quantity
          local totalQuantity = criteriaInfo.totalQuantity
          local duration = criteriaInfo.duration
          local elapsed = criteriaInfo.elapsed
          local failed = criteriaInfo.failed
          local isWeightedProgress = criteriaInfo.isWeightedProgress

          local objectiveData = scenarioData:AcquireObjective()

          if description and not isWeightedProgress then 
            description = string.format("%d/%d %s", quantity, totalQuantity, description)
          end

          objectiveData.text        = description
          objectiveData.isCompleted = completed
          objectiveData.isFailed    = failed

          if isWeightedProgress then
            objectiveData.hasProgress = true 
            objectiveData.minProgress = 0
            objectiveData.maxProgress = 100
            objectiveData.progress = quantity
            objectiveData.progressText = PERCENTAGE_STRING:format(quantity)
          else
            objectiveData.hasProgress = nil 
            objectiveData.minProgress = nil
            objectiveData.maxProgress = nil
            objectiveData.progress = nil
            objectiveData.progressText = nil
          end          

          local hasTimer = (duration and duration > 0 and not failed and not completed)
          if hasTimer then 
            objectiveData.hasTimer  = true
            objectiveData.startTime = elapsed and GetTime() - elapsed
            objectiveData.duration  = duration
          else
            objectiveData.hasTimer  = nil 
            objectiveData.startTime = nil 
            objectiveData.duration  = nil
          end
        end
      end
    end
    scenarioData:StopObjectivesCounter()

    -- Bonus objectives bonusObjectives
    scenarioData:StartBonusObjectivesCounter()
    local tblBonusSteps = GetBonusSteps()
    local numBonusObjectives = #tblBonusSteps
    if numBonusObjectives > 0 then

      for index = 1, numBonusObjectives do 
        local bonusStepIndex = tblBonusSteps[index]
        local criteriaInfo =  C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, 1)

        local criteriaString = criteriaInfo.description
        local criteriaCompleted = criteriaInfo.completed
        local quantity = criteriaInfo.quantity
        local totalQuantity = criteriaInfo.totalQuantity
        local duration = criteriaInfo.duration
        local elapsed = criteriaInfo.elapsed
        local criteriaFailed = criteriaInfo.failed
        local isWeightedProgress = criteriaInfo.isWeightedProgress

        local bonusObjectiveData = scenarioData:AcquireBonusObjective()

        if criteriaString and not isWeightedProgress then 
          criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
        end

        bonusObjectiveData.text        = criteriaString
        bonusObjectiveData.isCompleted = criteriaCompleted
        bonusObjectiveData.isFailed    = criteriaFailed

        if isWeightedProgress then 
          bonusObjectiveData.hasProgress = true 
          bonusObjectiveData.minProgress = 0
          bonusObjectiveData.maxProgress = 100
          bonusObjectiveData.progress = quantity
          bonusObjectiveData.progressText = PERCENTAGE_STRING:format(quantity)
        else
          bonusObjectiveData.hasProgress = nil 
          bonusObjectiveData.minProgress = nil
          bonusObjectiveData.maxProgress = nil
          bonusObjectiveData.progress = nil
          bonusObjectiveData.progressText = nil
        end          

        local hasTimer = (duration and duration > 0 and not criteriaFailed and not criteriaCompleted)
        if hasTimer then 
          bonusObjectiveData.hasTimer  = true
          bonusObjectiveData.startTime = elapsed and GetTime() - elapsed
          bonusObjectiveData.duration  = duration
        else
          bonusObjectiveData.hasTimer  = nil 
          bonusObjectiveData.startTime = nil 
          bonusObjectiveData.duration  = nil
        end

      end
    end
    scenarioData:StopBonusObjectivesCounter()
  end
end


__SystemEvent__ "SCENARIO_UPDATE" "SCENARIO_POI_UPDATE" "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_COMPLETED"
function UPDATE_SCENARIO()
  _M:UpdateScenario()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(SCENARIO_CONTENT_SUBJECT, "Scenario Content Subject")