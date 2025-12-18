-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.AutoQuests"                       ""
-- ========================================================================= --
-- As we have to interact with SecureHooks, we need the module still active.
-- ========================================================================= --
export {
  -- Addon API 
  RegisterObservableContent           = API.RegisterObservableContent,

  -- Wow API & Utils 
  GetNumAutoQuestPopUps               = GetNumAutoQuestPopUps,
  GetAutoQuestPopUp                   = GetAutoQuestPopUp,
  GetQuestName                        = QuestUtils_GetQuestName,
  AddAutoQuestPopUp                   = AddAutoQuestPopUp,

}

AUTO_QUESTS_CONTENT_SUBJECT = RegisterObservableContent("autoQuests", AutoQuestsContentSubject)

function AddAutoQuest(self, questID, type)
  local autoQuestData = AUTO_QUESTS_CONTENT_SUBJECT:AcquireAutoQuest(questID)
  local name = GetQuestName(questID)

  autoQuestData.questID = questID
  autoQuestData.type    = type
  autoQuestData.name    = name
end

function RemoveAutoQuest(self, questID)
  AUTO_QUESTS_CONTENT_SUBJECT.autoQuests[questID] = nil
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  for i = 1, GetNumAutoQuestPopUps() do 
    local questID, popupType = GetAutoQuestPopUp(i)
    _M:AddAutoQuest(questID, popupType)
  end 
end

__SystemEvent__()
function QUEST_AUTOCOMPLETE(questID)
  -- Important ! Don't forget adding the auto quest popup when it's autocomplete
  -- else it will be ignore by GetNumAutoQuestPopUps 
  AddAutoQuestPopUp(questID, "COMPLETE")

  _M:AddAutoQuest(questID, "COMPLETE")
end

-- For these below hooks, don't need calling AddAutoQuestPopUP or RemoveAutoQuestPopUp
-- as it's already done by original function. 
__SecureHook__()
function WatchFrameAutoQuest_AddPopUp(questID, popupType)
  _M:AddAutoQuest(questID, popupType)
end

__SecureHook__()
function WatchFrameAutoQuest_ClearPopUp(questID)
  _M:RemoveAutoQuest(questID)
end

local TEST_MODE_ID = "AutoQuest"
local IS_TEST_MODE = false
local TEST_MODE_OFFER_ID = -1
local TEST_MODE_COMPLETE_ID = -2

__SystemEvent__()
function SylingTracker__TestMode(id)
  
  if TEST_MODE_ID ~= id then 
    return 
  end

  if IS_TEST_MODE then
    AUTO_QUESTS_CONTENT_SUBJECT.autoQuests[TEST_MODE_OFFER_ID] = nil
    AUTO_QUESTS_CONTENT_SUBJECT.autoQuests[TEST_MODE_COMPLETE_ID] = nil
  else 
    local offerAutoQuestData = AUTO_QUESTS_CONTENT_SUBJECT:AcquireAutoQuest(TEST_MODE_OFFER_ID)
    offerAutoQuestData.questID = TEST_MODE_OFFER_ID
    offerAutoQuestData.type  = "OFFER"
    offerAutoQuestData.name  = "Offer AutoQuest Quest Name" 

    local completeAutoQuestData = AUTO_QUESTS_CONTENT_SUBJECT:AcquireAutoQuest(TEST_MODE_COMPLETE_ID)
    completeAutoQuestData.questID = TEST_MODE_COMPLETE_ID
    completeAutoQuestData.type  = "COMPLETE"
    completeAutoQuestData.name  = "Complete AutoQuest Quest Name"
  end

  IS_TEST_MODE = not IS_TEST_MODE
end

-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(AUTO_QUESTS_CONTENT_SUBJECT, "Auto Quests Content Subject")