-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Secure"                         ""
-- ========================================================================= --
export {
  RegisterSetting     = API.RegisterSetting,
  GetSetting          = API.GetSetting,
  SetSetting          = API.SetSetting,
  OpenQuestDetails    = QuestUtil.OpenQuestDetails,
}

UTILS_SECURE_HANDLER_FRAME = CreateFrame("Frame", "SylingTracker_UtilsSecureHandlerFrame", UIParent, "SecureHandlerBaseTemplate")
UTILS_SECURE_HANDLER_FRAME:Hide()

function Secure_OpenToQuestDetails(questID)
  if InCombatLockdown() then 
    return 
  end

  -- TODO: To remove once the action manager is implemented.
  local showMap = GetSetting("showMapForQuestDetails")
  if showMap then
    QuestMapFrame_OpenToQuestDetails(questID)
  else 
    OpenQuestDetails(questID)
  end
end

Utils.Secure_OpenToQuestDetails = Secure_OpenToQuestDetails

function OnLoad(self)
  RegisterSetting("showMapForQuestDetails", true)
end

--- NOTE: This is a temporary command will be removed once the action manager is implemented.
--- `/slt showMapForQuestDetails false` for showing the quest details without the map
__SlashCmd__ "slt" "showMapForQuestDetails"
function showMapForQuestDetails(args)
  if args == "false" then 
    SetSetting("showMapForQuestDetails", false) 
  elseif args == "true" then
    SetSetting("showMapForQuestDetails", true )
  else 
    SetSetting("showMapForQuestDetails", nil) 
  end
end