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
  GetAddonVersion     = Utils.GetAddonVersion,
  RegisterSetting     = API.RegisterSetting,
  GetSetting          = API.GetSetting
}

SLT_LOGO           = [[Interface\AddOns\SylingTracker\Media\logo]]

SECURE_HANDLER_FRAME = CreateFrame("Frame", "SylingTracker_SecureHandlerFrame", UIParent, "SecureHandlerBaseTemplate")
SECURE_HANDLER_FRAME:Hide()
SECURE_HANDLER_FRAME:SetFrameRef("ObjectiveTrackerFrame", ObjectiveTrackerFrame)

function OnLoad(self)
  _DB:SetDefault{ dbVersion = 2 }
  _DB:SetDefault{ minimap = { hide = false }}

  -- Register the settings 
  RegisterSetting("showBlizzardObjectiveTracker", false, function(show) BLIZZARD_TRACKER_VISIBLITY_CHANGED(show) end)
  RegisterSetting("showMinimapIcon", true, function(show) 
    if show then 
      LibDBIcon:Show("SylingTracker")
    else
      LibDBIcon:Hide("SylingTracker")
    end

    _DB.minimap.hide = not show
  end)

  -- Setup the minimap button
  self:SetupMinimapButton()

  -- Apply the migrations

  -- Fire an event for saying the DATABASE is fully loaded and ready to be fetched
  FireSystemEvent("SylingTracker_DATABASE_LOADED")
end

function OnEnable(self)
  BLIZZARD_TRACKER_VISIBLITY_CHANGED(GetSetting("showBlizzardObjectiveTracker"))
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

    if OPARENT then 
      ObjectiveTrackerFrame:SetParent(OPARENT)
    end

    SECURE_HANDLER_FRAME:Execute([[
      ObjectiveTrackerFrame = self:GetFrameRef("ObjectiveTrackerFrame")
      ObjectiveTrackerFrame:Show()
    ]])
  else

    -- since the 11.0, we need to change its parent for avoiding to be reshown due an event.
    OPARENT = ObjectiveTrackerFrame:GetParent()
    SECURE_HANDLER_FRAME:Execute([[
      ObjectiveTrackerFrame = self:GetFrameRef("ObjectiveTrackerFrame")
      ObjectiveTrackerFrame:Hide()
      ObjectiveTrackerFrame:SetParent(self)
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


--- `/slt enable` enable all the trackers
--- `/slt enable all` the same as above 
--- `/slt enable trackers` the same as above 
--- `/slt enable tracker main` enable only the main tracker 
--- `/slt enable tracker second` enable only the tracker with for id: second
__SlashCmd__ "slt" "enable"
function EnableElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    _M:FireSystemEvent("SylingTracker_ENABLE_TRACKERS")
    _M:FireSystemEvent("SylingTracker_ENABLE_ITEMBAR")
  elseif arg1 == "itembar" then 
    _M:FireSystemEvent("SylingTracker_ENABLE_ITEMBAR")
  elseif arg1 == "trackers" then 
    _M:FireSystemEvent("SylingTracker_ENABLE_TRACKERS")
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_ENABLE_TRACKER", arg2)
  end
end

--- `/slt disable` disable all the trackers
--- `/slt disable all` the same as above 
--- `/slt disable trackers` the same as above 
--- `/slt disable tracker main` disable only the main tracker 
--- `/slt disable tracker second` disable only the tracker with for id: second 
__SlashCmd__ "slt" "disable"
function DisableElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    _M:FireSystemEvent("SylingTracker_DISABLE_TRACKERS")
    _M:FireSystemEvent("SylingTracker_DISABLE_ITEMBAR")
  elseif arg1 == "itembar" then 
    _M:FireSystemEvent("SylingTracker_DISABLE_ITEMBAR")
  elseif arg1 == "trackers" then 
    _M:FireSystemEvent("SylingTracker_DISABLE_TRACKERS")
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_DISABLE_TRACKER", arg2)
  end
end

--- `/slt show` show all the trackers and the item bar 
--- `/slt show all` the same as above 
--- `/slt show itembar` show only the item bar 
--- `/slt show trackers` show only all the trackers 
--- `/slt show tracker main` show only the main tracker 
--- `/slt show tracker second` show only the tracker with for id: second 
__SlashCmd__ "slt" "show"
function ShowElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    _M:FireSystemEvent("SylingTracker_SHOW_TRACKERS")
    _M:FireSystemEvent("SylingTracker_ENABLE_ITEMBAR")
  elseif arg1 == "itembar" then 
    _M:FireSystemEvent("SylingTracker_ENABLE_ITEMBAR")
  elseif arg1 == "trackers" then 
    _M:FireSystemEvent("SylingTracker_SHOW_TRACKERS")
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_SHOW_TRACKER", arg2)
  end
end

--- `/slt tshow tracker main` toggle show only the main tracker 
--- `/slt tshow tracker second` toggle show only the tracker with for id: second
__SlashCmd__ "slt" "tshow"
function ToggleShowElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    -- TODO
  elseif arg1 == "itembar" then 
    -- TODO
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_TOGGLE_SHOW_TRACKER", arg2)
  end
end

--- `/slt hide` show all the trackers and the item bar 
--- `/slt hide all` the same as above 
--- `/slt hide itembar` hide only the item bar 
--- `/slt hide trackers` hide only all the trackers 
--- `/slt hide tracker main` hide only the main tracker 
--- `/slt hide tracker second` hide only the tracker with for id: second 
__SlashCmd__ "slt" "hide"
function HideElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    _M:FireSystemEvent("SylingTracker_HIDE_TRACKERS")
    _M:FireSystemEvent("SylingTracker_DISABLE_ITEMBAR")
  elseif arg1 == "itembar" then 
    _M:FireSystemEvent("SylingTracker_DISABLE_ITEMBAR")
  elseif arg1 == "trackers" then 
    _M:FireSystemEvent("SylingTracker_HIDE_TRACKERS")
  elseif arg1 == "tracker" then
    _M:FireSystemEvent("SylingTracker_HIDE_TRACKER", arg2)
  end
end

--- `/slt lock` lock all the trackers and the item bar 
--- `/slt lock all` the same as above 
--- `/slt lock itembar` lock only the item bar 
--- `/slt lock trackers` lock only all the trackers 
--- `/slt lock tracker main` lock only the main tracker 
--- `/slt lock tracker second` lock only the tracker with for id: second 
__SlashCmd__ "slt" "lock"
function LockElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    _M:FireSystemEvent("SylingTracker_LOCK_TRACKERS")
    _M:FireSystemEvent("SylingTracker_LOCK_ITEMBAR")
  elseif arg1 == "itembar" then 
    _M:FireSystemEvent("SylingTracker_LOCK_ITEMBAR")
  elseif arg1 == "trackers" then 
    _M:FireSystemEvent("SylingTracker_LOCK_TRACKERS")
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_LOCK_TRACKER", arg2)
  end
end

--- `/slt unlock` unlock all the trackers and the item bar 
--- `/slt unlock all` the same as above 
--- `/slt unlock itembar` unlock only the item bar 
--- `/slt unlock trackers` unlock only all the trackers 
--- `/slt unlock tracker main` unlock only the main tracker 
--- `/slt unlock tracker second` unlock only the tracker with for id: second 
__SlashCmd__ "slt" "unlock"
function UnlockElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    _M:FireSystemEvent("SylingTracker_UNLOCK_TRACKERS")
    _M:FireSystemEvent("SylingTracker_UNLOCK_ITEMBAR")
  elseif arg1 == "itembar" then 
    _M:FireSystemEvent("SylingTracker_UNLOCK_ITEMBAR")
  elseif arg1 == "trackers" then 
    _M:FireSystemEvent("SylingTracker_UNLOCK_TRACKERS")
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_UNLOCK_TRACKER", arg2)
  end
end

--- `/slt resetpos tracker main` reset only the tracker position for main
--- `/slt resetpos tracker second` reset only the tracker position with for id: second 
__SlashCmd__ "slt" "resetpos"
function ResetPosElementCommand(args)
  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    -- TODO
  elseif arg1 == "itembar" then 
    -- TODO
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_RESET_POSITION_TRACKER", arg2)
  end
end
