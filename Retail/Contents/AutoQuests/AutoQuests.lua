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
  IsQuestBounty                       = C_QuestLog.IsQuestBounty,
  RequestLoadQuestByID                = C_QuestLog.RequestLoadQuestByID,
  GetQuestName                        = QuestUtils_GetQuestName,
  AddAutoQuestPopUp                   = AddAutoQuestPopUp,

}

AUTO_QUESTS_CONTENT_SUBJECT = RegisterObservableContent("autoQuests", AutoQuestsContentSubject)
AUTO_QUESTS_REQUESTED       = {}

function AddAutoQuest(self, questID, type)
  AUTO_QUESTS_REQUESTED[questID] = true 

  RequestLoadQuestByID(questID)

  local autoQuestData = AUTO_QUESTS_CONTENT_SUBJECT:AcquireAutoQuest(questID)
  autoQuestData.questID = questID
  autoQuestData.type    = type
end

function RemoveAutoQuest(self, questID)
  AUTO_QUESTS_CONTENT_SUBJECT.autoQuests[questID] = nil
end

__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success and  AUTO_QUESTS_REQUESTED[questID] then 
    local name          = GetQuestName(questID)
    local autoQuestData = AUTO_QUESTS_CONTENT_SUBJECT:AcquireAutoQuest(questID)
    autoQuestData.name  = name

    AUTO_QUESTS_REQUESTED[questID] = nil 
  end
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  for i = 1, GetNumAutoQuestPopUps() do 
    local questID, popupType = GetAutoQuestPopUp(i)

    if not IsQuestBounty(questID) then
      _M:AddAutoQuest(questID, popupType)
    end
  end 
end

__SystemEvent__()
function QUEST_AUTOCOMPLETE(questID)
  -- Important ! Don't forget adding the auto quest popup when it's autocomplete
  -- else it will be ignore by GetNumAutoQuestPopUps 
  AddAutoQuestPopUp(questID, "COMPLETE")

  _M:AddAutoQuest(questID, "COMPLETE")
end

-- QuestObjectiveTracker.AddAutoQuestPopUp

-- For these below hooks, don't need calling AddAutoQuestPopUP or RemoveAutoQuestPopUp
-- as it's already done by original function. 
-- __SecureHook__()
-- function AutoQuestPopupTracker_AddPopUp(questID, popupType)
--   _M:AddAutoQuest(questID, popupType)
-- end

__SecureHook__(QuestObjectiveTracker, "AddAutoQuestPopUp")
function Hook_AddAutoQuestPopUp(_, questID, popupType, itemID)
  _M:AddAutoQuest(questID, popupType)
end

__SecureHook__(QuestObjectiveTracker, "RemoveAutoQuestPopUp")
function Hook_RemoveAutoQuestPopUp(_, questID)
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

-- __SecureHook__()
-- function AutoQuestPopupTracker_RemovePopUp(questID)
--   _M:RemoveAutoQuest(questID)
-- end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(AUTO_QUESTS_CONTENT_SUBJECT, "Auto Quests Content Subject")