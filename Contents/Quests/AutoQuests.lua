-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.AutoQuests"                         ""
-- ========================================================================= --
import                          "SLT"
-- ========================================================================= --
-- TODO: Need to make test later
RegisterContentType               = API.RegisterContentType
RegisterModel                     = API.RegisterModel
-- ========================================================================= --
_AutoQuestModel = RegisterModel(QuestModel, "auto-quests-data")
-- ========================================================================= --
GetNumAutoQuestPopUps             = GetNumAutoQuestPopUps
GetAutoQuestPopUp                 = GetAutoQuestPopUp
IsQuestBounty                     = IsQuestBounty
RequestLoadQuestByID              = C_QuestLog.RequestLoadQuestByID
GetQuestName                      = QuestUtils_GetQuestName
AddAutoQuestPopUp                 = AddAutoQuestPopUp
-- ========================================================================= --
RegisterContentType({
  ID = "auto-quests",
  DisplayName = "Auto Quests PopUp",
  Description = "The auto quests are quests which are automatically accepeted or completed from notication PopUp",
  DefaultOrder = 1,
  DefaultModel = _AutoQuestModel,
  DefaultViewClass = AutoQuestsContentView,
  Events = { "PLAYER_ENTERING_WORLD", "SLT_AUTOQUEST_ADDED", "SLT_AUTOQUEST_REMOVED", "QUEST_AUTOCOMPLETE" },
  Status = function() return GetNumAutoQuestPopUps() > 0 end
})
-- ========================================================================= --
-- This is here for knowing which quest has been requested by this module, as 
-- QUEST_DATA_LOAD_RESULT event may be used by anothers modules.
_QUESTS_ID_REQUESTED = {}

function LoadAutoQuests()
  for i = 1, GetNumAutoQuestPopUps() do 
    local questID, popupType = GetAutoQuestPopUp(i)

    if not IsQuestBounty(questID) then
      _M:AddAutoQuest(questID, popupType)
    end
  end

  _AutoQuestModel:Flush()
end

function AddAutoQuest(self, questID, type)
  _QUESTS_ID_REQUESTED[questID] = true 

  RequestLoadQuestByID(questID)

  _AutoQuestModel:AddQuestData(questID, {
    questID = questID,
    type    = type
  })

  _M:FireSystemEvent("SLT_AUTOQUEST_ADDED")
end

function RemoveAutoQuest(self, questID)
  RemoveAutoQuestPopUp(questID)
  _AutoQuestModel:RemoveQuestData(questID)
  _M:FireSystemEvent("SLT_AUTOQUEST_REMOVED")
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  _M:LoadAutoQuests()
end

__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success and _QUESTS_ID_REQUESTED[questID] then
    local name = GetQuestName(questID)
    _AutoQuestModel:AddQuestData(questID, {
      name  = name, 
      title = title,
    })

    _QUESTS_ID_REQUESTED[questID] = nil
    _AutoQuestModel:Flush()
  end
end

__SystemEvent__()
function QUEST_AUTOCOMPLETE(questID)
  -- Important ! Don't forget adding the auto quest popup when it's autocomplate 
  -- else it will be ignored by GetNumAutoQuestPopUps
  AddAutoQuestPopUp(questID, "COMPLETE")

  _M:AddAutoQuest(questID, "COMPLETE")
  _AutoQuestModel:Flush()
end

-- For these below hooks, don't need calling AddAutoQuestPopUp or RemoveAutoQuestPopUp
-- as it's already done by original function.
__SecureHook__()
function AutoQuestPopupTracker_AddPopUp(questID, popupType)
  _M:AddAutoQuest(questID, popupType)
  _AutoQuestModel:Flush()
end

__SecureHook__()
function AutoQuestPopupTracker_RemovePopUp(questID)
  _M:RemoveAutoQuest(questID)
  _AutoQuestModel:Flush()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_AutoQuestModel, "SLT Auto Quest Model")
end
