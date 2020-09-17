-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                     "SylingTracker.Tasks"                            ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
RegisterContentType = API.RegisterContentType
RegisterModel = API.RegisterModel
-- ========================================================================= --
IsWorldQuest                        = QuestUtils_IsQuestWorldQuest
IsQuestTask                         = IsQuestTask
GetTaskInfo                         = GetTaskInfo
GetTasksTable                       = GetTasksTable
GetQuestLogIndexByID                = GetQuestLogIndexByID
SelectQuestLogEntry                 = SelectQuestLogEntry 
GetQuestLogCompletionText           = GetQuestLogCompletionText
-- ========================================================================= --
_BonusTasksModel = RegisterModel(QuestModel, "bonus-tasks-data")
_TasksModel      = RegisterModel(QuestModel, "tasks-data")
-- ========================================================================= --
_TASKS_CACHE = {}
_BONUS_TASKS_CACHE = {}



RegisterContentType({
  ID = "bonus-tasks",
  DisplayName = "Bonus Tasks",
  Description = "Display the bonus tasks, also known as bonus objectives",
  DefaultModel = _BonusTasksModel,
  DefaultViewClass = BonusTasksContentView,
  Events = { "PLAYER_ENTERING_WORLD", "QUEST_ACCEPTED", "QUEST_REMOVED"},
  Status = function() return _M:HasBonusTasks() end
})

RegisterContentType({
  ID = "tasks",
  DisplayName = "Tasks",
  Description = "Display the tasks, also known as objectives",
  DefaultOrder = 20,
  DefaultModel = _TasksModel,
  DefaultViewClass = TasksContentView,
  Events = { "PLAYER_ENTERING_WORLD", "SLT_QUEST_TASK_ADDED", "QUEST_REMOVED"},
  Status = function(...) print("HasTasks", _M:HasTasks(), ...) ;return _M:HasTasks() end
})

function OnEnable(self)
  self:LoadTasks()
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID)
  print("QUEST_ACCEPTED", questID)

  if not IsQuestTask(questID) or IsWorldQuest(questID) then 
    return 
  end

  _M:UpdateTask(questID)

  if _BONUS_TASKS_CACHE[questID] then 
    _BonusTasksModel:Flush()
  else 
    _TasksModel:Flush()
    -- NOTE: We triggered an event, allowing to content type to check correctly
    -- the status.
   _M:FireSystemEvent("SLT_QUEST_TASK_ADDED", questID)
  end
end

__SystemEvent__()
function QUEST_REMOVED(questID)
  if not IsQuestTask(questID) or IsWorldQuest(questID) then 
    return 
  end
  
  if _BONUS_TASKS_CACHE[questID] then 
    _BonusTasksModel:RemoveQuestData(questID)
    _BonusTasksModel:Flush()
    _BONUS_TASKS_CACHE[questID] = nil
  else 
    _TasksModel:RemoveQuestData(questID)
    _TasksModel:Flush()
    _TASKS_CACHE[questID] = nil
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

  print("UpdateTasks", taskName, displayAsObjective)

  local questData = {
    questID = questID,
    title = taskName,
    name = taskName,
    numObjectives = numObjectives,
    isInArea = isInArea,
    isOnMap = isOnMap
  }

  if numObjectives > 0 then 
    local objectivesData = {}
    for index = 1, numObjectives do 
      local text, type, finished =  GetQuestObjectiveInfo(questID, index, false)
      local data = {
        text = text, 
        type = type,
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
  else 
    SelectQuestLogEntry(GetQuestLogIndexByID(questID))
    local text = GetQuestLogCompletionText()
    questData.objectives = {
      [1] = { text = text, isCompleted = false }
    }
  end 

  if displayAsObjective then 
    _TASKS_CACHE[questID] = true
    _TasksModel:AddQuestData(questID, questData)
  else
    _BONUS_TASKS_CACHE[questID] = true
    _BonusTasksModel:AddQuestData(questID, questData)
  end
end


function HasTasks(self)
  for k,v in pairs(_TASKS_CACHE) do 
    return true 
  end
  
  return false
end

function HasBonusTasks(self)
  for k,v in pairs(_BONUS_TASKS_CACHE) do 
    return true 
  end 
  
  return false 
end

-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_BonusTasksModel, "BonusTaskModel")
  ViragDevTool_AddData(_TasksModel, "TaskModel")
end