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

  HasTasks                            = Utils.HasTasks,
  IsQuestComplete                     = C_QuestLog.IsComplete,
  IsQuestTask                         = C_QuestLog.IsQuestTask,
  IsWorldQuest                        = QuestUtils_IsQuestWorldQuest,
  GetTaskInfo                         = GetTaskInfo,
  GetQuestObjectiveInfo               = GetQuestObjectiveInfo,
  RequestLoadQuestByID                = C_QuestLog.RequestLoadQuestByID,
}

TASKS_CONTENT_SUBJECT = RegisterObservableContent("tasks", TasksContentSubject)
TASKS_CACHE = {}

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "QUEST_REMOVED"
function ActivateOn(self, event)
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


  taskData:StartObjectivesCounter()
  if not isComplete and numObjectives > 0 then 
    for index = 1, numObjectives do
      local objectiveData = taskData:AcquireObjective()
      local text, oType, finished = GetQuestObjectiveInfo(questID, index, false)

      objectiveData.text = text 
      objectiveData.type = oType
      objectiveData.isCompleted = finished
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