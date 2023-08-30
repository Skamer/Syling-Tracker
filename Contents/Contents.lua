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

--- TODO: Add Widgets (e.g, Fishing tracking for knowing the fish amount)

-------------------------------------------------------------------------------
--                             AutoQuests                                 --
-------------------------------------------------------------------------------
RegisterContent({
  id = "autoQuests",
  name = "Auto Quests PopUp",
  description = "AUTO_QUESTS_PH_DESC",
  order = 10,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                              Scenario                                     --
-------------------------------------------------------------------------------
RegisterContent({
  id = "scenario",
  name = "Scenario",
  description = "SCENARIO_PH_DESC",
  icon = { atlas = AtlasType("ScenariosIcon") },
  order = 20,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Dungeon                                       --
-------------------------------------------------------------------------------
RegisterContent({
  id = "dungeon",
  name = "Dungeon",
  description = "DUNGEON_PH_DESC",
  icon = { atlas = AtlasType("Dungeon") },
  order = 30,
  viewClass = DungeonContentView,
  data = API.GetObservableContent("dungeon"),
})
-------------------------------------------------------------------------------
--                             Keystone                                      --
-------------------------------------------------------------------------------
RegisterContent({
  id = "keystone",
  name = "Mythic +",
  description = "KEYSTONE_PH_DESC",
  icon = { atlas = AtlasType("Dungeon") },
  order = 40,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Torghast                                      --
-------------------------------------------------------------------------------
RegisterContent({
  id = "torghast",
  name = "Torghast",
  description = "TORGHAST_PH_DESC",
  icon = { atlas = AtlasType("poi-torghast") },
  order = 50,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             World Quests                                  --
-------------------------------------------------------------------------------
RegisterContent({
  id = "worldQuests",
  name = "World Quests",
  description = "WORLD_QUESTS_PH_DESC",
  icon = { atlas = AtlasType("QuestDaily") },
  order = 60,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Tasks                                         --
-------------------------------------------------------------------------------
RegisterContent({
  id = "tasks",
  name = "Tasks",
  description = "TASKS_PH_DESC",
  icon = { atlas = AtlasType("QuestBonusObjective") },
  order = 70,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Bonus Tasks                                   --
-------------------------------------------------------------------------------
RegisterContent({
  id = "bonusTasks",
  name = "Bonus Tasks",
  description = "BONUS_TASKS_PH_DESC",
  icon = { atlas = AtlasType("QuestBonusObjective") },
  order = 80,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Achievements                                  --
-------------------------------------------------------------------------------
RegisterContent({
  id = "achievements",
  name = "Achievements",
  description = "ACHIEVEMENTS_PH_DESC",
  icon = { atlas = AtlasType("UI-HUD-MicroMenu-Achievements-Mouseover")},
  order = 90,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Activities                                    --
-------------------------------------------------------------------------------
RegisterContent({
  id = "activities",
  name = "Activities",
  description = "ACTIVITIES_PH_DESC",
  icon = { atlas = AtlasType("UI-HUD-MicroMenu-AdventureGuide-Mouseover") },
  order = 100,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Profession Recipes                            --
-------------------------------------------------------------------------------
RegisterContent({
  id = "professionRecipes",
  name = "Profession",
  description = "PROFESSION_RECIPES_PH_DESC",
  icon = { atlas = AtlasType("Professions-Crafting-Orders-Icon") },
  order = 110,
  viewClass = ContentView,
})
-------------------------------------------------------------------------------
--                             Campaign Quests                               --
-------------------------------------------------------------------------------
local campaignQuestsData = GetObservableContent("quests"):Map(function(data)
    local campaignQuests = {}
    if data and data.quests then
      for questID, questData in pairs(data.quests) do 
        if questData.campaignID and questData.campaignID ~= 0 then
          campaignQuests[questID] = questData
        end
      end
    end

    return { quests = campaignQuests }
end)

RegisterObservableContent("campaignQuests", campaignQuestsData)


RegisterContent({
  id = "campaignQuests",
  name = "Campaign Quests",
  description = "CAMPAIGN_QUESTS_PH_DESC",
  icon =  { atlas = AtlasType("quest-campaign-available") },
  order = 120,
  viewClass = QuestsContentView,
  data = campaignQuestsData,
  statusFunc = function(data)
    if data and data.quests then 
      for k, v in pairs(data.quests) do
        return true 
      end
    end

    return false
  end
})
-------------------------------------------------------------------------------
--                             Quests                                        --
-------------------------------------------------------------------------------
RegisterContent({
  id = "quests",
  name = "Quests",
  description = "QUESTS_PH_DESC",
  icon = { atlas =  AtlasType("QuestNormal") },
  order = 130,
  viewClass = QuestsContentView,
  data = API.GetObservableContent("quests"),
})
-------------------------------------------------------------------------------
--                             Dungeon Quests                                --
-------------------------------------------------------------------------------
RegisterContent({
  id = "dungeonQuests",
  name = "OnMap Quests",
  description = "QUESTS_PH_DESC",
  icon = { atlas =  AtlasType("QuestNormal") },
  order = 115,
  viewClass = QuestsContentView,
  data = API.GetObservableContent("quests"):Map(function(data)
    local dungeonQuests = {}
    if data and data.quests then 
      for questID, questData in pairs(data.quests) do 
        if questData.isOnMap or questData.hasLocalPOI then
          dungeonQuests[questID] = questData
        end
      end
    end

    return { quests = dungeonQuests}
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