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
export {
  -- Syling API
  ItemBar_AddItemData                 = API.ItemBar_AddItemData,
  ItemBar_RemoveItemData              = API.ItemBar_RemoveItemData,
  ItemBar_Update                      = API.ItemBar_Update,
  RegisterContentType                 = API.RegisterContentType,
  RegisterModel                       = API.RegisterModel,

  -- WoW API & Utils
  CreateAtlasMarkup                   = CreateAtlasMarkup,
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
  IsCampaignQuest                     = Utils.Quest.IsCampaignQuest,
  IsDungeonQuest                      = Utils.Quest.IsDungeonQuest,
  IsFailed                            = C_QuestLog.IsFailed,
  IsLegendaryQuest                    = C_QuestLog.IsLegendaryQuest,
  IsOnMap                             = C_QuestLog.IsOnMap,
  IsQuestBounty                       = C_QuestLog.IsQuestBounty,
  IsQuestComplete                     = C_QuestLog.IsComplete,
  IsQuestTask                         = C_QuestLog.IsQuestTask,
  IsQuestTrivial                      = C_QuestLog.IsQuestTrivial,
  IsQuestWatched                      = QuestUtils_IsQuestWatched,
  IsRaidQuest                         = Utils.Quest.IsRaidQuest,
  IsWorldQuest                        = QuestUtils_IsQuestWorldQuest,
  RequestLoadQuestByID                = C_QuestLog.RequestLoadQuestByID,
  SelectQuestLogEntry                 = SelectQuestLogEntry,
  SelectQuestLogEntry                 = SelectQuestLogEntry,
  SetSelectedQuest                    = C_QuestLog.SetSelectedQuest
}
-- ========================================================================= --
_QuestModel                         = RegisterModel(QuestModel, "quests-data")
-- ========================================================================= --
-- Register the achievements content type
-- ========================================================================= --
_QuestsIconMarkupAtlas = CreateAtlasMarkup("QuestNormal", 16, 16)
_CampaignIconMarkupAtlas = CreateAtlasMarkup("quest-campaign-available", 16, 16)

RegisterContentType({
  ID = "quests",
  Name = "Quests",
  DisplayName = _QuestsIconMarkupAtlas.." Quests",
  Description = "Track the watched quests",
  DefaultOrder = 100,
  DefaultModel = _QuestModel,
  DefaultViewClass = QuestsContentView,
  Events = { "PLAYER_ENTERING_WORLD", "QUEST_WATCH_LIST_CHANGED"},
  Status = function() return GetNumQuestWatches() > 0 end
})

RegisterContentType({
  ID = "campaign",
  Name = "Campaign",
  DisplayName = _CampaignIconMarkupAtlas.." Campaign",
  Description = "Track the camapign quests",
  DefaultOrder = 90,
  DefaultModel = _QuestModel,
  DefaultViewClass = CampaignContentView,
  Events = { "PLAYER_ENTERING_WORLD", "QUEST_WATCH_LIST_CHANGED"},
  Status = function() return GetNumQuestWatches() > 0 end
})
-- ========================================================================= --
local DISTANCE_UPDATER_ENABLED      = false
local QUESTS_CACHE                  = {}
local QUEST_HEADERS_CACHE           = {}
local QUESTS_WITH_PROGRESS          = {}
local QUESTS_WITH_ITEMS             = {}
local QUESTS_REQUESTED              = {}


-- ========================================================================= --
__ActiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED" "QUEST_ACCEPTED"
function BecomeActiveOn(self, event, ...)
  if event == "QUEST_ACCEPTED" then
    -- Caling QUEST_ACCEPTED will watch the quest if matching the requirements,
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

      _QuestModel:SetQuestData(questID, questData)

      QUESTS_REQUESTED[questID] = true
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
  local isFailed          = IsFailed(questID)
  local isTask            = IsQuestTask(questID)
  local isBounty          = IsQuestBounty(questID)
  local distance          = GetDistanceSqToQuest(questID)
  local isDungeon         = IsDungeonQuest(questID)
  local isRaid            = IsRaidQuest(questID)
  local requiredMoney     = GetRequiredMoney(questID)
  local suggestedGroup    = GetSuggestedGroupSize(questID)
  local isLegendary       = IsLegendaryQuest(questID)
  local tag               = GetQuestTagInfo(questID)
  local campaignID        = GetCampaignID(questID)
  local isSequenced       = IsQuestSequenced(questID)
  local isSuperTracked    = (questID == C_SuperTrack.GetSuperTrackedQuestID())
  
  if not distance then
    distance = 99999
  else 
    distance = sqrt(distance)
  end

  local failureTime, timeElapsed = GetTimeAllowed(questID)
  local isOnMap, hasLocalPOI = IsOnMap(questID)

  local shouldShowWaypoint = isSuperTracked or (questID == QuestMapFrame_GetFocusedQuestID())

  -- local isStory        
  -- local startEvent      
  -- local isAutoComplete

  local questData = {
    questID             = questID,
    title               = title,
    name                = title,
    level               = level,
    header              = header,
    category            = header,
    campaignID          = campaignID,
    questLogIndex       = questLogIndex,
    numObjectives       = numObjectives,
    isComplete          = isComplete,
    isFailed            = isFailed,
    isTask              = isTask,
    isBounty            = isBounty,
    requiredMoney       = requiredMoney,
    failureTime         = failureTime,
    isOnMap             = isOnMap,
    hasLocalPOI         = hasLocalPOI,
    questType           = questType,
    tag                 = questType,
    isStory             = isStory,
    startEvent          = startEvent,
    isAutoComplete      = isAutoComplete,
    suggestedGroup      = suggestedGroup,
    distance            = distance,
    isDungeon           = isDungeon,
    isRaid              = isRaid,
    isLegendary         = isLegendary,
    tag                 = tag,
    shouldShowWaypoint  = shouldShowWaypoint,
    isSequenced         = isSequenced,
    isSuperTracked      = isSuperTracked
  }

  -- Is the quest has an item quest ?
  local itemLink, itemTexture
  
  -- We check if the quest log index is valid before fetching as sometimes 
  -- for unknown reason this can be nil.
  if questLogIndex then 
    itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)
  end 

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


  local objectivesData = {}
  if isComplete then
    if not isAutoComplete then 
      for index = 1, numObjectives do 
        local text, type, finished = GetQuestObjectiveInfo(questID, index, true)
        tinsert(objectivesData, { text = text, type = type, isCompleted = finished })
      end
    end

    -- We don't display the progress bar if it's completed, we remove it from tracking.
    QUESTS_WITH_PROGRESS[questID] = nil

    -- In case where the quest is auto complete, this say the user needs to click 
    -- for finishing the quest. We need to notify the player. 
    if isAutoComplete then
      tinsert(objectivesData, { isCompleted = true, text = QUEST_WATCH_QUEST_COMPLETE })
      tinsert(objectivesData, { isCompleted = false, text = QUEST_WATCH_CLICK_TO_COMPLETE })
    else
      local completionText = GetQuestLogCompletionText(questLogIndex)
      if completionText then 

        -- The waypoint text is here for helping the player to navigate for completing the quest.
        if shouldShowWaypoint then 
          local waypointText = GetNextWaypointText(questID)
          if waypointText then 
            tinsert(objectivesData, { isCompleted = false, text =  WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText)})
          end
        end

        tinsert(objectivesData, { isCompleted = false, text= completionText} )
      else 
        local waypointText = GetNextWaypointText(questID)
        if waypointText then 
          tinsert(objectivesData, { isCompleted = false, text = waypointText})
        else
          tinsert(objectivesData, { isCompleted = false, text = QUEST_WATCH_QUEST_READY})
        end
      end
    end
  elseif isFailed then
    objectivesData = { [1] = { isCompleted = false, failed = true, text = FAILED } }

    -- We don't display the progress bar if it's failed, we remove it from tracking.
    QUESTS_WITH_PROGRESS[questID] = nil
  else
    if shouldShowWaypoint then 
      -- The waypoint text is here for helping the player to navigate for progress on the quest, it's still optional.
      local waypointText = GetNextWaypointText(questID)
      if waypointText then
        tinsert(objectivesData, { isCompleted = false, text = WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText)})
      end
    end

    for index = 1, numObjectives do 
      local text, type, finished = GetQuestObjectiveInfo(questID, index, false)
      local data = { text = text, type = type, isCompleted = finished }

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

        tinsert(objectivesData, data)
    end

    --- Display the money objective if the player hasn't enought for the quest.
    local playerMoney = GetMoney()
    if requiredMoney > playerMoney then 
      local text = GetMoneyString(playerMoney) .. " / " .. GetMoneyString(requiredMoney)
      tinsert(objectivesData, { isCompleted = false, text = text })
    end
  end

  _QuestModel:AddQuestData(questID, questData)
  -- For the objectives, we use 'SetData' directly to be sure there are no old 
  -- data about them, in addition to keep the 'AddQuestData' feature for the
  -- other quest data.
  _QuestModel:SetData(objectivesData, "quests", questID, "objectives")
end


__SystemEvent__ "QUEST_LOG_UPDATE" "SUPER_TRACKING_CHANGED"
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

  Trace("The quest (id:%i) has been accepted", questID)

  -- Add it in the quest watched 
  if GetCVarBool("autoQuestWatch") and GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
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

__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then 
    return 
  end

  -- Manually tracking the world quest trigger this event so we need to check
  -- this isn't a world quest
  if IsWorldQuest(questID) then 
    return 
  end

  if isAdded then
    Debug("The quest (id:%i) has been added in the watch list", questID)

    QUESTS_CACHE[questID] = true 
    QUESTS_REQUESTED[questID] = true

    RequestLoadQuestByID(questID)

    -- _M:UpdateQuest(questID)
  else 
    Debug("The quest (id:%i) has been removed from the watch list", questID)

    QUESTS_CACHE[questID] = nil
    QUESTS_REQUESTED[questID] = nil
    
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
  if success and QUESTS_REQUESTED[questID] then
    QUESTS_REQUESTED[questID] = nil 

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
function OnEnable(self)
  if ViragDevTool and ViragDevTool.AddData then 
    ViragDevTool:AddData(_QuestModel, "SLT Quest Model")
  end
end
