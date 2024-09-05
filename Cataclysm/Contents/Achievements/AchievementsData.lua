-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Data.AchievementsData"               ""
-- ========================================================================= --
__DataProperties__ {
  { name = "achievementID", type = Number},
  { name = "title", type = String},
  { name = "name", type = String},
  { name = "description", type = String},
  { name = "numObjectives", type = Number},
  { name = "points", type = Number},
  { name = "isFailed", type = Boolean },
  { name = "isCompleted", type = Boolean},
  { name = "month", type = Any },
  { name = "day", type = Any},
  { name = "year", type = Any},
  { name = "flags", type = Any},
  { name = "icon", type = Any},
  { name = "rewardText", type = String},
  { name = "isGuild", type = Boolean},
  { name = "wasEarnedByMe", type = Boolean},
  { name = "earnedBy", type = Any},
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"}
}
class "AchievementData" { ObjectData }

__DataProperties__ {
  { name = "achievements", type = AchievementData, isMap = true, singularName = "achievement"}
}
class "AchievementsContentSubject" { ContentSubject }