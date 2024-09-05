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