-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Quests"                           ""
-- ========================================================================= --
import                              "SLT"
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
-- Check if the player is on the Shadowlands environment
IsOnShadowlands                     = Utils.IsOnShadowlands
RegisterContentType                 = API.RegisterContentType
RegisterModel                       = API.RegisterModel
ItemBar_AddItemData                 = API.ItemBar_AddItemData
ItemBar_RemoveItemData              = API.ItemBar_RemoveItemData
ItemBar_Update                      = API.ItemBar_Update
-- ========================================================================= --
RequestLoadQuestByID                = C_QuestLog.RequestLoadQuestByID
GetQuestName                        = QuestUtils_GetQuestName
IsWorldQuest                        = QuestUtils_IsQuestWorldQuest
IsRaidQuest                         = Utils.Quest.IsRaidQuest
IsDungeonQuest                      = Utils.Quest.IsDungeonQuest
SelectQuestLogEntry                 = SelectQuestLogEntry
GetNumQuestObjectives               = C_QuestLog.GetNumQuestObjectives
IsQuestBounty                       = C_QuestLog.IsQuestBounty
IsQuestTask                         = C_QuestLog.IsQuestTask
IsQuestTrivial                      = C_QuestLog.IsQuestTrivial
GetQuestDifficultyLevel             = C_QuestLog.GetQuestDifficultyLevel
IsQuestWatched                      = QuestUtils_IsQuestWatched
GetNumQuestWatches                  = C_QuestLog.GetNumQuestWatches
GetNumQuestLogEntries               = C_QuestLog.GetNumQuestLogEntries
GetLogIndexForQuestID               = C_QuestLog.GetLogIndexForQuestID
GetInfo                             = C_QuestLog.GetInfo
IsLegendaryQuest                    = C_QuestLog.IsLegendaryQuest
GetDistanceSqToQuest                = C_QuestLog.GetDistanceSqToQuest
IsQuestBounty                       = C_QuestLog.IsQuestBounty
IsQuestTask                         = C_QuestLog.IsQuestTask
IsQuestComplete                     = C_QuestLog.IsComplete
SetSelectedQuest                    = C_QuestLog.SetSelectedQuest
GetQuestTagInfo                     = C_QuestLog.GetQuestTagInfo
AddQuestWatch                       = C_QuestLog.AddQuestWatch
EnumQuestWatchType                  = _G.Enum.QuestWatchType
-- ========================================================================= --
-- Shadowlands Only function
-- Don't use them in non Shadowlands environments
-- ========================================================================= --
GetRequiredMoney              = C_QuestLog.GetRequiredMoney
GetSuggestedGroupSize         = C_QuestLog.GetSuggestedGroupSize
GetTimeAllowed                = C_QuestLog.GetTimeAllowed
IsOnMap                       = C_QuestLog.IsOnMap
-- ========================================================================= --
-- NEED CHECK these below functions 
GetQuestProgressBarPercent    = GetQuestProgressBarPercent
GetQuestObjectiveInfo         = GetQuestObjectiveInfo
GetQuestLogCompletionText     = GetQuestLogCompletionText
SelectQuestLogEntry           = SelectQuestLogEntry
GetQuestLogSpecialItemInfo    = GetQuestLogSpecialItemInfo
-- ========================================================================= --
_QuestModel                         = RegisterModel(QuestModel, "quests-data")
-- ========================================================================= --
-- Register the achievements content type
-- ========================================================================= --

RegisterContentType({
  ID = "quests",
  DisplayName = "Quests",
  Description = "Track the watched quests",
  DefaultModel = _QuestModel,
  DefaultViewClass = QuestsContentView,
  Events = { "PLAYER_ENTERING_WORLD", "QUEST_WATCH_LIST_CHANGED"},
  Status = function() return GetNumQuestWatches() > 0 end
})
-- ========================================================================= --
DISTANCE_UPDATER_ENABLED      = false
QUESTS_CACHE                  = {}
QUEST_HEADERS_CACHE           = {}
QUESTS_WITH_PROGRESS          = {}
QUESTS_WITH_ITEMS             = {}
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED"
function ActivateOn(self, event, ...)
  return GetNumQuestWatches() > 0
end
-- ========================================================================= --
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

function OnInactive(self)
  _QuestModel:ClearData()
  
  wipe(QUESTS_CACHE)
  wipe(QUESTS_WITH_PROGRESS)

  for questID in pairs(QUESTS_WITH_ITEMS) do
    ItemBar_RemoveItemData(questID)
  end
  ItemBar_Update()

  wipe(QUESTS_WITH_ITEMS)
end
-- ========================================================================= --
function LoadQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  local currentHeader = "Misc"

  for i = 1, numEntries do

    local questInfo = GetInfo(i)


    -- local title, questLogIndex, questID, campaignID, level, difficultyLevel, 
    --   suggestedGroup, frequency, isHeader, isCollapsed, startEvent, isTask,
    --   isBounty, isStory, isScaling, isOnMap, hasLocalPOI, isHidden,
    --   isAutoComplete, overridesSortOrder, readyForTranslation = GetInfo(i)
    local questID   = questInfo.questID
    local isHeader  = questInfo.isHeader
    local isHidden  = questInfo.isHidden
    local isBounty  = questInfo.isBounty
    local isTask    = questInfo.isTask

    if questInfo.isHeader then 
      currentHeader = questInfo.title
    elseif IsQuestWatched(questID) and not isHidden and not isBounty and not isTask then
    -- elseif IsQuestWatched(IsOnShadowlands() and questID or i) and not questInfo.isHidden and not isBounty and not isTask then 
      QUESTS_CACHE[questID] = true
      QUEST_HEADERS_CACHE[questID] = currentHeader

      local questData = {
        title               = questInfo.title,
        name                = questInfo.title,
        questLogIndex       = questInfo.questLogIndex,
        questID             = questInfo.questID,
        campaignID          = questInfo.campaignID,
        level               = questInfo.level,
        difficultyLevel     = questInfo.difficultyLevel,
        suggestedGroup      = questInfo.suggestedGroup,
        frequency           = questInfo.frequency,
        isHeader            = questInfo.isHeader,
        isCollapsed         = questInfo.isCollapsed,
        startEvent          = questInfo.startEvent,
        isTask              = questInfo.isTask,
        isBounty            = questInfo.isBounty,
        isStory             = questInfo.isStory,
        isScaling           = questInfo.isScaling,
        isOnMap             = questInfo.isOnMap,
        hasLocalPOI         = questInfo.hasLocalPOI,
        isHidden            = questInfo.isHidden,
        isAutoComplete      = questInfo.isAutoComplete,
        overridesSortOrder  = questInfo.overridesSortOrder,
        readyForTranslation = questInfo.readyForTranslation,
        header              = currentHeader,
        category            = currentHeader
      }

      -- local questData = {
      --   title = title,
      --   name = title,
      --   questLogIndex = questLogIndex,
      --   questID = questID, 
      --   campaignID = campaignID,
      --   level = level,
      --   suggestedGroup = suggestedGroup,
      --   difficultyLevel = difficultyLevel,
      --   isBounty = isBounty,
      --   isStory = isStory, 
      --   isScaling = isScaling, 
      --   isOnMap = isOnMap,
      --   hasLocalPOI = hasLocalPOI,
      --   isHidden = isHidden,
      --   isAutoComplete = isAutoComplete,
      --   overridesSortOrder = overridesSortOrder,
      --   readyForTranslation = readyForTranslation,
      --   header = currentHeader,
      --   category = currentHeader, 
      -- }

      _QuestModel:SetQuestData(questID, questData)

      RequestLoadQuestByID(questID)
    end 
  end

  _QuestModel:Flush()
end

function UpdateQuest(self, questID)
  -- Cross function & unchanged fonction
  local title             = GetQuestName(questID)
  local level             = GetQuestDifficultyLevel(questID)
  local header            = self:GetQuestHeader(questID)
  local questLogIndex     = GetLogIndexForQuestID(questID)
  local numObjectives     = GetNumQuestObjectives(questID)
  local isComplete        = IsQuestComplete(questID)
  local isTask            = IsQuestTask(questID)
  local isBounty          = IsQuestBounty(questID)
  local distance          = GetDistanceSqToQuest(questID)
  local isDungeon         = IsDungeonQuest(questID)
  local isRaid            = IsRaidQuest(questID)
  local requiredMoney     = GetRequiredMoney(questID)
  local suggestedGroup    = GetSuggestedGroupSize(questID)
  local isLegendary       = IsLegendaryQuest(questID)
  local tag               = GetQuestTagInfo(questID)
  
  if not distance then
    distance = 99999
  else 
    distance = sqrt(distance)
  end

  local failureTime, timeElapsed = GetTimeAllowed(questID)
  local isOnMap, hasLocalPOI      = IsOnMap(questID)

  -- local isStory        
  -- local startEvent      
  -- local isAutoComplete

  local questData = {
    questID         = questID,
    title           = title,
    name            = title,
    level           = level,
    header          = header,
    category        = header,
    questLogIndex   = questLogIndex,
    numObjectives   = numObjectives,
    isComplete      = isComplete,
    isTask          = isTask,
    isBounty        = isBounty,
    requiredMoney   = requiredMoney,
    failureTime     = failureTime,
    isOnMap         = isOnMap,
    hasLocalPOI     = hasLocalPOI,
    questType       = questType,
    tag             = questType,
    isStory         = isStory,
    startEvent      = startEvent,
    isAutoComplete  = isAutoComplete,
    suggestedGroup  = suggestedGroup,
    distance        = distance,
    isDungeon       = isDungeon,
    isRaid          = isRaid,
    isLegendary     = isLegendary,
    tag             = tag
  }

  -- Is the quest has an item quest ?
  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)

  if itemLink and itemTexture then
    questData.item = {
      link    = itemLink,
      texture = itemTexture
    }

    -- We check if the quest has already the item for avoiding useless data 
    -- update.
    if not QUESTS_WITH_ITEMS[questID] then 
      ItemBar_AddItemData(questID, {
        link = itemLink, 
        texture = itemTexture
      })
      ItemBar_Update()

      QUESTS_WITH_ITEMS[questID] = true 
    end
  else 
    QUESTS_WITH_ITEMS[questID] = nil 
  end

  -- Fetch the objectives
  if numObjectives > 0 then
    local objectivesData = {}
    for index = 1, numObjectives do 
      for index = 1, numObjectives do 
        local text, type, finished = GetQuestObjectiveInfo(questID, index, false)
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
          QUESTS_WITH_PROGRESS[questID] = true
        else 
          QUESTS_WITH_PROGRESS[questID] = nil 
        end

        objectivesData[index] = data
      end 
    end

    questData.objectives = objectivesData
  else

    SetSelectedQuest(questID)
    local text = GetQuestLogCompletionText()
    questData.objectives = {
      [1] = {
        text = text,
        isCompleted = false
      }
    }
  end 
  
  _QuestModel:AddQuestData(questID, questData)
end


__SystemEvent__ "QUEST_LOG_UPDATE"
function QUESTS_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end

  _QuestModel:Flush()
end

__SystemEvent__()
function QUEST_POI_UPDATE()
  QuestSuperTracking_OnPOIUpdate()

  _M:UpdateDistance()
end


__SystemEvent__ "ZONE_CHANGED" "ZONE_CHANGED_NEW_ARED" "AREA_POIS_UPDATED"
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

  Trace("The quest (id:%i) has been accepted", questID)

  -- Add it in the quest watched 
  if AUTO_QUEST_WATCH == "1" and GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
    local wasWatched = AddQuestWatch(questID, EnumQuestWatchType.Automatic)
    if wasWatched then 
      QuestSuperTracking_OnQuestTracked(questID)
      Debug("The quest (id:%i) has been watched with success", questID)
    else 
      Debug("The quest (id:%i) hasn't been watched for a unknown reason", questID)
    end
  else 
    Debug("The quest (id:%i) doesn't match the requirements for being watched", questID)
    Trace("AUTO_QUEST_WATCH: %s", AUTO_QUEST_WATCH)
    Trace("GetNumQuestWatches(): %i", GetNumQuestWatches())
    Trace("MAX_QUEST_WATCHES: %i", Constants.QuestWatchConsts.MAX_QUEST_WATCHES)
  end
end

__Async__()
__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then 
    return 
  end

  if isAdded then
    Debug("The quest (id:%i) has been added in the watch list", questID)

    QUESTS_CACHE[questID] = true 
    RequestLoadQuestByID(questID)

    _M:UpdateQuest(questID)
  else 
    Debug("The quest (id:%i) has been removed from the watch list", questID)

    QUESTS_CACHE[questID] = nil
    
    if QUESTS_WITH_ITEMS[questID] then 
      ItemBar_RemoveItemData(questID)
      ItemBar_Update()
      QUESTS_WITH_ITEMS[questID] = nil
    end

    _QuestModel:RemoveQuestData(questID)
    _QuestModel:Flush()
  end 
end

__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success and QUESTS_CACHE[questID] then
    _M:UpdateQuest(questID)
    _QuestModel:Flush()
  end
end

function GetQuestHeader(self, qID)
    -- Check if the quest header is in the cache
    if QUEST_HEADERS_CACHE[qID] then
      return QUEST_HEADERS_CACHE[qID]
    end

    -- if no, find the quest header
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

__Async__()
__SystemEvent__()
function PLAYER_STARTED_MOVING()
  DISTANCE_UPDATER_ENABLED = true
  while  DISTANCE_UPDATER_ENABLED do
    _M:UpdateDistance()

    -- TODO: Create an option for changing the refresh rate.
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
      _QuestModel:AddQuestData(questID, { distance = math.sqrt(distanceSq) })
    end
  end
  
  _QuestModel:Flush()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_QuestModel, "SLT Quest Model")
end
