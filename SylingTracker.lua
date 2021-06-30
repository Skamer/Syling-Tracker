-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                          "SylingTracker"                              ""
-- ========================================================================= --
import                              "SLT"
-- ========================================================================= --
Log                 = Logger("SylingTracker")

Trace               = Log:SetPrefix(1, "|cffa9a9a9[SLT:Trace]|r")
Debug               = Log:SetPrefix(2, "|cff808080[SLT:Debug]|r")
Info                = Log:SetPrefix(3, "|cffffffff[SLT:Info]|r")
Warn                = Log:SetPrefix(4, "|cffffff00[SLT:Warn]|r")
Error               = Log:SetPrefix(5, "|cffff0000[SLT:Error]|r")
Fatal               = Log:SetPrefix(6, "|cff8b0000[SLT:Fatal]|r")

Log.LogLevel        = 3
Log.UseTimeFormat   = false
Log:AddHandler(print)
-- ========================================================================= --
_SLT_VERSION       = GetAddOnMetadata("SylingTracker", "Version")
-- ========================================================================= --
_SCORPIO_VERSION    = tonumber(GetAddOnMetadata("Scorpio", "Version"):match("%d+$"))
_PLOOP_VERSION      = tonumber(GetAddOnMetadata("PLoop", "Version"):match("%d+$"))
-- ========================================================================= --
_LibSharedMedia     = LibStub("LibSharedMedia-3.0")
_LibDataBroker      = LibStub("LibDataBroker-1.1")
_LibDBIcon          = LibStub("LibDBIcon-1.0")
-- ========================================================================= --
_SLT_LOGO           = [[Interface\AddOns\SylingTracker\Media\logo]]

function OnLoad(self)
  -- Create and init the DB 
  _DB = SVManager("SylingTrackerDB")

  -- Regiser the options 
  Settings.Register("replace-blizzard-objective-tracker", true, "Blizzard/UpdateTrackerVisibility")

  -- Register the callbacks
  CallbackManager.Register("Blizzard/UpdateTrackerVisibility", Callback(function(replace) BLIZZARD_TRACKER_VISIBLITY_CHANGED(not replace) end))

  --
  _DB:SetDefault{ dbVersion = 1 }
  _DB:SetDefault{ minimap = { hide = false }}

  -- Setup the minimap button
  self:SetupMinimapButton()
end

function OnEnable(self)
  BLIZZARD_TRACKER_VISIBLITY_CHANGED(not Settings.Get("replace-blizzard-objective-tracker"))
end


__SystemEvent__()
function BLIZZARD_TRACKER_VISIBLITY_CHANGED(isVisible)
  local wasInitialized = false
  if not ObjectiveTrackerFrame.initialized then 
    ObjectiveTracker_Initialize(ObjectiveTrackerFrame)
    wasInitilized = true
  end

  if isVisible and not wasInitialized then
    ObjectiveTrackerFrame:SetScript("OnEvent", ObjectiveTracker_OnEvent)
    WorldMapFrame:RegisterCallback("SetFocusedQuestID", ObjectiveTracker_OnFocusedQuestChanged, ObjectiveTrackerFrame)
    WorldMapFrame:RegisterCallback("ClearFocusedQuestID", ObjectiveTracker_OnFocusedQuestChanged, ObjectiveTrackerFrame)
    
    ObjectiveTrackerFrame:Show()
    ObjectiveTracker_Update()
  else
    ObjectiveTrackerFrame:Hide()
    
    ObjectiveTrackerFrame:SetScript("OnEvent", nil)
    WorldMapFrame:UnregisterCallback("SetFocusedQuestID", ObjectiveTrackerFrame)
    WorldMapFrame:UnregisterCallback("ClearFocusedQuestID", ObjectiveTrackerFrame)
  end
end

function OnQuit(self)
  -- Do a clean in the database (remove empty table) when the player log out
  Database.Clean()
end 

function SetupMinimapButton(self)
  local LDBObject = _LibDataBroker:NewDataObject("SylingTracker", {
    type = "launcher",
    icon = _SLT_LOGO,
    OnClick = function(_, button, down)

    end,

    OnTooltipShow = function(tooltip)
      tooltip:AddDoubleLine("Syling Tracker", _SLT_VERSION, 1, 106/255, 0, 1, 1, 1)
    end
  })

  _LibDBIcon:Register("SylingTracker", LDBObject, _DB.minimap)
end


-- __SlashCmd__ "slt" "config"
-- function OpenOptions()
--   local loaded, reason = LoadAddOn("SylingTracker_Options")
-- end

__SlashCmd__ "slt" "bot" "- enable/disable the blizzard objective tracker"
function ToggleBlizzardObjectiveTracker()
  Settings.Set("replace-blizzard-objective-tracker", ObjectiveTrackerFrame:IsShown())
end

__SlashCmd__ "slt" "lock" "- lock the Tracker and the Item Bar, preventing them to be moved or resized"
function LockCommand()
  _M:FireSystemEvent("SLT_LOCK_COMMAND")
end

__SlashCmd__ "slt" "unlock" "- unlock the Tracker and the Item Bar, allowing you to resize or move them"
function UnlockCommand()
  _M:FireSystemEvent("SLT_UNLOCK_COMMAND")
end

__SlashCmd__ "slt" "show" "- show the Tracker and the Item bar"
function ShowCommand()
  _M:FireSystemEvent("SLT_SHOW_COMMAND")
end

__SlashCmd__ "slt" "hide" "- hide the Tracker and the Item Bar"
function HideCommand()
  _M:FireSystemEvent("SLT_HIDE_COMMAND")
end

__SlashCmd__ "slt" "toggle" "- toggle the Tracker and the Item Bar"
function ToggleCommand()
  _M:FireSystemEvent("SLT_TOGGLE_COMMAND")
end

__SlashCmd__ "slt" "scrollstep" "- set the scroll sensibility (default: 15)"
function SetScrollStepCommand(info)
  local val = tonumber(info)

  if val then 
    _M:FireSystemEvent("SLT_SCROLL_STEP_COMMAND", val)
  end
end

__SlashCmd__ "slt" "log" "- set the log level"
function SetLogLevel(info)
  local val = tonumber(info)
  
  Info("Set the Log Level to %i", val)
  Log.LogLevel = val
end

__SlashCmd__ "slt" "qcat" "- toggle the displaying of categories for quests"
function ToggleQuestCategories()
  _M:FireSystemEvent("SLT_TOGGLE_QUEST_CATEGORIES_COMMAND")
end

__SlashCmd__ "slt" "minimap" "- toggle the minimap button"
function ToggleMinimapButton()
  local isHidden = not _DB.minimap.hide

  if isHidden then 
    _LibDBIcon:Hide("SylingTracker")
  else 
    _LibDBIcon:Show("SylingTracker")
  end

  _DB.minimap.hide = isHidden
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD(initialLogin, reloadingUI)
  IsInitialLogin  = initialLogin
  IsReloadingUI   = reloadingUI
end

-------------------------------------------------------------------------------
-- LibSharedMedia: register the fonts
-------------------------------------------------------------------------------
_Fonts = {
  -- PT Sans Family Fonts
  ["PT Sans"] = [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Regular.ttf]],
  ["PT Sans Bold"] = [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Bold.ttf]],
  ["PT Sans Bold Italic"] = [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Bold-Italic.ttf]],
  ["PT Sans Narrow"]  = [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Narrow.ttf]],
  ["PT Sans Narrow Bold"] = [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Narrow-Bold.ttf]],
  ["PT Sans Caption"] = [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Caption.ttf]],
  ["PT Sans Caption Bold"] = [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Caption-Bold.ttf]],
  -- DejaVuSans Family Fonts
  ["Deja Vu Sans"] = [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSans.ttf]],
  ["Deja Vu Sans Bold"] = [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSans-Bold.ttf]],
  ["Deja Vu Sans Bold Italic"] = [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSans-BoldOblique.ttf]],
  ["DejaVuSansCondensed"] = [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed.ttf]],
  ["DejaVuSansCondensed Bold"] = [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed-Bold.ttf]],
  ["DejaVuSansCondensed Bold Italic"] = [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed-BoldOblique.ttf]],
  ["DejaVuSansCondensed Italic"] = [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed-Oblique.ttf]]

}

for fontName, fontFile in pairs(_Fonts) do
  _LibSharedMedia:Register("font", fontName, fontFile)
end
-- -------------------------------------------------------------------------------
-- LibSharedMedia: register the backgounds
-------------------------------------------------------------------------------
_LibSharedMedia:Register("background", "SylingTracker Background", [[Interface\AddOns\SylingTracker\Media\Textures\Frame-Background]])


