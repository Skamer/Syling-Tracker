-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Data.ActivitiesData"                    ""
-- ========================================================================= --
__DataProperties__ {
  { name = "activityID", type = Number},
  { name = "name", type = String},
  { name = "description", type = String},
  { name = "isCompleted", type = Boolean},
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"}
}
class "ActivityData" { ObjectData }

__DataProperties__{
  { name = "activities", type = ActivityData, isMap = true, singularName = "activity"}
}
class "ActivitiesContentSubject" { ContentSubject }