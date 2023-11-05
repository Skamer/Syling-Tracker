-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Data.QuestData"                      ""
-- ========================================================================= --
__DataProperties__{
  { name = "link", type = Any },
  { name = "texture", type = Any}
}
class "QuestItemData" { ObjectData }

__DataProperties__ {
  { name = "questLogIndex", type = Number },
  { name = "questID", type = Number },
  { name = "isFailed", type = Boolean, default = false },
  { name = "title", type = String },
  { name = "name", type = String },
  { name = "level", type = Number },
  { name = "header", type = String },
  { name = "category", type = String },
  { name = "campaignID", type = Number },
  { name = "numObjectives", type = Number },
  { name = "isComplete", type = Boolean },
  { name = "isTask", type = Boolean },
  { name = "isBounty", type = Boolean },
  { name = "requiredMoney", type = Number },
  { name = "hasTimer", type = Boolean },
  { name = "totalTime", type = Number },
  { name = "elapsedTime", type = Number },
  { name = "startTime", type = Number},
  { name = "isOnMap", type = Boolean },
  { name = "hasLocalPOI", type = Boolean },
  { name = "questType", type = Any },
  { name = "tag", type = Any },
  { name = "isStory", type = Boolean },
  { name = "startEvent", type = Any },
  { name = "isAutoComplete", type = Boolean },
  { name = "suggestedGroup", type = Any },
  { name = "isDungeon", type = Boolean },
  { name = "distance", type = Number },
  { name = "isRaid", type = Boolean },
  { name = "isLegendary", type = Boolean },
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"},
  { name = "item", type = QuestItemData }
}
class "QuestData" { ObjectData }