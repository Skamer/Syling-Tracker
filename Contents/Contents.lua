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
  viewClass = AutoQuestsContentView,
  data = GetObservableContent("autoQuests"),
  statusFunc = function(data) return (data and data.autoQuests) and true or false end,
})
-------------------------------------------------------------------------------
--                             Widgets                                       --
-------------------------------------------------------------------------------
RegisterContent({
  id = "widgets",
  name = "Widgets",
  description = "WIDGETS_PH_DESC",
  order = 15,
  viewClass = WidgetsContentView,
  statusFunc = function() return false end,
})
-------------------------------------------------------------------------------
--                              Scenario                                     --
-------------------------------------------------------------------------------
RegisterContent({
  id = "scenario",
  name = "Scenario",
  formattedName = CreateAtlasMarkup("ScenariosIcon", 16, 16) .. " Scenario",
  description = "SCENARIO_PH_DESC",
  icon = { atlas = AtlasType("ScenariosIcon") },
  order = 20,
  viewClass = ScenarioContentView,
  data = GetObservableContent("scenario"),
  statusFunc = function(data) return (data and data.scenario) and true or false end
})
-------------------------------------------------------------------------------
--                             Dungeon                                       --
-------------------------------------------------------------------------------
RegisterContent({
  id = "dungeon",
  name = "Dungeon",
  formattedName = CreateAtlasMarkup("Dungeon", 16, 16) .. " Dungeon",
  description = "DUNGEON_PH_DESC",
  icon = { atlas = AtlasType("Dungeon") },
  order = 30,
  viewClass = DungeonContentView,
  data = GetObservableContent("dungeon"),
  statusFunc = function(data) return (data and data.name) and true or false end 
})
-------------------------------------------------------------------------------
--                             Keystone                                      --
-------------------------------------------------------------------------------
RegisterContent({
  id = "keystone",
  name = "Mythic +",
  formattedName = CreateAtlasMarkup("Dungeon", 16, 16) .. " Mythic +",
  description = "KEYSTONE_PH_DESC",
  icon = { atlas = AtlasType("Dungeon") },
  order = 40,
  viewClass = KeystoneContentView,
  data = GetObservableContent("keystone"),
  statusFunc = function() return C_ChallengeMode.GetActiveKeystoneInfo() > 0 end,
})
-------------------------------------------------------------------------------
--                             Torghast                                      --
-------------------------------------------------------------------------------
RegisterContent({
  id = "torghast",
  name = "Torghast",
  formattedName = CreateAtlasMarkup("poi-torghast", 16, 16) .. " Torghast",
  description = "TORGHAST_PH_DESC",
  icon = { atlas = AtlasType("poi-torghast") },
  order = 50,
  viewClass = ContentView,
  statusFunc = function() return false end,
})
-------------------------------------------------------------------------------
--                             World Quests                                  --
-------------------------------------------------------------------------------
RegisterContent({
  id = "worldQuests",
  name = "World Quests",
  formattedName = CreateAtlasMarkup("QuestDaily", 16, 16) .. " World Quests",
  description = "WORLD_QUESTS_PH_DESC",
  icon = { atlas = AtlasType("QuestDaily") },
  order = 60,
  viewClass = TasksContentView,
  data = GetObservableContent("worldQuests"),
  statusFunc = function(data) return (data and data.quests) and true or false end
})
-------------------------------------------------------------------------------
--                             Tasks                                         --
-------------------------------------------------------------------------------
RegisterContent({
  id = "tasks",
  name = "Tasks",
  formattedName = CreateAtlasMarkup("QuestBonusObjective", 16, 16) .. " Tasks",
  description = "TASKS_PH_DESC",
  icon = { atlas = AtlasType("QuestBonusObjective") },
  order = 70,
  viewClass = TasksContentView,
  data = GetObservableContent("tasks"):Map(function(data)
    local normalTasks
    if data and data.quests then 
      for questID, taskData in pairs(data.quests) do 
        if taskData.displayAsObjective then 
          if not normalTasks then 
            normalTasks = {}
          end
          normalTasks[questID] = taskData
        end
      end
    end

    return { quests = normalTasks }
  end),
  statusFunc = function(data) return (data and data.quests) and true or false end
})
-------------------------------------------------------------------------------
--                             Bonus Tasks                                   --
-------------------------------------------------------------------------------
RegisterContent({
  id = "bonusTasks",
  name = "Bonus Tasks",
  formattedName = CreateAtlasMarkup("QuestBonusObjective", 16, 16) .. " Bonus Tasks",
  description = "BONUS_TASKS_PH_DESC",
  icon = { atlas = AtlasType("QuestBonusObjective") },
  order = 80,
  viewClass = TasksContentView,
  data = GetObservableContent("tasks"):Map(function(data)
    local bonusTasks
    if data and data.quests then 
      for questID, taskData in pairs(data.quests) do 
        if not taskData.displayAsObjective then 
          if not bonusTasks then 
            bonusTasks = {}
          end

          bonusTasks[questID] = taskData
        end
      end
    end

    return { quests = bonusTasks }
  end),
  statusFunc = function(data) return (data and data.quests) and true or false end
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
  order = 90,
  viewClass = AchievementsContentView,
  data = GetObservableContent("achievements"),
  statusFunc = function(data) return (data and data.achievements) and true or false end
})
-------------------------------------------------------------------------------
--                             Activities                                    --
-------------------------------------------------------------------------------
RegisterContent({
  id = "activities",
  name = "Activities",
  formattedName = CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-Mouseover", 16, 16) .. " Activities",
  description = "ACTIVITIES_PH_DESC",
  icon = { atlas = AtlasType("UI-HUD-MicroMenu-AdventureGuide-Mouseover") },
  order = 100,
  viewClass = ActivitiesContentView,
  data = GetObservableContent("activities"),
  statusFunc = function(data) return (data and data.activities) and true or false end
})
-------------------------------------------------------------------------------
--                             Profession Recipes                            --
-------------------------------------------------------------------------------
RegisterContent({
  id = "professionRecipes",
  name = "Profession",
  formattedName = CreateAtlasMarkup("Professions-Crafting-Orders-Icon", 16, 16) .. " Profession",
  description = "PROFESSION_RECIPES_PH_DESC",
  icon = { atlas = AtlasType("Professions-Crafting-Orders-Icon") },
  order = 110,
  viewClass = ProfessionRecipesContentView,
  data = GetObservableContent("professionRecipes"),
  statusFunc = function(data) return (data and (data.recipes or data.recraftRecipes)) and true or false end
})
-------------------------------------------------------------------------------
--                             Collections                                   --
-------------------------------------------------------------------------------
RegisterContent({
  id = "collections",
  name = "Collections",
  formattedName = CreateAtlasMarkup("UI-HUD-MicroMenu-Collections-Mouseover", 16, 16) .. " Collections",
  description = "COLLECTIONS_PH_DESC",
  icon = { atlas = AtlasType("UI-HUD-MicroMenu-Collections-Mouseover") },
  order = 120,
  viewClass = CollectionsContentView,
  data = GetObservableContent("collections"),
  statusFunc = function(data) return (data and data.collections) and true or false end
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
  formattedName = CreateAtlasMarkup("quest-campaign-available", 16, 16) .. " Campaign Quests",
  description = "CAMPAIGN_QUESTS_PH_DESC",
  icon =  { atlas = AtlasType("quest-campaign-available") },
  order = 130,
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
  formattedName = CreateAtlasMarkup("QuestNormal", 16, 16) .. " Quests",
  description = "QUESTS_PH_DESC",
  icon = { atlas =  AtlasType("QuestNormal") },
  order = 140,
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
-------------------------------------------------------------------------------
--                             Dungeon Quests                                --
-------------------------------------------------------------------------------
-- RegisterContent({
--   id = "dungeonQuests",
--   name = "OnMap Quests",
--   description = "QUESTS_PH_DESC",
--   icon = { atlas =  AtlasType("QuestNormal") },
--   order = 115,
--   viewClass = QuestsContentView,
--   data = API.GetObservableContent("quests"):Map(function(data)
--     local dungeonQuests = {}
--     if data and data.quests then 
--       for questID, questData in pairs(data.quests) do 
--         if questData.isOnMap or questData.hasLocalPOI then
--           dungeonQuests[questID] = questData
--         end
--       end
--     end

--     return { quests = dungeonQuests}
--   end),
--     statusFunc = function(data)
--     if data and data.quests then
--       for k, v in pairs(data.quests) do
--         return true 
--       end
--     end

--     return false
--   end
-- })