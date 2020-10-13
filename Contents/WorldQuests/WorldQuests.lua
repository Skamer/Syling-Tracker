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
import                              "SLT"
-- ========================================================================= --
_Active                             = false 
-- ========================================================================= --
RegisterContentType                 = API.RegisterContentType
RegisterModel                       = API.RegisterModel
ItemBar_AddItemData                 = API.ItemBar_AddItemData
ItemBar_RemoveItemData              = API.ItemBar_RemoveItemData
ItemBar_Update                      = API.ItemBar_Update
-- ========================================================================= --
RequestLoadQuestByID                =  C_QuestLog.RequestLoadQuestByID
IsWorldQuest                        = QuestUtils_IsQuestWorldQuest
GetTaskInfo                         = GetTaskInfo
GetTasksTable                       = GetTasksTable
GetLogIndexForQuestID               = C_QuestLog.GetLogIndexForQuestID
GetQuestLogSpecialItemInfo          = GetQuestLogSpecialItemInfo
GetQuestObjectiveInfo               = GetQuestObjectiveInfo
GetQuestProgressBarPercent          = GetQuestProgressBarPercent
-- ========================================================================= --
_WorldQuestsModel                   = RegisterModel(QuestModel, "world-quests-data")
-- ========================================================================= --
RegisterContentType({
  ID = "world-quests",
  DisplayName = "World Quests",
  Description = "Display the world quests",
  DefaultOrder = 5,
  DefaultModel = _WorldQuestsModel,
  DefaultViewClass = WorldQuestsContentView,
  Events = { "PLAYER_ENTERING_WORLD", "SLT_WORLD_QUEST_ACCEPTED", "SLT_WORLD_QUEST_REMOVED"},
  Status = function(event, ...) return _M:HasWorldQuests() end
})
-- ========================================================================= --
-- Keep a memory the list of world quests id 
WORLD_QUESTS_CACHE                  = {}
WORLD_QUESTS_WITH_ITEMS             = {}
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "QUEST_REMOVED"
function ActivateOn(self)
  return self:HasWorldQuests()
end
-- ========================================================================= --
function OnActive(self)
  _M:LoadWorldQuests()
end

function OnInactive(self)
  wipe(WORLD_QUESTS_CACHE)

  for questID in pairs(WORLD_QUESTS_WITH_ITEMS) do 
    ItemBar_RemoveItemData(questID)
  end
  ItemBar_Update()

  wipe(WORLD_QUESTS_WITH_ITEMS)
end 

__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success and WORLD_QUESTS_CACHE[questID] then
    _M:UpdateWorldQuest(questID)
    _WorldQuestsModel:Flush()
  end 
end

__SystemEvent__()
function QUEST_REMOVED(questID)
  if not IsWorldQuest(questID) then 
    return 
  end

  -- Remove the world quest from cache
  WORLD_QUESTS_CACHE[questID] = nil

  -- If the world quest had an item, remove it 
  if WORLD_QUESTS_WITH_ITEMS[questID] then 
    ItemBar_RemoveItemData(questID)
    ItemBar_Update()

    WORLD_QUESTS_WITH_ITEMS[questID] = nil 
  end

  -- Remove the data from model, and send an update
  _WorldQuestsModel:RemoveQuestData(questID)
  _WorldQuestsModel:Flush()

  _M:FireSystemEvent("SLT_WORLD_QUEST_REMOVED", questID)
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID)
  if not IsWorldQuest(questID) then 
    return 
  end

  -- Add the world quest into cache
  WORLD_QUESTS_CACHE[questID] = true

  -- Send a request for get the world quest information, the update will be 
  -- continued by the QUEST_DATA_LOAD_RESULT event 
  RequestLoadQuestByID(questID)

  -- Trigger a custom event
  _M:FireSystemEvent("SLT_WORLD_QUEST_ACCEPTED", questID)
end


__SystemEvent__()
function QUEST_LOG_UPDATE()
  for questID in pairs(WORLD_QUESTS_CACHE) do
    _M:UpdateWorldQuest(questID)
  end

  _WorldQuestsModel:Flush()
end

function LoadWorldQuests(self)
  local tasks = GetTasksTable()
  for _, questID in ipairs(tasks) do 
    local isInArea = GetTaskInfo(questID) 
    if IsWorldQuest(questID) and isInArea then
      -- Add the world quest into cache
      WORLD_QUESTS_CACHE[questID] = true

      -- Send a request for get the world quest information, the update will be 
      -- continued by the QUEST_DATA_LOAD_RESULT event 
      RequestLoadQuestByID(questID)
    end
  end
  
  _WorldQuestsModel:Flush()
end

function UpdateWorldQuests()
  for questID in pairs(WORLD_QUESTS_CACHE) do 
    _M:UpdateQuest(questID)
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
  local itemLink, itemTexture, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(GetLogIndexForQuestID(questID))
  if itemLink and itemTexture then
    questData.item = {
      link    = itemLink,
      texture = itemTexture
    }

    -- We check if the world quest has already the item for avoiding useless data 
    -- update.
    if not WORLD_QUESTS_WITH_ITEMS[questID] then 
      ItemBar_AddItemData(questID, {
        link = itemLink, 
        texture = itemTexture
      })
      ItemBar_Update()

      WORLD_QUESTS_WITH_ITEMS[questID] = true 
    end
  else 
    WORLD_QUESTS_WITH_ITEMS[questID] = nil
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


function HasWorldQuests(self)
  local tasks = GetTasksTable()
  for _, questID in ipairs(tasks) do 
    local isInArea = GetTaskInfo(questID)
    if IsWorldQuest(questID) and isInArea then 
      return true 
    end 
  end
  
  return false
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_WorldQuestsModel, "SLT World Quest Model")
end
