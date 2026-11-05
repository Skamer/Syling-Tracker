-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.Contents"                           ""
-- ========================================================================= --
export {
  RegisterContent             = API.RegisterContent,
  RegisterObservableContent   = API.RegisterObservableContent,
  GetObservableContent        = API.GetObservableContent,
  CombineObservableContent    = API.CombineObservableContent,
  CreateAtlasMarkup           = CreateAtlasMarkup,
}
-------------------------------------------------------------------------------
--                             Quests                                        --
-------------------------------------------------------------------------------
RegisterContent({
  id = "quests",
  name = _Locale.QUESTS,
  formattedName = CreateAtlasMarkup("QuestNormal", 16, 16) .. " " .. _Locale.QUESTS,
  description = "QUESTS_PH_DESC",
  icon = { atlas =  AtlasType("QuestNormal") },
  order = 150,
  viewClass = QuestsContentView,
  data = GetObservableContent("quests")
})