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
  CreateAtlasMarkup           = CreateAtlasMarkup,
}
-------------------------------------------------------------------------------
--                             AutoQuests                                 --
-------------------------------------------------------------------------------
RegisterContent({
  id = "autoQuests",
  name = "Auto Quests PopUp",
  description = "AUTO_QUESTS_PH_DESC",
  order = 10,
  viewClass = AutoQuestsContentView,
  data = GetObservableContent("autoQuests"),
  statusFunc = function(data) return (data and data.autoQuests) and true or false end,
})
-------------------------------------------------------------------------------
--                             Achievements                                  --
-------------------------------------------------------------------------------
RegisterContent({
  id = "achievements",
  name = "Achievements",
  formattedName = CreateAtlasMarkup("UI-HUD-MicroMenu-Achievements-Mouseover", 16, 16) .. " Achievements",
  description = "ACHIEVEMENTS_PH_DESC",
  icon = { atlas = AtlasType("UI-HUD-MicroMenu-Achievements-Mouseover")},
  order = 10,
  viewClass = AchievementsContentView,
  data = GetObservableContent("achievements"),
  statusFunc = function(data) return (data and data.achievements) and true or false end
})
-------------------------------------------------------------------------------
--                             Quests                                        --
-------------------------------------------------------------------------------
RegisterContent({
  id = "quests",
  name = "Quests",
  formattedName = CreateAtlasMarkup("QuestNormal", 16, 16) .. " Quests",
  description = "QUESTS_PH_DESC",
  icon = { atlas =  AtlasType("QuestNormal") },
  order = 20,
  viewClass = QuestsContentView,
  data = GetObservableContent("quests"):Map(function(data)
    local quests = {}
    if data and data.quests then
      for questID, questData in pairs(data.quests) do 
        if not questData.campaignID or questData.campaignID == 0 then
          quests[questID] = questData
        end
      end
    end

    return { quests = quests }
  end),
  statusFunc = function(data)
    if data and data.quests then 
      for k, v in pairs(data.quests) do 
        return true 
      end
    end

    return false   
  end
})