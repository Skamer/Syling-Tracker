-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.WorldQuests"                      ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API 
  RegisterObservableContent           = API.RegisterObservableContent,

  HasWorldQuests                      = Utils.HasWorldQuests,

  RequestLoadQuestByID                =  C_QuestLog.RequestLoadQuestByID,
  IsWorldQuest                        = QuestUtils_IsQuestWorldQuest,
  GetTaskInfo                         = GetTaskInfo,
  GetTasksTable                       = GetTasksTable
}

WORLD_QUESTS_CONTENT_SUBJECT = RegisterObservableContent("worldQuests", QuestsContentSubject)

WORLD_QUESTS_CACHE                  = {}

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "QUEST_REMOVED"
function BecomeActiveOn(self)
  return HasWorldQuests()
end

function OnActive(self)
  self:LoadWorldQuests()
end

function LoadWorldQuests()
  local tasks = GetTasksTable()
  for _, questID in ipairs(tasks) do 
    local isInArea = GetTaskInfo(questID) 
    if IsWorldQuest(questID) and isInArea then
      -- Add the world quest into cache
      WORLD_QUESTS_CACHE[questID] = true

      -- Send a request for getting the world quest information, the update will be 
      -- continued by the QUEST_DATA_LOAD_RESULT event 
      RequestLoadQuestByID(questID)
    end
  end
end

function UpdateWorldQuest(self, questID)
  local isInArea, isOnMap, numObjectives, questName, displayAsObjective = GetTaskInfo(questID)

  local worldQuestData = WORLD_QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)
  worldQuestData.questID = questID
  worldQuestData.title = questName
  worldQuestData.name = questName
  worldQuestData.numObjectives = numObjectives

  worldQuestData:StartObjectivesCounter()
  if numObjectives and numObjectives > 0 then
    for index = 1, numObjectives do 
      local objectiveData = worldQuestData:AcquireObjective()
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
  end
  worldQuestData:StopObjectivesCounter()
end

__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success and WORLD_QUESTS_CACHE[questID] then
    _M:UpdateWorldQuest(questID)
  end   
end

__SystemEvent__()
function QUEST_REMOVED(questID)
  if not IsWorldQuest(questID) then 
    return 
  end

  WORLD_QUESTS_CACHE[questID] = nil 

  WORLD_QUESTS_CONTENT_SUBJECT.quests[questID] = nil
end


__SystemEvent__()
function QUEST_ACCEPTED(questID)
  if not IsWorldQuest(questID) then 
    return 
  end

  WORLD_QUESTS_CACHE[questID] = true 

  -- Send a request for getting the world quest information, the update will be 
  -- continued by the QUEST_DATA_LOAD_RESULT event 
  RequestLoadQuestByID(questID)
end

__SystemEvent__()
function QUEST_LOG_UPDATE()
  for questID in pairs(WORLD_QUESTS_CACHE) do 
    _M:UpdateWorldQuest(questID)
  end
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(WORLD_QUESTS_CONTENT_SUBJECT, "World Quests Content Subject")