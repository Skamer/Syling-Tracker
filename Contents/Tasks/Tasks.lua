-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Tasks"                             ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
RegisterContentType                 = API.RegisterContentType
RegisterModel                       = API.RegisterModel
ItemBar_AddItemData                 = API.ItemBar_AddItemData
ItemBar_RemoveItemData              = API.ItemBar_RemoveItemData
ItemBar_Update                      = API.ItemBar_Update
-- ========================================================================= --
IsWorldQuest                        = QuestUtils_IsQuestWorldQuest
IsQuestTask                         = IsQuestTask
IsQuestComplete                     = IsQuestComplete
GetTaskInfo                         = GetTaskInfo
GetTasksTable                       = GetTasksTable
GetQuestLogIndexByID                = GetQuestLogIndexByID
SelectQuestLogEntry                 = SelectQuestLogEntry 
GetQuestLogCompletionText           = GetQuestLogCompletionText
-- ========================================================================= --
_BonusTasksModel                    = RegisterModel(QuestModel, "bonus-tasks-data")
_TasksModel                         = RegisterModel(QuestModel, "tasks-data")
NIL_DATA                            = Model.NIL_DATA
-- ========================================================================= --
RegisterContentType({
  ID = "bonus-tasks",
  DisplayName = "Bonus Tasks",
  Description = "Display the bonus tasks, also known as bonus objectives",
  DefaultModel = _BonusTasksModel,
  DefaultViewClass = BonusTasksContentView,
  Events = { "PLAYER_ENTERING_WORLD", "SLT_BONUS_TASK_QUEST_ADDED", "SLT_BONUS_TASK_QUEST_REMOVED"},
  Status = function() return _M:HasBonusTasks() end
})

RegisterContentType({
  ID = "tasks",
  DisplayName = "Tasks",
  Description = "Display the tasks, also known as objectives",
  DefaultOrder = 20,
  DefaultModel = _TasksModel,
  DefaultViewClass = TasksContentView,
  Events = { "PLAYER_ENTERING_WORLD", "SLT_TASK_QUEST_ADDED", "SLT_TASK_QUEST_REMOVED"},
  Status = function(...) print(..., "Return", _M:HasTasks()) return _M:HasTasks() end
})
-- ========================================================================= --
TASKS_CACHE                         = {}
BONUS_TASKS_CACHE                   = {}
TASKS_WITH_ITEMS                    = {}
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "QUEST_REMOVED"
function ActivateOn(self, event)
  return self:HasAnyTasks()
end
-- ========================================================================= --
function OnActive(self)
  self:LoadTasks()
end

function OnInactive(self)
  -- Clear the data inside the models
  _BonusTasksModel:ClearData()
  _TasksModel:ClearData()

  -- Clear the cache
  wipe(TASKS_CACHE)
  wipe(BONUS_TASKS_CACHE)

  -- Remove the items from Item Bar if they are exists.
  for questID in pairs(TASKS_WITH_ITEMS) do 
    ItemBar_RemoveItemData(questID)
  end
  ItemBar_Update()

  wipe(TASKS_WITH_ITEMS)
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID)

  if not IsQuestTask(questID) or IsWorldQuest(questID) then 
    return 
  end

  _M:UpdateTask(questID)

  if BONUS_TASKS_CACHE[questID] then
    _BonusTasksModel:Flush()
    -- NOTE: We triggered an event, allowing to content type to check correctly
    -- the status.
    _M:FireSystemEvent("SLT_BONUS_TASK_QUEST_ADDED", questID)
  else 
    _TasksModel:Flush()
    -- NOTE: We triggered an event, allowing to content type to check correctly
    -- the status.
   _M:FireSystemEvent("SLT_TASK_QUEST_ADDED", questID)
  end
end

__SystemEvent__()
function QUEST_REMOVED(questID)
  print("QUEST_REMOVED", questID)
  -- NOTE: This seems that IsQuestTask returns false even for the task when it has 
  -- been completed.
  -- In this case, this is better to make checks with the cache.
  if not TASKS_CACHE[questID] and not BONUS_TASKS_CACHE[questID] then 
    return
  end 


  if BONUS_TASKS_CACHE[questID] then 
    _BonusTasksModel:RemoveQuestData(questID)
    _BonusTasksModel:Flush()
    BONUS_TASKS_CACHE[questID] = nil

    -- NOTE: We triggered an event, allowing to content type to check correctly
    -- the status.
    _M:FireSystemEvent("SLT_BONUS_TASK_QUEST_REMOVED", questID)
  else 
    _TasksModel:RemoveQuestData(questID)
    _TasksModel:Flush()
    TASKS_CACHE[questID] = nil

    -- NOTE: We triggered an event, allowing to content type to check correctly
    -- the status.
    _M:FireSystemEvent("SLT_TASK_QUEST_REMOVED", questID)
  end

  -- If the tasks had an item, remove it 
  if TASKS_WITH_ITEMS[questID] then 
    ItemBar_RemoveItemData(questID)
    ItemBar_Update()

    TASKS_WITH_ITEMS[questID] = nil 
  end
end

__SystemEvent__()
function QUEST_LOG_UPDATE()
  for questID in pairs(BONUS_TASKS_CACHE) do 
    _M:UpdateTask(questID)
    _BonusTasksModel:Flush()
  end
  
  for questID in pairs(TASKS_CACHE) do 
    _M:UpdateTask(questID)
    _TasksModel:Flush()
  end
end

function LoadTasks(self)
  local tasks = GetTasksTable()
  for i, questID in pairs(tasks) do 
    if not IsWorldQuest(questID) then 
      self:UpdateTask(questID)
    end
  end

  _TasksModel:Flush()
  _BonusTasksModel:Flush()
end

function UpdateTask(self, questID)
  local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID)
  local isComplete = IsQuestComplete(questID)
  local questData = {
    questID = questID,
    title = taskName,
    name = taskName,
    numObjectives = numObjectives,
    isInArea = isInArea,
    isOnMap = isOnMap, 
    isComplete = isComplete
  }

  -- Is the quest has an item quest ?
  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(GetQuestLogIndexByID(questID))

  if itemLink and itemTexture then
    questData.item = {
      link    = itemLink,
      texture = itemTexture
    }
    
    -- We check if the world quest has already the item for avoiding useless data 
    -- update.
    if not TASKS_WITH_ITEMS[questID] then 
      ItemBar_AddItemData(questID, {
        link = itemLink, 
        texture = itemTexture
      })
      ItemBar_Update()

      TASKS_WITH_ITEMS[questID] = true 
    end
  end 

  if not isComplete and numObjectives > 0 then 
    local objectivesData = {}
    for index = 1, numObjectives do 
      local text, type, finished =  GetQuestObjectiveInfo(questID, index, false)
      local data = {
        text = text,
        type = type,
        isCompleted = finished
      }

      if type == "progressbar" then
        if not finished then 
          local progress = GetQuestProgressBarPercent(questID)
          data.hasProgressBar = true
          data.progress = progress
          data.minProgress = 0
          data.maxProgress = 100
          data.progressText = PERCENTAGE_STRING:format(progress)
        else
          -- We hide the progress bar if the objective is finished
          -- IMPORTANT: Use "NIL_DATA" instead of nil, otherwise the data won't
          -- be deleted.
          data.hasProgressBar = NIL_DATA 
          data.progress = NIL_DATA 
          data.minProgress = NIL_DATA 
          data.maxProgress = NIL_DATA
          data.progressText = NIL_DATA
        end 
      end

      objectivesData[index] = data 
    end
    
    questData.objectives = objectivesData
  else 
    SelectQuestLogEntry(GetQuestLogIndexByID(questID))
    local text = GetQuestLogCompletionText()

    local objectivesData = {}
    -- IMPORTANT: Use "NIL_DATA" instead of nil, otherwise the data won't
    -- be deleted.
    for index = 1, numObjectives do 
      if index == 1 then 
        objectivesData[1] = { 
          text              = text, 
          isCompleted       = false, 
          hasProgressBar    = NIL_DATA,
          progress          = NIL_DATA,
          minProgress       = NIL_DATA,
          maxProgress       = NIL_DATA,
          progressText      = NIL_DATA
        }
      else 
        objectivesData[index] = NIL_DATA 
      end
    end
    -- We set the num objectives to "1" for staying consistant, and avoiding to
    -- mislead the views.
    questData.numObjectives = 1
    questData.objectives = objectivesData
  end 

  if displayAsObjective then 
    TASKS_CACHE[questID] = true
    _TasksModel:AddQuestData(questID, questData)
  else
    BONUS_TASKS_CACHE[questID] = true
    _BonusTasksModel:AddQuestData(questID, questData)
  end
end



function HasAnyTasks(self)
  local tasks = GetTasksTable()
  for i, questID in pairs(tasks) do
    local isInArea = GetTaskInfo(questID)
    if not IsWorldQuest(questID) and isInArea then 
      return true 
    end
  end

  return false
end

function HasTasks(self)
  for k,v in pairs(TASKS_CACHE) do 
    return true 
  end
  
  return false
end

function HasBonusTasks(self)
  for k,v in pairs(BONUS_TASKS_CACHE) do 
    return true 
  end
  
  return false 
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_BonusTasksModel, "SLT Bonus Task Model")
  ViragDevTool_AddData(_TasksModel, "SLT Task Model")
end
