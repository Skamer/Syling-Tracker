-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.WorldQuest"                          ""
-- ========================================================================= --
import                          "SLT"
-- ========================================================================= --
RegisterContentType = API.RegisterContentType
RegisterModel = API.RegisterModel
-- ========================================================================= --
_WorldQuestsModel = RegisterModel(QuestModel, "world-quests-data")
-- ========================================================================= --
IsWorldQuest                        = QuestUtils_IsQuestWorldQuest
-- ========================================================================= --

RegisterContentType({
  ID = "world-quests",
  DisplayName = "World Quests",
  Description = "Display the world quests",
  DefaultOrder = 5,
  DefaultModel = _WorldQuestsModel,
  DefaultViewClass = WorldQuestsContentView,
  Events = { "PLAYER_ENTERING_WORLD", "SLT_WORLD_QUEST_ACCEPTED", "SLT_WORLD_QUEST_REMOVED"},
  Status = function(event, ...) return _M:HasWorldQuest() end
})

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  _M:LoadWorldQuests()
end


__SystemEvent__()
function QUEST_REMOVED(questID)
  if not IsWorldQuest(questID) then 
    return 
  end

  _WorldQuestsModel:RemoveQuestData(questID)
  _WorldQuestsModel:Flush()

  _M:FireSystemEvent("SLT_WORLD_QUEST_REMOVED", questID)
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID)
  if not IsWorldQuest(questID) then 
    return 
  end

  _M:UpdateWorldQuest(questID)

  _WorldQuestsModel:Flush()

  _M:FireSystemEvent("SLT_WORLD_QUEST_ACCEPTED", questID)
end

function HasWorldQuest(self)
  local tasks = GetTasksTable()
  for _, questID in ipairs(tasks) do 
    local isInArea = GetTaskInfo(questID)
    if IsWorldQuest(questID) and isInArea then 
      return true 
    end 
  end
  
  return false
end

function LoadWorldQuests(self)
  local tasks = GetTasksTable()
  for _, questID in ipairs(tasks) do 
    local isInArea = GetTaskInfo(questID) 
    if IsWorldQuest(questID) and isInArea then 
      self:UpdateWorldQuest(questID)
    end
  end
  
  _WorldQuestsModel:Flush()
end


function UpdateWorldQuest(self, questID)
  local isInArea, isOnMap, numObjectives, questName, displayAsObjective = GetTaskInfo(questID)

  local questData = {
    questID         = questID,
    title           = questName,
    name            = questName,
    numObjectives   = numObjectives,
    isInArea        = isInArea,
    isOnMap         = isOnMap
  }

  -- Is the quest has an item quest ?
  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(GetQuestLogIndexByID(questID))

  if itemLink and itemTexture then
    questData.item = {
      link    = itemLink,
      texture = itemTexture
    }
  end

  if numObjectives > 0 then 
    local objectivesData = {}
    for index = 1, numObjectives do 
      local text, type, finished =  GetQuestObjectiveInfo(questID, index, false)
      local data = {
        text        = text,
        type        = type, 
        isCompleted = finished
      }

      if type == "progressbar" then
        local progress = GetQuestProgressBarPercent(questID)
        data.hasProgressBar = true
        data.progress = progress
        data.minProgress = 0
        data.maxProgress = 100
        data.progressText = PERCENTAGE_STRING:format(progress)
      end
      
      objectivesData[index] = data 
    end
    questData.objectives = objectivesData
  end

  _WorldQuestsModel:AddQuestData(questID, questData)
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_WorldQuestsModel, "WorldQuestsModel")
end