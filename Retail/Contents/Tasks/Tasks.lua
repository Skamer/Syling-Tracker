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
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API
  RegisterObservableContent           = API.RegisterObservableContent,
  ItemBar_AddItem                     = API.ItemBar_AddItem,
  ItemBar_RemoveItem                  = API.ItemBar_RemoveItem,

  IsQuestBonusObjective               = QuestUtils_IsQuestBonusObjective,
  HasTasks                            = Utils.HasTasks,
  IsQuestComplete                     = C_QuestLog.IsComplete,
  IsQuestTask                         = C_QuestLog.IsQuestTask,
  IsWorldQuest                        = QuestUtils_IsQuestWorldQuest,
  GetTaskInfo                         = GetTaskInfo,
  GetQuestObjectiveInfo               = GetQuestObjectiveInfo,
  GetQuestProgressBarPercent          = GetQuestProgressBarPercent,
  RequestLoadQuestByID                = C_QuestLog.RequestLoadQuestByID,
  SetSelectedQuest                    = C_QuestLog.SetSelectedQuest
}

TASKS_CONTENT_SUBJECT = RegisterObservableContent("tasks", TasksContentSubject)
TASKS_CACHE = {}
TASKS_WITH_ITEMS = {}

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "QUEST_REMOVED"
function ActivateOn(self, event, ...)
  if event == "QUEST_ACCEPTED" then 
    local questID = ...
    return IsQuestBonusObjective(questID)
  elseif event == "QUEST_REMOVED" then 
    for questID in pairs(TASKS_CACHE) do 
      return true 
    end

    return false
  end

  return HasTasks()
end

function OnActive(self)
  if self:IsActivateByEvent("PLAYER_ENTERING_WORLD") then 
    self:LoadTasks()
  end
end

function LoadTasks(self)
  local tasks = GetTasksTable()
  for i, questID in pairs(tasks) do 
    local isInArea = GetTaskInfo(questID)
    if not IsWorldQuest(questID) and isInArea then 
      TASKS_CACHE[questID] = true 

      self:UpdateTask(questID)
    end
  end
end

function UpdateTask(self, questID)
  local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID)
  local isComplete = IsQuestComplete(questID)

  local taskData = TASKS_CONTENT_SUBJECT:AcquireQuest(questID)
  taskData.questID = questID
  taskData.name = taskName
  taskData.numObjectives = numObjectives
  taskData.isInArea = isInArea
  taskData.isOnMap = isOnMap
  taskData.isComplete = isComplete
  taskData.displayAsObjective = displayAsObjective


  -- Is the task has an item quest ? 
  local itemLink, itemTexture

  local questLogIndex = GetLogIndexForQuestID(questID)
  -- We check if the quest log index is valid before fetching as sometimes for 
  -- unknown reason this can be nil 
  if questLogIndex then 
    itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)
  end

  if itemLink and itemTexture then 
    local itemData = taskData.item

    itemData.link = itemLink
    itemData.texture = itemTexture

    -- We don't need to check if the item has been already added, as it's done 
    -- internally, and in this case the call is ignored. 
    ItemBar_AddItem(questID, itemLink, itemTexture, 1)

    TASKS_WITH_ITEMS[questID] = true
  end

  taskData:StartObjectivesCounter()
  if not isComplete and numObjectives and numObjectives > 0 then 
    for index = 1, numObjectives do
      local objectiveData = taskData:AcquireObjective()
      local text, oType, finished = GetQuestObjectiveInfo(questID, index, false)

      objectiveData.text = text 
      objectiveData.type = oType
      objectiveData.isCompleted = finished

      if oType == "progressbar" then 
        local progress = GetQuestProgressBarPercent(questID)
        objectiveData.hasProgress = true 
        objectiveData.progress = progress 
        objectiveData.minProgress = 0
        objectiveData.maxProgress = 100
        objectiveData.progressText = PERCENTAGE_STRING:format(progress)
      else
        objectiveData.hasProgress = nil 
        objectiveData.progress = nil 
        objectiveData.minProgress = nil
        objectiveData.maxProgress = nil
        objectiveData.progressText = nil
      end
    end
  else 
    SetSelectedQuest(questID)
    local text = GetQuestLogCompletionText() 
    
    local objectiveData = taskData:AcquireObjective()
    objectiveData.text = text 
    objectiveData.isComplete = false
  end
  taskData:StopObjectivesCounter()
end

__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success and TASKS_CACHE[questID] then 
    _M:UpdateTask(questID)
  end
end

__SystemEvent__()
function QUEST_ACCEPTED(questID)

  -- World Quests are considered as tasks so we need to filter them out
  if not IsQuestTask(questID) or IsWorldQuest(questID) then 
    return 
  end

  TASKS_CACHE[questID] = true 

  -- Send a request for getting the task informations, the update will be 
  -- continued by QUEST_DATA_LOAD_RESULT event 
  RequestLoadQuestByID(questID)

  _M:UpdateTask(questID)
end

__SystemEvent__()
function QUEST_REMOVED(questID)

  if not TASKS_CACHE[questID] then 
    return 
  end

  if TASKS_WITH_ITEMS[questID] then 
    ItemBar_RemoveItem(questID)
    TASKS_WITH_ITEMS[questID] = nil 
  end

  TASKS_CACHE[questID] = nil 
  TASKS_CONTENT_SUBJECT.quests[questID] = nil
end

__SystemEvent__()
function QUEST_LOG_UPDATE()
  for questID in pairs(TASKS_CACHE) do 
    _M:UpdateTask(questID)
  end
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(TASKS_CONTENT_SUBJECT, "Tasks Content Subject")