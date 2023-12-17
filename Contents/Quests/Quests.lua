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
  IsQuestWatched                      = IsQuestWatched,
  AddQuestWatch                       = AddQuestWatch
}

QUESTS_CONTENT_SUBJECT = RegisterObservableContent("quests", QuestsContentSubject)

QUESTS_CACHE = {}
QUEST_HEADERS_CACHE = {}
QUESTS_WITH_PROGRESS = {}
QUESTS_WITH_ITEMS = {}
QUESTS_REQUESTED = {}


__ActiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED" "QUEST_LOG_UPDATE"
function BecomeActiveOn(self, event, ...)
  return GetNumQuestWatches() > 0
end

__InactiveOnEvents__  "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED"
function BecomeInactiveOn(self, event, ...)
  return GetNumQuestWatches() == 0
end

__Async__()
function OnActive(self)
  _M:LoadQuests()
end

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
  local currentHeader         = "Misc"

  -- IMPORTANT: Use 'GetNumQuestLogEntries()' for getting the quest entries is prefered but for unknow reasons, the values returned 
  -- are incorrect after loading and until a 'QUEST_LOG_UPDATE' event is triggered. 
  --
  -- This is the reason a while loop is used for fetching the quests data, iterating unil the title is nil. 
  local i = 1
  local title, level, questTag, isHeader, isCollapsed, isComplete, 
  frequency, questID, startEvent, displayQuestID, isOnMap, 
  hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(i)

  while title and title ~= "" do
    if isHeader then 
      currentHeader = title
    elseif IsQuestWatched(i) and not isHidden and not isBounty and not isTask then 
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
      questData.isAutoComplete = nil -- TODO: Need check it
      questData.overridesSortOrder = nil -- TODO: Need Check it
      questData.readyForTranslation = nil -- TODO: Need Check it

      QUESTS_REQUESTED[questID] = true 

      self:UpdateQuest(questID)
    end

    i = i + 1
    title, level, questTag, isHeader, isCollapsed, isComplete, 
    frequency, questID, startEvent, displayQuestID, isOnMap, 
    hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(i)
  end
end




function UpdateQuest(self, questID)
  local questLogIndex = GetQuestLogIndexByID(questID)

  if not questLogIndex then 
    return 
  end

  local numObjectives = GetNumQuestLeaderBoards(questLogIndex)
  local requiredMoney = GetQuestLogRequiredMoney(questLogIndex)
  local tag           = GetQuestTagInfo(questID)


  local isDungeon = false
  local isRaid = false 
  local isLegendary = false 

  if tag then 
    if tag == EQuestTag.Dungeon then 
      isDungeon = true 
    elseif tag == EQuestTag.Legendary then 
      isLegendary = true 
    elseif tag == EQuestTag.Raid or tag == EQuestTag.Raid10 or tag == EQuestTag.Raid25 then 
      isRaid = true 
    end
  end
  
  local title, level, questTag, isHeader, isCollapsed, 
  isComplete, frequency, questID, startEvent, displayQuestID, 
  isOnMap, hasLocalPOI, isTask, isBounty, isStory, 
  isHidden, isScaling = GetQuestLogTitle(questLogIndex)

  -- Transform to boolean
  isComplete = (isComplete and isComplete > 0) and true or false

  local header = self:GetQuestHeader(questID)

  --- TODO: Need check if there is no way for computing the distance
  local distance = 1

  local questData = QUESTS_CONTENT_SUBJECT:AcquireQuest(questID)
  questData.questID = questID
  questData.questLogIndex = questLogIndex
  questData.isFailed = nil -- TODO: Check it
  questData.title = title
  questData.name = title
  questData.level = level
  questData.header = header
  questData.category = header
  questData.campaignID =  nil -- TODO: Remove it
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
  questData.isAutoComplete = nil
  questData.suggestedGroup = nil
  questData.distance = distance
  questData.isImportant = nil
  questData.isCalling = nil
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
      objectiveData.text = text
      objectiveData.type = objectiveType
      objectiveData.isCompleted = finished
    end

    if isComplete then
      local text = GetQuestLogCompletionText(questLogIndex)
      local objectiveData = questData:AcquireObjective()
      objectiveData.text = text
      objectiveData.isCompleted = false    
    end
  else
    local text = GetQuestLogCompletionText(questLogIndex)
    local objectiveData = questData:AcquireObjective()
    objectiveData.text = text
    objectiveData.isCompleted = false    
  end
  questData:StopObjectivesCounter()
end

__SystemEvent__ "QUEST_LOG_UPDATE" "QUEST_POI_UPDATE"
function QUESTS_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end

__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then 
    return 
  end

  if isAdded then 
    QUESTS_CACHE[questID] = true 
    QUESTS_REQUESTED[questID] = true

    _M:UpdateQuest(questID)
  else 
    QUESTS_CACHE[questID] = nil 
    QUESTS_REQUESTED[questID] = nil 

    if QUESTS_WITH_ITEMS[questID] then 
      ItemBar_RemoveItem(questID)
      QUESTS_WITH_ITEMS[questID] = nil 
    end

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
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(QUESTS_CONTENT_SUBJECT, "Quests Content Subject")