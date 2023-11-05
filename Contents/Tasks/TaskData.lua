-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Data.TaskData"                      ""
-- ========================================================================= --
__DataProperties__ {
  { name = "questID", type = Number },
  { name = "name", type = String},
  { name = "numObjectives", type = Number },
  { name = "isInArea", type = Boolean},
  { name = "isOnMap", type = Boolean},
  { name = "isComplete", type = Boolean},
  { name = "displayAsObjective", type = Boolean },
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"}
}
class "TaskData" { ObjectData }