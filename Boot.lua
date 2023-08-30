-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Bootstrap"                         ""
-- ========================================================================= --
export {
  LibDataBroker       = LibStub("LibDataBroker-1.1"),
  LibDBIcon           = LibStub("LibDBIcon-1.0"),
  GetAddonVersion     = Utils.GetAddonVersion
}

SLT_LOGO           = [[Interface\AddOns\SylingTracker\Media\logo]]

SECURE_HANDLER_FRAME = CreateFrame("Frame", "SylingTracker_SecureHandlerFrame", UIParent, "SecureHandlerBaseTemplate")
SECURE_HANDLER_FRAME:SetFrameRef("ObjectiveTrackerFrame", ObjectiveTrackerFrame)

function OnLoad(self)
  _DB:SetDefault{ dbVersion = 2 }
  _DB:SetDefault{ minimap = { hide = false }}

  -- Setup the minimap button
  self:SetupMinimapButton()

  -- Apply the migrations

  -- Fire an event for saying the DATABASE is fully loaded and ready to be fetched
  FireSystemEvent("SylingTracker_DATABASE_LOADED")
end

__SystemEvent__()
__AsyncSingle__(true)
function BLIZZARD_TRACKER_VISIBLITY_CHANGED(isVisible)
  -- With __AsyncSingle__ only the last call will be handled.
  -- We are waiting the player leaves the combat as we aren't allowed to update 
  -- the visibility of blizzard objective tracker in combat. 
  --
  -- NOTE: In case where the player reload the ui in combat, Blizzard gives us a 
  -- short time before lockdown the protected frames, we could show or hide the 
  -- blizzard objective tracker directly. 
  NoCombat()

  -- We use the secure snippet for avoiding to taint the entire blizzard objective tracker
  if isVisible then 
    SECURE_HANDLER_FRAME:Execute([[
      ObjectiveTrackerFrame = self:GetFrameRef("ObjectiveTrackerFrame")
      ObjectiveTrackerFrame:Show()   
    ]])
  else
    SECURE_HANDLER_FRAME:Execute([[
      ObjectiveTrackerFrame = self:GetFrameRef("ObjectiveTrackerFrame")
      ObjectiveTrackerFrame:Hide()    
    ]])
  end
end

function OnQuit(self)
  FireSystemEvent("SylingTracker_DATABASE_SAVED")

  -- Clean the SaveVariables (remove empty tables) when the player log out
  SavedVariables.Clean() 
end

function SetupMinimapButton(self)
  local LDBObject = LibDataBroker:NewDataObject("SylingTracker", {
    type = "launcher",
    icon = SLT_LOGO,
    OnClick = function(_, button, down)
      _M:OpenOptions()
    end,

    OnTooltipShow = function(tooltip)
      tooltip:AddDoubleLine("Syling Tracker", GetAddonVersion(), 1, 106/255, 0, 1, 1, 1)
      tooltip:AddLine(" ")
      tooltip:AddLine("|cff00ffffClick|r to open the options")
    end
  })

  LibDBIcon:Register("SylingTracker", LDBObject, _DB.minimap)
end


__SlashCmd__ "slt"
function OpenOptions()
  local addonName = "SylingTracker_Options"
  local loaded, reason = LoadAddOn(addonName)
  if not loaded then 
    if reason == "DISABLED" then 
      EnableAddOn(addonName, true)
      LoadAddOn(addonName)
    else
      -- TODO: Put an error message here
      return 
    end
  end

  _M:FireSystemEvent("SylingTracker_OPEN_OPTIONS")
end
