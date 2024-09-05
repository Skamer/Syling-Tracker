-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Data.ObjectiveData"                  ""
-- ========================================================================= --
__DataProperties__ {
  { name = "text", type = String },
  { name = "type", type = String },
  { name = "isCompleted", type = Boolean },
  { name = "isFailed", type = Boolean },
  { name = "hasProgress", type = Boolean },
  { name = "progress", type = Number },
  { name = "minProgress", type = Number },
  { name = "maxProgress", type = Number },
  { name = "progressText", type = String },
  { name = "hasTimer", type = Boolean },
  { name = "startTime", type = Number },
  { name = "duration", type = Number }
}
__Recyclable__() class "ObjectiveData"  { ObjectData }