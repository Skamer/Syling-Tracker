-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Datastores.Quests"                ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API
  RegisterObservableContent           = API.RegisterObservableContent,
  ItemBar_AddItem                     = API.ItemBar_AddItem,
  ItemBar_RemoveItem                  = API.ItemBar_RemoveItem,
  ItemBar_Update                      = API.ItemBar_Update,
  ItemBar_SetItemDistance             = API.ItemBar_SetItemDistance,

  --- WoW API & Utils
  AddQuestWatch                       = C_QuestLog.AddQuestWatch,
  EnumQuestWatchType                  = _G.Enum.QuestWatchType,
  GetCampaignID                       = C_CampaignInfo.GetCampaignID,
  GetDistanceSqToQuest                = C_QuestLog.GetDistanceSqToQuest,
  GetInfo                             = C_QuestLog.GetInfo,
  GetLogIndexForQuestID               = C_QuestLog.GetLogIndexForQuestID,
  GetNextWaypointText                 = C_QuestLog.GetNextWaypointText,
  GetNumQuestLogEntries               = C_QuestLog.GetNumQuestLogEntries,
  GetNumQuestObjectives               = C_QuestLog.GetNumQuestObjectives,
  GetNumQuestWatches                  = C_QuestLog.GetNumQuestWatches,
  GetQuestDifficultyLevel             = C_QuestLog.GetQuestDifficultyLevel,
  GetQuestLogCompletionText           = GetQuestLogCompletionText,
  GetQuestLogSpecialItemInfo          = GetQuestLogSpecialItemInfo,
  GetQuestName                        = QuestUtils_GetQuestName,
  GetQuestObjectiveInfo               = GetQuestObjectiveInfo,
  GetQuestProgressBarPercent          = GetQuestProgressBarPercent,
  GetQuestTagInfo                     = C_QuestLog.GetQuestTagInfo,
  GetRequiredMoney                    = C_QuestLog.GetRequiredMoney,
  GetSuggestedGroupSize               = C_QuestLog.GetSuggestedGroupSize,
  GetTimeAllowed                      = C_QuestLog.GetTimeAllowed,
  IsDungeonQuest                      = Utils.IsDungeonQuest,
  IsFailed                            = C_QuestLog.IsFailed,
  IsLegendaryQuest                    = C_QuestLog.IsLegendaryQuest,
  IsOnMap                             = C_QuestLog.IsOnMap,
  IsQuestBounty                       = C_QuestLog.IsQuestBounty,
  IsQuestComplete                     = C_QuestLog.IsComplete,
  IsQuestTask                         = C_QuestLog.IsQuestTask,
  IsQuestTrivial                      = C_QuestLog.IsQuestTrivial,
  IsQuestWatched                      = QuestUtils_IsQuestWatched,
  IsRaidQuest                         = Utils.IsRaidQuest,
  IsWorldQuest                        = QuestUtils_IsQuestWorldQuest,
  RequestLoadQuestByID                = C_QuestLog.RequestLoadQuestByID,
  SelectQuestLogEntry                 = SelectQuestLogEntry,
  SelectQuestLogEntry                 = SelectQuestLogEntry,
  SetSelectedQuest                    = C_QuestLog.SetSelectedQuest
}

QUESTS_CONTENT_SUBJECT = RegisterObservableContent("quests", QuestsContentSubject)

QUESTS_CACHE = {}
QUEST_HEADERS_CACHE = {}
QUESTS_WITH_PROGRESS = {}
QUESTS_WITH_ITEMS = {}
QUESTS_REQUESTED = {}


__ActiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED" "QUEST_ACCEPTED"
function BecomeActiveOn(self, event, ...)
  if event == "QUEST_ACCEPTED" then 
    -- Calling QUEST_ACCEPTED will watch the quest if matching the requirements,
    -- so going to trigger the checking on "QUEST_WATCH_LIST_CHANGED".
    -- As QUEST_ACCEPTED returns nil, the system skip the event. 
    return QUEST_ACCEPTED(...)
  end

  return GetNumQuestWatches() > 0
end

__InactiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED"
function BecomeInactiveOn(self, event, ...)
  return GetNumQuestWatches() == 0
end

__Async__()
function OnActive(self)
  if self:IsActivateByEvent("PLAYER_ENTERING_WORLD") then 
    local initialLogin = self:GetActivatingEventArgs()
    if initialLogin then 
      -- If it's the first login, we need to wait "QUEST_LOG_UPDATE" is fired
      -- to get valid informations about quests
      Wait("QUEST_LOG_UPDATE")
    end
  end

  _M:LoadQuests()
end

-- function GetQuestData(self, questID)
--   local questData = QUESTS_DATA[questID]
--   if not questData then 
--     questData = {}
--     QUESTS_DATA[questID] = questData
--   end

--   return questData
-- end

function OnInactive(self)
  wipe(QUESTS_CACHE)
  wipe(QUESTS_WITH_PROGRESS)

  for questId in pairs(QUESTS_WITH_ITEMS) do 
    ItemBar_RemoveItem(questId)
  end

  ItemBar_Update()

  wipe(QUESTS_WITH_ITEMS)
end

function LoadQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  local currentHeader         = "Misc"

  for i = 1, numEntries do 
    local questInfo = GetInfo(i)

    local questID   = questInfo.questID
    local isHeader  = questInfo.isHeader
    local isHidden  = questInfo.isHidden
    local isBounty  = questInfo.isBounty
    local isTask    = questInfo.isTask

    if questInfo.isHeader then 
      currentHeader = questInfo.title
    elseif IsQuestWatched(questID) and not isHidden and not isBounty and not isTask then 
      QUESTS_CACHE[questID]         = true 
      QUEST_HEADERS_CACHE[questID]  = currentHeader

      local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)
      questData.questID = questID
      questData.questLogIndex = questInfo.questLogIndex
      questData.title = questInfo.title
      questData.name = questInfo.title
      questData.header = header
      questData.category = header
      questData.campaignID = questInfo.campaignID
      questData.level = questInfo.level
      questData.difficultyLevel = questInfo.difficultyLevel
      questData.suggestedGroup = questInfo.suggestedGroup
      questData.frequency = questInfo.frequency
      questData.isHeader = questInfo.isHeader
      questData.isCollapsed = questInfo.isCollapsed
      questData.startEvent = questInfo.startEvent
      questData.isTask = questInfo.isTask
      questData.isBounty = questInfo.isBounty
      questData.isScaling = questInfo.isScaling
      questData.isOnMap = questInfo.isOnMap
      questData.hasLocalPOI = questInfo.hasLocalPOI
      questData.isHidden = questInfo.isHidden
      questData.isAutoComplete = questInfo.isAutoComplete
      questData.overridesSortOrder = questInfo.overridesSortOrder
      questData.readyForTranslation = questInfo.readyForTranslation

      QUESTS_REQUESTED[questID] = true 
      RequestLoadQuestByID(questID)
    end
  end
end

function UpdateQuest(self, questID)
  local isFailed = IsFailed(questID)
  local title = GetQuestName(questID)
  local level = GetQuestDifficultyLevel(questID)
  local header = self:GetQuestHeader(questID)
  local questLogIndex = GetLogIndexForQuestID(questID)
  local numObjectives = GetNumQuestObjectives(questID)
  local isComplete = IsQuestComplete(questID)
  local isTask = IsQuestTask(questID)
  local isBounty = IsQuestBounty(questID)
  local distance = GetDistanceSqToQuest(questID)
  local isDungeon = IsDungeonQuest(questID)
  local isRaid = IsRaidQuest(questID)
  local requiredMoney = GetRequiredMoney(questID)
  local suggestedGroup = GetSuggestedGroupSize(questID)
  local isLegendary = IsLegendaryQuest(questID)
  local tag = GetQuestTagInfo(questID)
  local campaignID = GetCampaignID(questID)

  if not distance then 
    distance = 99999
  else
    distance = sqrt(distance)
  end

  local totalTime, elapsedTime = GetTimeAllowed(questID)
  local isOnMap, hasLocalPOI = IsOnMap(questID)

  local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)

  questData.questID = questID
  questData.questLogIndex = questLogIndex
  questData.isFailed = isFailed
  questData.title = title
  questData.name = title
  questData.level = level
  questData.header = header
  questData.category = header
  questData.campaignID = campaignID
  questData.numObjectives = numObjectives
  questData.isComplete = isComplete
  questData.isTask = isTask
  questData.isBounty = isBounty
  questData.requiredMoney = requiredMoney
  questData.totalTime = totalTime
  questData.elapsedTime = elapsedTime
  questData.startTime =  GetTime() - elapsedTime
  questData.hasTimer = (totalTime and elapsedTime) and true
  questData.isOnMap = isOnMap
  questData.hasLocalPOI = hasLocalPOI
  -- questData.questType= tag
  questData.tag = tag
  questData.isStory = isStory
  questData.startEvent = startEvent
  questData.isAutoComplete = isAutoComplete
  questData.suggestedGroup = suggestedGroup
  questData.distance = distance
  questData.isDungeon = isDungeon
  questData.isRaid = isRaid
  questData.isLegendary = isLegendary

  -- Is the quest has an item quest ?
  local itemLink, itemTexture

  -- We check if the quest log index is valid before fetching as sometimes for 
  -- unknown reason this can be nil 
  if questLogIndex then 
    itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)
  end

  -- if itemLink and itemTexture then
  --   -- QUESTS_DATASTORE:Path("item"):SaveValue("link", itemLink)
  --   -- QUESTS_DATASTORE:Path("item"):SaveValue("texture", itemTexture)
  --   questData.itemLink = itemLink
  --   questData.itemTexture = itemTexture

  --   -- We check if the quest has already the item for avoiding useless data update 
  --   if not QUESTS_WITH_ITEMS[questID] then 
  --     ItemBar_AddItem(questID, {
  --       link = itemLink,
  --       texture = itemTexture,
  --       distance = distance
  --     })

  --     ItemBar_Update()

  --     QUESTS_WITH_ITEMS[questID] = true 
  --   end
  -- else 
  --   if QUESTS_WITH_ITEMS[questID] then 
  --     ItemBar_RemoveItem(questID)
  --     QUESTS_WITH_ITEMS[questID] = nil

  --     -- QUESTS_DATASTORE:SetValue("item", nil)
  --     questData.itemLink = nil 
  --     questData.itemTexture = nil
  --   end
  -- end

  -- if itemLink and itemTexture then
  --   if not ItemBar_HasItem(questID) then 
  --     ItemBar_AddItem(questID, {
  --       link = itemLink,
  --       texture = itemTexture,
  --       distance = distance
  --     })
  --   else
  --     ItemBar_SetItemLink(questID, itemLink)
  --     ItemBar_SetItemTexture(questID, itemTexture)
  --   end
  -- else 
  --   if ItemBar_HasItem(questID) then 
  --     ItemBar_RemoveItem(questID)
  --   end
  -- end

  -- Updating the objectives 
  local objectiveCount = 0

  if isComplete then 
    if not isAutoComplete then
      for index = 1, numObjectives do 
        local objectiveData = questData:AcquireObjective(objectiveCount + 1)
        local text, oType, finished = GetQuestObjectiveInfo(questID, index, true)
        
        objectiveData.text = text
        objectiveData.type = oType
        objectiveData.isCompleted =  finished
        
        objectiveCount = objectiveCount + 1

        if oType == "progressbar" then 
          objectiveData.hasProgress = nil 
          objectiveData.progress = nil 
          objectiveData.minProgress = nil
          objectiveData.maxProgress = nil
          objectiveData.progressText = nil
          
          -- We don't display the progress bar if it's completed, we remove it from tracking 
          QUESTS_WITH_PROGRESS[questID] = nil
        end
      end
    end

    -- In case where the quest is auto completed, this says the user needs to click 
    -- for finishing the quest. We need to notify the player 
    if isAutoComplete then 
      local objectiveCompleteData = questData:AcquireObjective(objectiveCount + 1)
      objectiveCompleteData.isCompleted = true 
      objectiveCompleteData.text = QUEST_WATCH_QUEST_COMPLETE

      local objectiveClickData = questData:AcquireObjective(objectiveCount + 2)
      objectiveClickData.isCompleted = false 
      objectiveClickData.text = QUEST_WATCH_CLICK_TO_COMPLETE 

      -- We don't forget to add 2 objectives in the objective counter
      objectiveCount = objectiveCount + 2
    else
      local completionText = GetQuestLogCompletionText(questLogIndex)
      if completionText then 
        -- The waypoint text is here for helping the player to navigate for completing the quests 
        if shouldShowWaypoint then 
          local waypointText = GetNextWaypointText(questID)
          if waypointText then
            local objectiveData = questData:AcquireObjective(objectiveCount + 1)
            objectiveData.isCompleted = false 
            objectiveData.text = WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText)
            objectiveCount = objectiveCount + 1
          end
        end

        local objectiveCompletionData = questData:AcquireObjective(objectiveCount + 1)
        objectiveCompletionData.isCompleted = false 
        objectiveCompletionData.text = completionText
        objectiveCount = objectiveCount + 1
      else
        local waypointText = GetNextWaypointText(questID)
        local objectiveWaypointData = questData:AcquireObjective(objectiveCount + 1)
        objectiveWaypointData.isCompleted = false
        objectiveCount = objectiveCount + 1

        if waypointText then
          objectiveWaypointData.text = waypointText
        else
          objectiveWaypointData.text =  QUEST_WATCH_QUEST_READY
        end 
      end
    end
  elseif isFailed then 
    local objectiveData = questData:AcquireObjective(objectiveCount + 1)
    objectiveData.text = FAILED
    objectiveData.isCompleted = false 
    objectiveData.isFailed = true
    objectiveCount = objectiveCount + 1

    -- We don't display the progress bar if it's failed, we remove it from tracking.
    QUESTS_WITH_PROGRESS[questID] = nil
  else 
    if shouldShowWaypoint then 
      -- The waypoint text is here for helping the player to navigate for progress on the quest, it's still optional.
      local waypointText = GetNextWaypointText(questID)
      if waypointText then
        local objectiveData = questData:AcquireObjective(objectiveCount + 1)
        objectiveCount = objectiveCount + 1
        objectiveData.isCompleted = false 
        objectiveData.text = WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText)
      end
    end

    for index = 1, numObjectives do 
      local objectiveData = questData:AcquireObjective(objectiveCount + 1)
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
        QUESTS_WITH_PROGRESS[questID] = true 
      else
        objectiveData.hasProgress = nil 
        objectiveData.progress = nil 
        objectiveData.minProgress = nil
        objectiveData.maxProgress = nil
        objectiveData.progressText = nil
        QUESTS_WITH_PROGRESS[questID]  = nil
      end

      objectiveCount = objectiveCount + 1
    end

    --- Display the money objective if the player hasn't enought for the quest.
    local playerMoney = GetMoney()
    if requiredMoney > playerMoney then 
      local text = GetMoneyString(playerMoney) .. " / " .. GetMoneyString(requiredMoney)
      local objectiveMoneyData = questData:AcquireObjective(objectiveCount + 1)
      objectiveMoneyData.text = text 
      objectiveMoneyData.isCompleted = false 

      objectiveCount = objectiveCount + 1
    end
  end

  questData:SetObjectivesCount(objectiveCount)

  -- if totalTime and elapsedTime then 
  --   local lastObjective = questData:GetObjectiveData(objectiveCount)
  --   lastObjective.hasTimer = true
  --   lastObjective.startTime = GetTime() - elapsedTime
  --   lastObjective.duration = totalTime 
  -- end
end

__SystemEvent__ "QUEST_LOG_UPDATE"
function QUESTS_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end

__SystemEvent__()
function QUEST_POI_UPDATE()
  QuestSuperTracking_OnPOIUpdate()

  _M:UpdateDistance()
end


__SystemEvent__ "ZONE_CHANGED" "ZONE_CHANGED_NEW_AREA" "AREA_POIS_UPDATED"
function QUESTS_ON_MAP_UPDATE()
  QUESTS_UPDATE()

  _M:UpdateDistance()
end

__SystemEvent__()
function QUEST_ACCEPTED(questID)
  -- Don't continue if the quest is a world quest or a emissary 
  if IsWorldQuest(questID) or IsQuestTask(questID) or IsQuestBounty(questID) then 
    return 
  end 


  -- Add it in the quest watched 
  if GetCVarBool("autoQuestWatch") and GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
    local wasWatched = AddQuestWatch(questID, EnumQuestWatchType.Automatic)
    if wasWatched then 
      QuestSuperTracking_OnQuestTracked(questID)
    end 
  end 
end

__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then 
    return 
  end

  -- Manually tracking the world quest triggers this event so we need to check
  -- this isn't a world quest 
  if IsWorldQuest(questID) then 
    return 
  end 

  if isAdded then 
    QUESTS_CACHE[questID] = true 
    QUESTS_REQUESTED[questID] = true 

    RequestLoadQuestByID(questID)
  else 
    QUESTS_CACHE[questID] = nil 
    QUESTS_REQUESTED[questID] = nil 

    if QUESTS_WITH_ITEMS[questID] then 
      ItemBar_RemoveItem(questID)
      ItemBar_Update()
      QUESTS_WITH_ITEMS[questID] = nil 
    end

    -- QUESTS_CONTENT_SUBJECT:RemoveQuestData(questID)
    QUESTS_CONTENT_SUBJECT.quests[questID] = nil
  end
end


__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success and QUESTS_REQUESTED[questID] then 
    QUESTS_REQUESTED[questID] = nil 

    _M:UpdateQuest(questID)
  end
end

function GetQuestHeader(self, qID)
  -- Check if the quest header is in the cache 
  if QUEST_HEADERS_CACHE[qID] then 
    return QUEST_HEADERS_CACHE[qID]
  end

  -- If no, find the quest header 
  local currentHeader = "Misc"
  local numEntries, numQuests = GetNumQuestLogEntries()

  for i = 1, numEntries do 
    local data = GetInfo(1)
    if data.isHeader then 
      currentHeader = data.title 
    elseif data.questID == qID then 
      QUEST_HEADERS_CACHE[qID] = currentHeader
      return currentHeader
    end
  end

  return currentHeader
end

__Async__()
__SystemEvent__()
function PLAYER_STARTED_MOVING()
  DISTANCE_UPDATER_ENABLED = true
  while DISTANCE_UPDATER_ENABLED do 
    _M:UpdateDistance()

    Delay(1)
  end
end

__SystemEvent__()
function PLAYER_STOPPED_MOVING()
  DISTANCE_UPDATER_ENABLED = false 

  _M:UpdateDistance()
end

IN_TAXI = false 
__Async__()
__SystemEvent__()
function VEHICLE_ANGLE_SHOW()
  if IN_TAXI then 
    return 
  end

  IN_TAXI = true 

  PLAYER_STARTED_MOVING()

  NextEvent("VEHICLE_ANGLE_SHOW")

  PLAYER_STOPPED_MOVING()

  Delay(0.2)

  IN_TAXI = false 
end

function UpdateDistance()
  for questID in pairs(QUESTS_CACHE) do 
    local distanceSq = GetDistanceSqToQuest(questID)

    if distanceSq then 
      local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)
      questData.distance = math.sqrt(distanceSq)
    end
  end
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(QUESTS_CONTENT_SUBJECT, "Quests Content Subject")