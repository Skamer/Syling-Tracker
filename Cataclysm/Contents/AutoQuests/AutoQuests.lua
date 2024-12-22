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
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(AUTO_QUESTS_CONTENT_SUBJECT, "Auto Quests Content Subject")