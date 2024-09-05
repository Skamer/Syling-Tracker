-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.AutoQuestsData"                         ""
-- ========================================================================= --
__DataProperties__ {
  { name = "questID", type = Number },
  { name = "name", type = String},
  { name = "type", type = String },
}
class "AutoQuestData" { ObjectData }

__DataProperties__ {
  { name = "autoQuests", type = AutoQuestData, isMap = true, singularName = "autoQuest" }
}
class "AutoQuestsContentSubject" { ContentSubject }