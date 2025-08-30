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
  GetTimePlayed                       = Utils.GetTimePlayed,
  ItemBar_AddItem                     = API.ItemBar_AddItem,
  ItemBar_RemoveItem                  = API.ItemBar_RemoveItem,
  ItemBar_Update                      = API.ItemBar_Update,
  ItemBar_SetItemDistance             = API.ItemBar_SetItemDistance,

  --- WoW API & Utils
  EQuestTag                           = _G.Enum.QuestTag,
  GetNumQuestLogEntries               = GetNumQuestLogEntries,
  GetNumQuestWatches                  = GetNumQuestWatches,
  GetQuestLogTitle                    = GetQuestLogTitle,
  GetNumQuestLeaderBoards             = GetNumQuestLeaderBoards,
  GetQuestLogLeaderBoard              = GetQuestLogLeaderBoard,
  GetQuestLogRequiredMoney            = GetQuestLogRequiredMoney,
  GetQuestTagInfo                     = GetQuestTagInfo,
  GetQuestLogSpecialItemInfo          = GetQuestLogSpecialItemInfo,
  GetQuestLogCompletionText           = GetQuestLogCompletionText,
  GetQuestLogIsAutoComplete           = GetQuestLogIsAutoComplete,
  IsQuestWatched                      = IsQuestWatched,
  AddQuestWatch                       = AddQuestWatch
}

QUESTS_CONTENT_SUBJECT = RegisterObservableContent("quests", QuestsContentSubject)

QUESTS_CACHE = {}
QUEST_HEADERS_CACHE = {}
QUESTS_WITH_ITEMS = {}
QUESTS_REQUESTED = {}

local QUEST_NEW_MAX_AGE = nil
local QUEST_NEW_REMOVE_ON_PROGRESS = nil

__ActiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED" "QUEST_LOG_UPDATE"
function BecomeActiveOn(self, event, ...)
  return GetNumQuestWatches() > 0
end

__InactiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED"
function BecomeInactiveOn(self, event, ...)
  return GetNumQuestWatches() == 0
end

function OnActive(self)
  _M:LoadQuests()

  self:RunAgeUpdater()
end

function OnInactive(self)
  self:StopAgeUpdater()

  wipe(QUESTS_CACHE)

  for questId in pairs(QUESTS_WITH_ITEMS) do 
    ItemBar_RemoveItem(questId)
  end

  ItemBar_Update()

  wipe(QUESTS_WITH_ITEMS)
end

__Async__()
function LoadQuests(self)
  -- IMPORTANT: When the game has no cache and it's the player's first login, GetNumQuestLogEntries returns 0,
  -- even if we know there are quests. This is why we need to delay execution until it returns a value other than 0
  local numEntries  = GetNumQuestLogEntries()
  local timePlayed = GetTimePlayed()
  while numEntries == 0 or timePlayed == 0 do
    Next() 
    numEntries = GetNumQuestLogEntries()
    timePlayed = GetTimePlayed()
  end

  local currentHeader         = "Misc"

  local i = 1
  local title, level, questTag, isHeader, isCollapsed, isComplete, 
  frequency, questID, startEvent, displayQuestID, isOnMap, 
  hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(i)
  local isAutoComplete = GetQuestLogIsAutoComplete(i)

  while title and title ~= "" do
    if isHeader then 
      currentHeader = title
    elseif not isHidden and not isBounty and not isTask then
      local receivedTime = self:GetQuestReceivedTime(questID)
      if not receivedTime then
        receivedTime = time() 
        self:SetQuestReceivedTime(questID, receivedTime)
      end

      if IsQuestWatched(i) then 
        QUESTS_CACHE[questID]         = true 
        QUEST_HEADERS_CACHE[questID]  = currentHeader

        -- Transform to boolean
        isComplete = (isComplete and isComplete > 0) and true or false


        local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)
        questData.questID = questID
        questData.questLogIndex = i
        questData.title = title
        questData.name = title
        questData.header = currentHeader
        questData.category = currentHeader
        questData.isComplete = isComplete
        questData.campaignID = nil
        questData.level = level
        questData.difficultyLevel = nil -- TODO: Need check it
        questData.suggestedGroup = nil -- TODO: Need check it
        questData.frequency = frequency
        questData.isHeader = isHeader
        questData.isCollapsed = isCollapsed
        questData.startEvent = startEvent
        questData.isTask = isTask
        questData.isBounty = isBounty
        questData.isScaling = isScaling
        questData.isOnMap = isOnMap
        questData.hasLocalPOI = hasLocalPOI
        questData.isHidden = isHeader
        questData.isAutoComplete = isAutoComplete
        questData.overridesSortOrder = nil -- TODO: Need Check it
        questData.readyForTranslation = nil -- TODO: Need Check it

        self:UpdateQuest(questID, true)
      end
    end

    i = i + 1
    title, level, questTag, isHeader, isCollapsed, isComplete, 
    frequency, questID, startEvent, displayQuestID, isOnMap, 
    hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(i)
    local isAutoComplete = GetQuestLogIsAutoComplete(i)
  end
end

function UpdateQuest(self, questID, firstUpdate)
  local questLogIndex = GetQuestLogIndexByID(questID)

  if not questLogIndex then 
    return 
  end

  local hasChanged  = false
  local numObjectives = GetNumQuestLeaderBoards(questLogIndex)
  local requiredMoney = GetQuestLogRequiredMoney(questLogIndex)
  local tagID, tagName = GetQuestTagInfo(questID)
  local tag = { tagID = tagID, tagName = tagName }

  local isDungeon = false
  local isRaid = false 
  local isLegendary = false 

  if tagID then
    if tagID == EQuestTag.Dungeon or tagID == EQuestTag.Heroic then 
      isDungeon = true 
    elseif tagID == EQuestTag.Legendary then 
      isLegendary = true 
    elseif tagID == EQuestTag.Raid or tag == EQuestTag.Raid10 or tag == EQuestTag.Raid25 then 
      isRaid = true 
    end
  end

  local isAutoComplete = GetQuestLogIsAutoComplete(questLogIndex)
  local title, level, questTag, isHeader, isCollapsed, 
  isComplete, frequency, questID, startEvent, displayQuestID, 
  isOnMap, hasLocalPOI, isTask, isBounty, isStory, 
  isHidden, isScaling = GetQuestLogTitle(questLogIndex)

  -- Transform to boolean
  isComplete = (isComplete and isComplete > 0) and true or false

  local header = self:GetQuestHeader(questID)

  local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)

  if questData.numObjectives ~= numObjectives then 
    hasChanged = true
  elseif questData.isComplete ~= isComplete then 
    hasChanged = true
  end
  
  questData.questID = questID
  questData.questLogIndex = questLogIndex
  questData.isNew = GetCharCacheValue("newquests", questID)
  questData.age = self:GetQuestAge(questID)
  questData.isFailed = false
  questData.title = title
  questData.name = title
  questData.level = level
  questData.header = header
  questData.category = header
  questData.campaignID = 0
  questData.numObjectives = numObjectives
  questData.isComplete = isComplete
  questData.isTask = isTask
  questData.isBounty = isBounty
  questData.requiredMoney = requiredMoney
  -- questData.totalTime = totalTime
  -- questData.elapsedTime = elapsedTime
  -- questData.startTime =  elapsedTime and GetTime() - elapsedTime
  -- questData.hasTimer = (totalTime and elapsedTime) and true
  questData.isOnMap = isOnMap
  questData.hasLocalPOI = hasLocalPOI
  -- questData.questType= tag
  questData.tag = tag
  questData.isStory = isStory
  questData.startEvent = startEvent
  questData.isAutoComplete = isAutoComplete
  questData.suggestedGroup = nil
  questData.distance = 1
  questData.isDungeon = isDungeon
  questData.isRaid = isRaid
  questData.isLegendary = isLegendary
  questData.isImportant = false
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

  questData:StartObjectivesCounter()
  if numObjectives > 0 then 
    for index = 1, numObjectives do 
      local text, objectiveType, finished = GetQuestLogLeaderBoard(index, questLogIndex)
      local objectiveData = questData:AcquireObjective()

      if objectiveData.text ~= text then 
        hasChanged = true
      end

      objectiveData.text = text
      objectiveData.type = objectiveType
      objectiveData.isCompleted = finished
    end
  else
    local text = GetQuestLogCompletionText(questLogIndex)
    local objectiveData = questData:AcquireObjective()
    objectiveData.text = text
    objectiveData.isCompleted = false
  end
  questData:StopObjectivesCounter()


  if QUEST_NEW_REMOVE_ON_PROGRESS and not firstUpdate and hasChanged and questData.isNew then
    questData.isNew = false
    SetCharCacheValue("newquests", questID, false)
  end
end

__SystemEvent__ "QUEST_LOG_UPDATE" "QUEST_POI_UPDATE"
function QUESTS_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID)
  _M:SetQuestReceivedTime(questID, time())
  SetCharCacheValue("newquests", questID, true)
end

__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then 
    return 
  end

  if isAdded then 
    QUESTS_CACHE[questID] = true 

    _M:UpdateQuest(questID, true)
  else 
    QUESTS_CACHE[questID] = nil 

    if QUESTS_WITH_ITEMS[questID] then 
      ItemBar_RemoveItem(questID)
      QUESTS_WITH_ITEMS[questID] = nil 
    end

    QUESTS_CONTENT_SUBJECT.quests[questID] = nil

    SetCharCacheValue("newquests", questID, nil)
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
  local timePlayed = GetTimePlayed()

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