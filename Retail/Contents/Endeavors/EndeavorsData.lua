-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Data.EndeavorsData"                     ""
-- ========================================================================= --
__DataProperties__ {
  { name = "endeavorID", type = Number},
  { name = "name", type = String},
  { name = "description", type = String},
  { name = "isCompleted", type = Boolean},
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"}
}
class "EndeavorData" { ObjectData }

__DataProperties__{
  { name = "endeavors", type = EndeavorData, isMap = true, singularName = "endeavor"}
}
class "EndeavorsContentSubject" { ContentSubject }