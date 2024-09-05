-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Data.ScenarioData"                   ""
-- ========================================================================= --
__DataProperties__{
  { name = "scenarioID", type = Number },
  { name = "name", type = String},
  { name = "currentStage", type = Number},
  { name = "numStages", type = Number},
  { name = "flags", type = Number},
  { name = "isCompleted", type = Boolean},
  { name = "xp", type = Number},
  { name = "money", type = Number},
  { name = "type", type = Number},
  { name = "area", type = String},
  { name = "uiTextureKit", type = Any},
  { name = "stepID", type = Number},
  { name = "stepName", type = String},
  { name = "stepDescription", type = String},
  { name = "numCriteria", type = Number},
  { name = "isStepFailed", type = Boolean},
  { name = "isBonusStep", type = Boolean},
  { name = "isForCurrentStepOnly", type = Boolean},
  { name = "shouldShowBonusObjective", type = Boolean},
  { name = "spells", type = Any},
  { name = "weightedProgress", type = Number},
  { name = "rewardQuestID", type = Number},
  { name = "widgetSetID", type = Number},
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"},
  { name = "bonusObjectives", type = ObjectiveData, isArray = true, singularName = "bonusObjective"}
}
class "ScenarioData" { ObjectData }

__DataProperties__ {
  { name = "scenario", type = ScenarioData }
}
class "ScenarioContentSubject" { ContentSubject }