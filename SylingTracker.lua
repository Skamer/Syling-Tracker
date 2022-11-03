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
SLT_VERSION       = GetAddOnMetadata("SylingTracker", "Version")
-- ========================================================================= --
SCORPIO_VERSION    = tonumber(GetAddOnMetadata("Scorpio", "Version"):match("%d+$"))
-- ========================================================================= --
LibSharedMedia     = LibStub("LibSharedMedia-3.0")
LibDataBroker      = LibStub("LibDataBroker-1.1")
LibDBIcon          = LibStub("LibDBIcon-1.0")
-- ========================================================================= --
SLT_LOGO           = [[Interface\AddOns\SylingTracker\Media\logo]]

local function ShowMinimapIconCallback(show)
  if show then 
    LibDBIcon:Show("SylingTracker")
  else
    LibDBIcon:Hide("SylingTracker")
  end
  
  _DB.minimap.hide = not show
end

function OnLoad(self)
  --- Create and init the DB 
  _DB = SVManager("SylingTrackerDB")

  --- Register the options 
  SLT.Settings.Register("showBlizzardObjectiveTracker", false, "Blizzard/UpdateTrackerVisibility")
  SLT.Settings.Register("showMinimapIcon", true, "ShowMinimapIcon")

  --- Register the callbacks
  SLT.CallbackManager.Register("Blizzard/UpdateTrackerVisibility", SLT.Callback(function(show) BLIZZARD_TRACKER_VISIBLITY_CHANGED(show) end))
  SLT.CallbackManager.Register("ShowMinimapIcon", SLT.Callback(ShowMinimapIconCallback))

  --
  _DB:SetDefault{ dbVersion = 2 }
  _DB:SetDefault{ minimap = { hide = false }}

  -- Setup the minimap button
  self:SetupMinimapButton()

  --- Apply the migrations
  self:ApplyMigrationsToDB()
end

function OnEnable(self)
  BLIZZARD_TRACKER_VISIBLITY_CHANGED(SLT.Settings.Get("showBlizzardObjectiveTracker"))
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
  SLT.Database.Clean()
end 

function SetupMinimapButton(self)
  local LDBObject = LibDataBroker:NewDataObject("SylingTracker", {
    type = "launcher",
    icon = SLT_LOGO,
    OnClick = function(_, button, down)
      _M:OpenOptions()
    end,

    OnTooltipShow = function(tooltip)
      tooltip:AddDoubleLine("Syling Tracker", SLT_VERSION, 1, 106/255, 0, 1, 1, 1)
      tooltip:AddLine(" ")
      tooltip:AddLine("|cff00ffffClick|r to open the options")
    end
  })

  LibDBIcon:Register("SylingTracker", LDBObject, _DB.minimap)
end

__SlashCmd__ "slt" "log" "- set the log level"
function SetLogLevel(info)
  local val = tonumber(info)
  
  Info("Set the Log Level to %i", val)
  Log.LogLevel = val
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD(initialLogin, reloadingUI)
  IsInitialLogin  = initialLogin
  IsReloadingUI   = reloadingUI
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

  _M:FireSystemEvent("SLT_OPEN_OPTIONS")
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
  LibSharedMedia:Register("font", fontName, fontFile)
end
-------------------------------------------------------------------------------
-- LibSharedMedia: register the backgounds
-------------------------------------------------------------------------------
LibSharedMedia:Register("background", "SylingTracker Background", [[Interface\AddOns\SylingTracker\Media\Textures\Frame-Background]])

-------------------------------------------------------------------------------
-- Migrations DB
-------------------------------------------------------------------------------
function ApplyMigrationsToDB()
  --- The migration changes the settings name of:
  --  "replace-blizzard-objective-tracker" -> "showBlizzardObjectiveTracker"
  --  "quests-enable-categories" -> "questsEnableCategories"
  if SLT.Database.GetVersion() == 1 then
    SLT.Database.SelectRoot()
    local settings = SLT.Database.GetValue("settings")
    local oldValue = settings and settings["replace-blizzard-objective-tracker"]

    --- rename "replace-blizzard-objective-tracker"
    if oldValue ~= nil then
      --- We invert the value because if "replace-blizzard-objective-tracker" was true 
      --- it will say we hidee the Blizzard Objective Tracker
      SLT.Settings.Set("showBlizzardObjectiveTracker", not oldValue)
      
      settings["replace-blizzard-objective-tracker"] = nil
    end

    --- rename "quests-enable-categories"
    oldValue = settings and settings["quests-enable-categories"]
    if oldValue ~= nil then
      SLT.Settings.Set("questsEnableCategories", oldValue)

      settings["quests-enable-categories"] = nil 
    end

    --- We changed the database version for the next time, the migration
    --- won't be applied again
    SLT.Database.SetVersion(2)
  end
end


