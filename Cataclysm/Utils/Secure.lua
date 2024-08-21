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
UTILS_SECURE_HANDLER_FRAME = CreateFrame("Frame", "SylingTracker_UtilsSecureHandlerFrame", UIParent, "SecureHandlerBaseTemplate")
UTILS_SECURE_HANDLER_FRAME:Hide()

function Secure_OpenToQuestDetails(questID)
  if InCombatLockdown() then 
    return 
  end

  QuestMapFrame_OpenToQuestDetails(questID)
end

Utils.Secure_OpenToQuestDetails = Secure_OpenToQuestDetails
