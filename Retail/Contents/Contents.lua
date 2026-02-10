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

  HasObjectiveWidgets         = Utils.HasObjectiveWidgets,
  IsInHorrificVisions         = Utils.IsInHorrificVisions
}

-------------------------------------------------------------------------------
--                             AutoQuests                                 --
-------------------------------------------------------------------------------
RegisterContent({
  id = "autoQuests",
  name = _Locale.AUTO_QUESTS_POPUP,
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
  name = _Locale.WIDGETS,
  description = "WIDGETS_PH_DESC",
  order = 15,
  viewClass = WidgetsContentView,
  events = { "UPDATE_ALL_UI_WIDGETS", "UPDATE_UI_WIDGET", "ZONE_CHANGED_NEW_AREA"},
  statusFunc = function() return HasObjectiveWidgets() end,
})
-------------------------------------------------------------------------------
--                              Scenario                                     --
-------------------------------------------------------------------------------
RegisterContent({
  id = "scenario",
  name = _Locale.SCENARIO,
  formattedName = CreateAtlasMarkup("ScenariosIcon", 16, 16) .. " " .. _Locale.SCENARIO,
  description = "SCENARIO_PH_DESC",
  icon = { atlas = AtlasType("ScenariosIcon") },
  order = 20,
  viewClass = ScenarioContentView,
  data = GetObservableContent("scenario"),
  statusFunc = function(data)
    if IsInHorrificVisions() then 
      return false 
    end

    return (data and data.scenario) and true or false 
  end
})
-------------------------------------------------------------------------------
--                              Delve                                        --
-------------------------------------------------------------------------------
RegisterContent({
  id = "delve",
  name = _Locale.DELVE,
  formattedName = CreateAtlasMarkup("delves-regular", 16, 16) .. " " .. _Locale.DELVE,
  description = "DELVE_PH_DESC",
  icon = { atlas = AtlasType("delves-regular") },
  order = 25,
  viewClass = DelveContentView,
  data = GetObservableContent("delve"),
  statusFunc = function(data) return (data and data.name) and true or false end
})
-------------------------------------------------------------------------------
--                              Horrific Visions                             --
-------------------------------------------------------------------------------
RegisterContent({
  id = "horrificVisions",
  name = _Locale.HORRIFIC_VISIONS,
  formattedName = CreateAtlasMarkup("worldquest-icon-nzoth", 16, 16) .. " " .. _Locale.HORRIFIC_VISIONS,
  description = "HORRIFIC_VISIONS_PH_DESC",
  icon = { atlas = AtlasType("worldquest-icon-nzoth") },
  order = 25,
  viewClass = HorrificVisionsContentView,
  data = CombineObservableContent("scenario", "horrificVisions"),
  statusFunc = function(data) return IsInHorrificVisions() end
})
-------------------------------------------------------------------------------
--                             Dungeon                                       --
-------------------------------------------------------------------------------
RegisterContent({
  id = "dungeon",
  name = _Locale.DUNGEON,
  formattedName = CreateAtlasMarkup("Dungeon", 16, 16) .. " " .. _Locale.DUNGEON,
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
  name = _Locale.KEYSTONE,
  formattedName = CreateAtlasMarkup("Dungeon", 16, 16) .. " " .. _Locale.KEYSTONE,
  description = "KEYSTONE_PH_DESC",
  icon = { atlas = AtlasType("Dungeon") },
  order = 40,
  viewClass = KeystoneContentView,
  data = GetObservableContent("keystone"),
  statusFunc = function() return C_ChallengeMode.GetActiveKeystoneInfo() > 0 end,
})
-- -------------------------------------------------------------------------------
-- --                             Torghast                                      --
-- -------------------------------------------------------------------------------
-- RegisterContent({
--   id = "torghast",
--   name = "Torghast",
--   formattedName = CreateAtlasMarkup("poi-torghast", 16, 16) .. " Torghast",
--   description = "TORGHAST_PH_DESC",
--   icon = { atlas = AtlasType("poi-torghast") },
--   order = 50,
--   viewClass = ContentView,
--   statusFunc = function() return false end,
-- })
-- -------------------------------------------------------------------------------
--                             World Quests                                  --
-------------------------------------------------------------------------------
RegisterContent({
  id = "worldQuests",
  name = _Locale.WORLD_QUESTS,
  formattedName = CreateAtlasMarkup("QuestDaily", 16, 16) .. " " .. _Locale.WORLD_QUESTS,
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
  name = _Locale.TASKS,
  formattedName = CreateAtlasMarkup("QuestBonusObjective", 16, 16) .. " " .. _Locale.TASKS,
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
  name = _Locale.BONUS_TASKS,
  formattedName = CreateAtlasMarkup("QuestBonusObjective", 16, 16) .. " " .. _Locale.BONUS_TASKS,
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
  name = _Locale.ACHIEVEMENTS,
  formattedName = CreateAtlasMarkup("UI-HUD-MicroMenu-Achievements-Mouseover", 16, 16) .. " " ..  _Locale.ACHIEVEMENTS,
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
  name = _Locale.ACTIVITIES,
  formattedName = CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-Mouseover", 16, 16) .. " " .. _Locale.ACTIVITIES,
  description = "ACTIVITIES_PH_DESC",
  icon = { atlas = AtlasType("UI-HUD-MicroMenu-AdventureGuide-Mouseover") },
  order = 100,
  viewClass = ActivitiesContentView,
  data = GetObservableContent("activities"),
  statusFunc = function(data) return (data and data.activities) and true or false end
})
-------------------------------------------------------------------------------
--                             Endeavors                                     --
-------------------------------------------------------------------------------
RegisterContent({
  id = "endeavors",
  name = _Locale.ENDEAVORS,
  formattedName = CreateAtlasMarkup("housing-map-deed", 16, 16) .. " " .. _Locale.ENDEAVORS,
  description = "ENDEAVORS_PH_DESC",
  icon = { atlas = AtlasType("housing-map-deed") },
  order = 110,
  viewClass = EndeavorsContentView,
  data = GetObservableContent("endeavors"),
  statusFunc = function(data) return (data and data.endeavors) and true or false end
})
-------------------------------------------------------------------------------
--                             Profession Recipes                            --
-------------------------------------------------------------------------------
RegisterContent({
  id = "professionRecipes",
  name = _Locale.PROFESSION,
  formattedName = CreateAtlasMarkup("Professions-Crafting-Orders-Icon", 16, 16) .. " " .. _Locale.PROFESSION,
  description = "PROFESSION_RECIPES_PH_DESC",
  icon = { atlas = AtlasType("Professions-Crafting-Orders-Icon") },
  order = 120,
  viewClass = ProfessionRecipesContentView,
  data = GetObservableContent("professionRecipes"),
  statusFunc = function(data) return (data and (data.recipes or data.recraftRecipes)) and true or false end
})
-------------------------------------------------------------------------------
--                             Collections                                   --
-------------------------------------------------------------------------------
RegisterContent({
  id = "collections",
  name = _Locale.COLLECTIONS,
  formattedName = CreateAtlasMarkup("UI-HUD-MicroMenu-Collections-Mouseover", 16, 16) .. " " .. _Locale.COLLECTIONS,
  description = "COLLECTIONS_PH_DESC",
  icon = { atlas = AtlasType("UI-HUD-MicroMenu-Collections-Mouseover") },
  order = 130,
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
  name = _Locale.CAMPAIGN_QUESTS,
  formattedName = CreateAtlasMarkup("quest-campaign-available", 16, 16) .. " " .. _Locale.CAMPAIGN_QUESTS,
  description = "CAMPAIGN_QUESTS_PH_DESC",
  icon =  { atlas = AtlasType("quest-campaign-available") },
  order = 140,
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
  name = _Locale.QUESTS,
  formattedName = CreateAtlasMarkup("QuestNormal", 16, 16) .. " " .. _Locale.QUESTS,
  description = "QUESTS_PH_DESC",
  icon = { atlas =  AtlasType("QuestNormal") },
  order = 150,
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
-------------------------------------------------------------------------------
--                             Pets                                          --
-------------------------------------------------------------------------------
if C_AddOns.IsAddOnLoaded("PetTracker") then
  RegisterContent({
    id = "pets",
    name = "Pets",
    formattedName = CreateAtlasMarkup("WildBattlePetCapturable", 16, 16) .. " " .. "Pets",
    description = "PETS_PH_DESC",
    icon = { atlas = AtlasType("WildBattlePetCapturable") },
    order = 160,
    viewClass = PetsContentView,
    data = GetObservableContent("pets"),
    statusFunc = function(data) return (data and data.totalInZone) and true or false end
  })
end