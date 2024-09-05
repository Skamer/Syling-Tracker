-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Data.CollectionsData"                ""
-- ========================================================================= --
__DataProperties__ {
  { name = "collectableID", type = Number},
  { name = "collectableType", type = Number},
  { name = "name", type = String},
  { name = "uiMapID", type = Number },
  { name = "targetType", type = Number},
  { name = "targetID", type = Number},
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"}
}
class "CollectableData" { ObjectData }


__DataProperties__ {
  { name = "collections", type = CollectableData, isMap = true, singularName = "collectable"}
}
class "CollectionsContentSubject" { ContentSubject }
