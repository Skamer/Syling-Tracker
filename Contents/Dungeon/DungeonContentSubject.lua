-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling            "SylingTracker.Contents.DungeonContentSubject"             ""
-- ========================================================================= --
__DataProperties__ {
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"},
  { name = "name", type = String },
  { name = "numObjectives", type = Number },
  { name = "textureFileID", type = Number}
}
class "DungeonContentSubject" { ContentSubject }