-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Contents.Delve"                       ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
    -- Addon API
    RegisterObservableContent                       = API.RegisterObservableContent,
    GetObservableContent                            = API.GetObservableContent,

    -- WoW API & Utils 
    IsInDelve                                       = Utils.IsInDelve,
    GetCriteriaInfo                                 = C_Scenario.GetCriteriaInfo,
    GetBonusSteps                                   = C_Scenario.GetBonusSteps,
    GetCriteriaInfoByStep                           = C_Scenario.GetCriteriaInfoByStep,
    GetScenarioInfo                                 = C_ScenarioInfo.GetScenarioInfo,
    GetScenarioStepInfo                             = C_ScenarioInfo.GetScenarioStepInfo,
    GetScenarioHeaderDelvesWidgetVisualizationInfo  = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo
}

DELVE_DATA = RegisterObservableContent("delve", DelveContentSubject)
DELVE_WIDGET_ID = 6183

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "SCENARIO_POI_UPDATE" "SCENARIO_UPDATE" "ZONE_CHANGE" "ZONE_CHANGED_NEW_AREA"
function BecomeActiveOn(self, event)
  return IsInDelve()
end

function OnActive(self)
    self:UpdateDelve()
end

function OnInactive(self)
  DELVE_DATA:ResetDataProperties()
end

function UpdateDelve(self)
    local scenarioInfo = GetScenarioInfo()

    if not scenarioInfo then 
      return 
    end

    DELVE_DATA.isCompleted = scenarioInfo.isComplete

    local scenarioStepInfo = GetScenarioStepInfo()
    if not scenarioStepInfo then 
        return 
    end

    local numCriteria = scenarioStepInfo.numCriteria
    
    DELVE_DATA.name         = scenarioStepInfo.title
    DELVE_DATA.numCriteria  = numCriteria

    local widgetInfo = GetScenarioHeaderDelvesWidgetVisualizationInfo(DELVE_WIDGET_ID)

    -- Get the tier
    DELVE_DATA.tierText           = widgetInfo.tierText
    DELVE_DATA.tierTooltipSpellID = widgetInfo.tierTooltipSpellID

    -- Get the modifiers 
    local modifiers = widgetInfo.spells
    local modifiersCount = 0
    if modifiers then
      DELVE_DATA:StartModifiersCounter()
      for index, modifier in ipairs(modifiers) do 
        if modifier.shownState == 1 then 
          local modifierData  = DELVE_DATA:AcquireModifier()
          local spellID       = modifier.spellID

          modifierData.modifierID   = spellID
          modifierData.name         = GetSpellName(spellID)
          modifierData.description  = GetSpellDescription(spellID)
          modifierData.texture      = GetSpellTexture(spellID)
         
          modifiersCount            = modifiersCount + 1
        end
      end
      DELVE_DATA:StopModifiersCounter()

      DELVE_DATA.modifiersCount = modifiersCount
    end

    -- Get the revives (considered as currencies)
    local currencies = widgetInfo.currencies
    local reviveInfo = currencies and currencies[1]

    if reviveInfo then
      DELVE_DATA.showRevives = true
      DELVE_DATA.hasRemainingRevives = reviveInfo.textEnabledState ~= 2
      DELVE_DATA.reviveText = reviveInfo.text
      DELVE_DATA.reviveTooltip = reviveInfo.tooltip
    else
      DELVE_DATA.showRevives = nil
      DELVE_DATA.hasRemainingRevives = nil
      DELVE_DATA.reviveText = nil 
      DELVE_DATA.reviveTooltip = nil
    end

    -- Get reward 
    local rewardInfo = widgetInfo.rewardInfo
    if rewardInfo then    
      DELVE_DATA.showReward             = rewardInfo.shownState > 0 
      DELVE_DATA.hasEarnedReward        = rewardInfo.shownState == 1
      DELVE_DATA.earnedRewardTooltip    = rewardInfo.earnedTooltip
      DELVE_DATA.unearnedRewardTooltip  = rewardInfo.unearnedTooltip
    else 
      DELVE_DATA.showReward             = nil
      DELVE_DATA.hasEarnedReward        = nil
      DELVE_DATA.earnedRewardTooltip    = nil
      DELVE_DATA.unearnedRewardTooltip  = nil
    end

    -- Get the objectives
    DELVE_DATA:StartObjectivesCounter()
    if numCriteria and numCriteria > 0 then
        for index = 1, numCriteria do
          local criteriaInfo = GetCriteriaInfo(index)

          local description         = criteriaInfo.description
          local completed           = criteriaInfo.completed
          local quantity            = criteriaInfo.quantity
          local totalQuantity       = criteriaInfo.totalQuantity
          local duration            = criteriaInfo.duration
          local elapsed             = criteriaInfo.elapsed
          local failed              = criteriaInfo.failed
          local isWeightedProgress  = criteriaInfo.isWeightedProgress

          local objectiveData = DELVE_DATA:AcquireObjective()

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
    DELVE_DATA:StopObjectivesCounter()
end

__SystemEvent__ "SCENARIO_UPDATE" "SCENARIO_POI_UPDATE" "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_COMPLETED"
function UPDATE_DELVE()
  _M:UpdateDelve()
end

__SystemEvent__()
function UPDATE_UI_WIDGET(widgetData)
  if widgetData.widgetID == DELVE_WIDGET_ID then 
    _M:UpdateDelve()
  end
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(DELVE_DATA, "Delve Content Subject")