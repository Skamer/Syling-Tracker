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
  SetCharCacheValue                   = API.SetCharCacheValue,
  GetCharCacheValue                   = API.GetCharCacheValue,
  RegisterSetting                     = API.RegisterSetting,
  GetSetting                          = API.GetSetting,
  RegisterObservableContent           = API.RegisterObservableContent,
  ItemBar_AddItem                     = API.ItemBar_AddItem,
  ItemBar_RemoveItem                  = API.ItemBar_RemoveItem,
  ItemBar_Update                      = API.ItemBar_Update,
  ItemBar_SetItemDistance             = API.ItemBar_SetItemDistance,

  --- WoW API & Utils
  AddQuestWatch                       = C_QuestLog.AddQuestWatch,
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
  IsImportantQuest                    = C_QuestLog.IsImportantQuest,
  IsLegendaryQuest                    = C_QuestLog.IsLegendaryQuest,
  IsOnMap                             = C_QuestLog.IsOnMap,
  IsQuestBounty                       = C_QuestLog.IsQuestBounty,
  IsQuestCalling                      = C_QuestLog.IsQuestCalling,
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

local QUESTS_CONTENT_SUBJECT = RegisterObservableContent("quests", QuestsContentSubject)

local QUESTS_CACHE = {}
local QUEST_HEADERS_CACHE = {}
local QUESTS_WITH_PROGRESS = {}
local QUESTS_WITH_ITEMS = {}
local QUESTS_REQUESTED = {}

local QUEST_NEW_MAX_AGE = nil
local QUEST_NEW_REMOVE_ON_PROGRESS = nil

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

  self:RunAgeUpdater()
end

function OnInactive(self)
  self:StopAgeUpdater()

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
    elseif not isHidden and not isBounty and not isTask then
      local receivedTime = self:GetQuestReceivedTime(questID)
      if not receivedTime then
        receivedTime = time() 
        self:SetQuestReceivedTime(questID, receivedTime)
      end

      if IsQuestWatched(questID) then
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
end

function UpdateQuest(self, questID)
  local hasChanged = false
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
  local isImportant =  IsImportantQuest(questID)
  local isCalling = IsQuestCalling(questID)

  if not distance then 
    distance = 99999
  else
    distance = sqrt(distance)
  end

  local totalTime, elapsedTime = GetTimeAllowed(questID)
  local isOnMap, hasLocalPOI = IsOnMap(questID)

  local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)

  if questData.numObjectives ~= numObjectives then 
    hasChanged = true
  elseif questData.isComplete ~= isComplete then 
    hasChanged = true
  elseif questData.isFailed ~= isFailed then 
    hasChanged = true
  end

  questData.questID = questID
  questData.questLogIndex = questLogIndex
  questData.isNew = GetCharCacheValue("newquests", questID)
  questData.age = self:GetQuestAge(questID)
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
  questData.startTime =  elapsedTime and GetTime() - elapsedTime
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
  questData.isImportant = isImportant
  questData.isCalling = isCalling

  -- Is the quest has an item quest ?
  local itemLink, itemTexture

  -- We check if the quest log index is valid before fetching as sometimes for 
  -- unknown reason this can be nil 
  if questLogIndex then 
    itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)
  end

  if itemLink and itemTexture then 
    local itemData = questData.item

    itemData.link = itemLink
    itemData.texture = itemTexture

    -- We don't need to check if the item has been already added, as it's done 
    -- internally, and in this case the call is ignored. 
    ItemBar_AddItem(questID, itemLink, itemTexture, distance)

    QUESTS_WITH_ITEMS[questID] = true
  end

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

      if objectiveData.text ~= text then 
        hasChanged = true
      end

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

  if QUEST_NEW_REMOVE_ON_PROGRESS and hasChanged and questData.isNew and questData.age > 5 then
    questData.isNew = false
     SetCharCacheValue("newquests", questID, false)
  end

  -- if totalTime and elapsedTime then 
  --   local lastObjective = questData:GetObjectiveData(objectiveCount)
  --   lastObjective.hasTimer = true
  --   lastObjective.startTime = GetTime() - elapsedTime
  --   lastObjective.duration = totalTime 
  -- end
end

__SystemEvent__ "QUEST_LOG_UPDATE" "SUPER_TRACKING_CHANGED"
function QUESTS_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end

__SystemEvent__()
function QUEST_POI_UPDATE()
  -- QuestSuperTracking_OnPOIUpdate()

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

  _M:SetQuestReceivedTime(questID, time())

  SetCharCacheValue("newquests", questID, true)

  -- Add it in the quest watched 
  if GetCVarBool("autoQuestWatch") and GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
    AddQuestWatch(questID)
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
      QUESTS_WITH_ITEMS[questID] = nil 
    end

    -- QUESTS_CONTENT_SUBJECT:RemoveQuestData(questID)
    QUESTS_CONTENT_SUBJECT.quests[questID] = nil

    SetCharCacheValue("newquests", questID, nil)
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
    local data = GetInfo(i)
    if data.isHeader then 
      currentHeader = data.title 
    elseif data.questID == qID then 
      QUEST_HEADERS_CACHE[qID] = currentHeader
      return currentHeader
    end
  end

  return currentHeader
end

DISTANCE_UPDATER_TOKEN = 0
DISTANCE_UPDATER_ENABLED = false

__Async__()
__SystemEvent__()
function PLAYER_STARTED_MOVING()
  if DISTANCE_UPDATER_ENABLED then 
    return 
  end

  if IsInInstance() then 
    return 
  end

  DISTANCE_UPDATER_ENABLED = true

  local token = DISTANCE_UPDATER_TOKEN + 1
  DISTANCE_UPDATER_TOKEN = token 

  while DISTANCE_UPDATER_ENABLED and token == DISTANCE_UPDATER_TOKEN do
    _M:UpdateDistance()
    Delay(5)
  end
end

__SystemEvent__()
function PLAYER_STOPPED_MOVING()
  DISTANCE_UPDATER_ENABLED = false

  if IsInInstance() then
    return 
  end


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

local AGE_UPDATER_TOKEN = 0
local AGE_UPDATER_ENABLED = false

__Async__()
__SystemEvent__()
function RunAgeUpdater(self)
  if AGE_UPDATER_ENABLED then 
    return 
  end

  AGE_UPDATER_ENABLED = true 

  local token = AGE_UPDATER_TOKEN + 1
  AGE_UPDATER_TOKEN = token

  while AGE_UPDATER_ENABLED and token == AGE_UPDATER_TOKEN do
    for questID in pairs(QUESTS_CACHE) do 
      local age = self:GetQuestAge(questID)
  
      if age then 
        local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)
        questData.age = age

        if questData.isNew and QUEST_NEW_MAX_AGE > 0 and age > QUEST_NEW_MAX_AGE then
          questData.isNew = false
          SetCharCacheValue("newquests", questID, false)
        end
      end
    end

    Delay(1)
  end
end

function StopAgeUpdater(self)
  AGE_UPDATER_ENABLED = false
end


function GetQuestReceivedTime(self, questID)
  return GetCharCacheValue("questsReceivedTime", questID)
end

function GetQuestReceivedTimePlayed(self, questID)
  return GetCharCacheValue("questsReceivedTimePlayed", questID)
end

function GetQuestAge(self, questID)
  local receivedTimePlayed = self:GetQuestReceivedTimePlayed(questID)
  if not receivedTimePlayed then
    return 9999999
  end

  return Utils.GetTimePlayed() - receivedTimePlayed
end

function SetQuestReceivedTime(self, questID, receivedTime)
  local timePlayed = Utils.GetTimePlayed()

  if timePlayed == 0 then 
    return 
  end

  SetCharCacheValue("questsReceivedTime", questID, receivedTime)

  if receivedTime then
    SetCharCacheValue("questsReceivedTimePlayed", questID, timePlayed)
  else
    SetCharCacheValue("questsReceivedTimePlayed", questID, nil)
  end
end

function OnLoad(self)
  RegisterSetting("questNewMaxAge", 600, function(maxAge) QUEST_NEW_MAX_AGE = maxAge end)
  RegisterSetting("questNewRemoveOnProgress", true, function(removeOnProgress) QUEST_NEW_REMOVE_ON_PROGRESS = removeOnProgress end)
end

function OnEnable(self)
  QUEST_NEW_MAX_AGE = GetSetting("questNewMaxAge")
  QUEST_NEW_REMOVE_ON_PROGRESS = GetSetting("questNewRemoveOnProgress")
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(QUESTS_CONTENT_SUBJECT, "Quests Content Subject")