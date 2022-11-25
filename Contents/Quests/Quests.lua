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
  --- Syling API
  ItemBar_AddItemData                 = API.ItemBar_AddItemData,
  ItemBar_RemoveItemData              = API.ItemBar_RemoveItemData,
  ItemBar_Update                      = API.ItemBar_Update,
  RegisterContentType                 = API.RegisterContentType,
  RegisterModel                       = API.RegisterModel,

  --- WoW API & Utils
  GetNumQuestLogEntries               = GetNumQuestLogEntries,
  GetNumQuestWatches                  = GetNumQuestWatches,
  GetQuestLogTitle                    = GetQuestLogTitle,
  GetNumQuestLeaderBoards             = GetNumQuestLeaderBoards,
  GetQuestLogLeaderBoard              = GetQuestLogLeaderBoard,
  GetQuestLogRequiredMoney            = GetQuestLogRequiredMoney,
  GetQuestTagInfo                     = GetQuestTagInfo,
  GetQuestLogSpecialItemInfo          = GetQuestLogSpecialItemInfo,
  GetQuestLogCompletionText           = GetQuestLogCompletionText,
  IsQuestWatched                      = IsQuestWatched,
  AddQuestWatch                       = AddQuestWatch
}
-- ========================================================================= --
_QuestModel                         = RegisterModel(QuestModel, "quests-data")
-- ========================================================================= --
-- Register the quests content type
-- ========================================================================= --
_QuestsIconMarkupAtlas = CreateAtlasMarkup("QuestNormal", 16, 16)

RegisterContentType({
  ID = "quests",
  Name = "Quests",
  DisplayName = _QuestsIconMarkupAtlas.." Quests",
  Description = "Track the watched quests",
  DefaultOrder = 100,
  DefaultModel = _QuestModel,
  DefaultViewClass = QuestsContentView,
  Events = { "PLAYER_ENTERING_WORLD", "QUEST_WATCH_LIST_CHANGED", "QUEST_LOG_UPDATE"},
  Status = function(...)
    return GetNumQuestWatches() > 0 
  end
})
-- ========================================================================= --
local QUESTS_CACHE                = {}
local QUEST_HEADERS_CACHE         = {}
local QUESTS_WITH_ITEMS           = {}
-- ========================================================================= --
__ActiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED" "QUEST_LOG_UPDATE"
function BecomeActiveOn(self, event, ...)
  return GetNumQuestWatches() > 0
end

__InactiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED"
function BecomeInactiveOn(self, event, ...)
  return GetNumQuestWatches() == 0
end
-- ========================================================================= --
__Async__()
function OnActive(self)
  --- Sometimes during the initialLogin, GetNumQuestLogEntries() returns 0, 0 even 
  --- if the player has watched quests, preventing the module to load correctly 
  --- the quests. We have to delay the quest loading until GetNumQuestLogEntries()
  --- returning correct values.
  local _, numQuests = GetNumQuestLogEntries()
  local watchedQuests = GetNumQuestWatches()
  while numQuests == 0 and watchedQuests > 0 do 
      _, numQuests = GetNumQuestLogEntries()
      Next()
  end

  _M:LoadQuests()
end

function OnInactive(self)
  _QuestModel:ClearData()
  
  wipe(QUESTS_CACHE)

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
    local title, level, questTag, isHeader, isCollapsed, isComplete, 
    frequency, questID, startEvent, displayQuestID, isOnMap, 
    hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(i)

    if isHeader then 
      currentHeader = title 
    elseif IsQuestWatched(i) and not isHidden and not isBounty and not isTask then
      QUESTS_CACHE[questID] = true 
      QUEST_HEADERS_CACHE[questID] = currentHeader

      local questData = {
        title               = title,
        name                = title,
        questLogIndex       = i,
        questID             = questID,
        campaignID          = nil,
        level               = level,
        difficultyLevel     = nil, --- TODO: Need check it 
        suggestedGroup      = nil, --- TODO: Need check it
        frequency           = frequency,
        isHeader            = isHeader,
        isCollapsed         = isCollapsed,
        startEvent          = startEvent,
        isTask              = isTask,
        isBounty            = isBounty,
        isStory             = isStory,
        isScaling           = isScaling,
        isOnMap             = isOnMap,
        hasLocalPOI         = hasLocalPOI,
        isHidden            = isHidden,
        isAutoComplete      = nil, --- TODO: Need check it
        overridesSortOrder  = nil, --- TODO: Need check it
        readyForTranslation = nil, --- TODO: Need check it
        header              = currentHeader,
        category            = currentHeader
      }

      _QuestModel:SetQuestData(questID, questData)

      -- Update Quest
      self:UpdateQuest(questID)
    end
  end

  _QuestModel:Flush()
end

function UpdateQuest(self, questID)
  local questLogIndex = GetQuestLogIndexByID(questID)

  if not questLogIndex then 
    return 
  end

  local numObjectives = GetNumQuestLeaderBoards(questLogIndex)
  local requiredMoney = GetQuestLogRequiredMoney(questLogIndex)
  local tag           = GetQuestTagInfo(questID)

  local title, level, questTag, isHeader, isCollapsed, 
  isComplete, frequency, questID, startEvent, displayQuestID, 
  isOnMap, hasLocalPOI, isTask, isBounty, isStory, 
  isHidden, isScaling = GetQuestLogTitle(questLogIndex)

  local header = self:GetQuestHeader(questID)
  
  --- TODO: Need check if there is no way for computing the distance
  local distance = 1

  local questData = {
    questID         = questID,
    title           = title,
    name            = title,
    level           = level,
    header          = header,
    category        = header,
    campaignID      = nil, -- TODO: Remove
    questLogIndex   = questLogIndex,
    numObjectives   = numObjectives,
    isComplete      = isComplete,
    isTask          = isTask,
    isBounty        = isBounty,
    requiredMoney   = requiredMoney,
    failureTime     = nil, -- TODO: Check
    isOnMap         = isOnMap,
    hasLocalPOI     = hasLocalPOI,
    isStory         = isStory,
    startEvent      = startEvent,
    isAutoComplete  = nil,
    suggestedGroup  = nil,
    distance        = distance,
    isDungeon       = false, -- Not supported for WOTLK classic
    isRaid          = false, -- Not supported for WOTLK classic
    isLegendary     = false, -- Not supported for WOTLK classic
    tag             = tag
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

  -- Fetch the objectives
  if numObjectives > 0 then 
    local objectivesData = {}
    for index = 1, numObjectives do 
      local text, type, finished = GetQuestLogLeaderBoard(index, questLogIndex)
      local data = {
        text = text,
        type = type,
        isCompleted = finished
      }

      objectivesData[index] = data
    end

    questData.objectives = objectivesData
  else 
    local text = GetQuestLogCompletionText(questLogIndex)
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
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then 
    return 
  end

  if isAdded then 
    Debug("The quest (id:%i) has been added in the watch list", questID)
    
    QUESTS_CACHE[questID] = true

    _M:UpdateQuest(questID)
    _QuestModel:Flush()
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

function GetQuestHeader(self, qID)
  -- Check if the quest header is in the cache
  if QUEST_HEADERS_CACHE[qID] then
    return QUEST_HEADERS_CACHE[qID]
  end
  
  -- if no, find the quest header
  local currentHeader = "Misc"
  local numEntries, numQuests = GetNumQuestLogEntries()

  for i = 1, numEntries do 
    local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i)
    if isHeader then 
      currentHeader = title
    elseif questID == qID then 
      QUEST_HEADERS_CACHE[qID] = currentHeader
      return currentHeader
    end
  end

  return currentHeader
end