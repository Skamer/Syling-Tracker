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
  LibDataBroker                       = LibStub("LibDataBroker-1.1"),
  LibDBIcon                           = LibStub("LibDBIcon-1.0"),
  GetAddonVersion                     = Utils.GetAddonVersion,
  RegisterSetting                     = API.RegisterSetting,
  GetSetting                          = API.GetSetting,
  GetTrackerSettingWithDefault        = API.GetTrackerSettingWithDefault,
  GetItemBarSettingWithDefault        = API.GetItemBarSettingWithDefault
}

local SLT_LOGO           = [[Interface\AddOns\SylingTracker\Media\logo]]

local BLIZZARD_OBJECTIVE_TRACKER = nil
local SHOW_BLIZZARD_OBJECTIVE_TRACKER = false
if IsVanilla() then 
  BLIZZARD_OBJECTIVE_TRACKER = QuestWatchFrame
elseif IsCataclysm() or IsMoP() then 
  BLIZZARD_OBJECTIVE_TRACKER = WatchFrame 
else 
  BLIZZARD_OBJECTIVE_TRACKER = ObjectiveTrackerFrame
end

if IsRetail() then 
  BLIZZARD_OBJECTIVE_TRACKER:HookScript("OnShow", function()
    if not SHOW_BLIZZARD_OBJECTIVE_TRACKER then 
      BLIZZARD_OBJECTIVE_TRACKER:Hide()
    end
  end)
end

function OnLoad(self)
  local lastestDBVersion = 3
  
  _DB:SetDefault{ dbVersion = lastestDBVersion }
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
  local currentDBVersion = _DB.dbVersion
  for version = currentDBVersion, lastestDBVersion - 1 do 
    FireSystemEvent("SylingTracker_DATABASE_APPLY_MIGRATION", version)
  end
  _DB.dbVersion = lastestDBVersion

  -- Fire an event for saying the DATABASE is fully loaded and ready to be fetched
  FireSystemEvent("SylingTracker_DATABASE_LOADED")
end

function OnEnable(self)
  BLIZZARD_TRACKER_VISIBLITY_CHANGED(GetSetting("showBlizzardObjectiveTracker"))
end

__SystemEvent__()
function BLIZZARD_TRACKER_VISIBLITY_CHANGED(isVisible)
  SHOW_BLIZZARD_OBJECTIVE_TRACKER = isVisible

  if isVisible then
    ObjectiveTrackerFrame:Show()
  else
    ObjectiveTrackerFrame:Hide()
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
      tooltip:AddLine(_Locale.MINIMAP_BUTTON_TOOLTIP)
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
  args = args:lower()

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
  args = args:lower()

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

local function GetParsedEffectiveEnabledTracker(unparsedTrackerID)
  local defaultTrackerID = "main"

  if not unparsedTrackerID then 
    local enabled = GetTrackerSettingWithDefault(defaultTrackerID, "enabled")
    return enabled
  end

  local invert, trackerID = unparsedTrackerID:match("(!?)(.+)")

  if invert == "" then 
    invert = false 
  else
    invert = true 
  end

  if trackerID == "" then 
    trackerID = defaultTrackerID
  end

  local enabled = API.GetTrackerSettingWithDefault(trackerID, "enabled")

  if invert then 
    return not enabled
  else 
    return enabled
  end
end

--- `/slt toggle` toogle the itembar and all the trackers (sync with main tracker).
--- `/slt toggle all` the same as above.
--- `/slt toggle trackers` the same as above except this doesn't include the item bar.
--- `/slt toggle tracker main` toggle only the main tracker. 
--- `/slt toggle tracker second` toggle only the tracker with for id: 'second'.
--- `/slt toggle tracker second main` toggle only the tracker with for id: `second' but sync with the main tracker.
--- `/slt toggle itembar` toggle only the item bar.
--- `/slt toggle itembar main` toggle only the item bar but will be synced with the main tracker.
__SlashCmd__ "slt" "toggle"
__SlashCmd__ "slt" "tenable"
function ToggleEnableElementCommand(args)
  args = args:lower()

  local arg1, arg2, arg3 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then
    local enabled = GetParsedEffectiveEnabledTracker(arg2)
    if enabled then 
      _M:FireSystemEvent("SylingTracker_DISABLE_TRACKERS")
      _M:FireSystemEvent("SylingTracker_DISABLE_ITEMBAR")
    else 
      _M:FireSystemEvent("SylingTracker_ENABLE_TRACKERS")
      _M:FireSystemEvent("SylingTracker_ENABLE_ITEMBAR")
    end
  elseif arg1 == "itembar" then
    local enabled 
    if not arg2 or arg2 == "" then 
      enabled = GetItemBarSettingWithDefault("enabled")
    else 
      enabled = GetParsedEffectiveEnabledTracker(arg2)
    end

    if enabled then
      _M:FireSystemEvent("SylingTracker_DISABLE_ITEMBAR")
    else 
      _M:FireSystemEvent("SylingTracker_ENABLE_ITEMBAR")
    end

  elseif arg1 == "trackers" then
    local enabled = GetParsedEffectiveEnabledTracker(arg2)
    if enabled then 
      _M:FireSystemEvent("SylingTracker_DISABLE_TRACKERS")
    else 
      _M:FireSystemEvent("SylingTracker_ENABLE_TRACKERS")
    end    
  elseif arg1 == "tracker" then
    local enabled = GetParsedEffectiveEnabledTracker(arg3 or arg2)

    if enabled then 
       _M:FireSystemEvent("SylingTracker_DISABLE_TRACKER", arg2)
    else 
       _M:FireSystemEvent("SylingTracker_ENABLE_TRACKER", arg2)
    end
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
  args = args:lower()

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
  args = args:lower()

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
  args = args:lower()

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
  args = args:lower()

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
  args = args:lower()

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
  args = args:lower()

  local arg1, arg2 = strsplit(" ", args)
  if arg1 == "" or arg1 == "all" then 
    -- TODO
  elseif arg1 == "itembar" then 
    -- TODO
  elseif arg1 == "tracker" then 
    _M:FireSystemEvent("SylingTracker_RESET_POSITION_TRACKER", arg2)
  end
end
