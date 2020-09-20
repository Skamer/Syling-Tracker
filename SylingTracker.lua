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

Trace               = Log:SetPrefix(1, "|cffa9a9a9[SLT:Trace]|r", true)
Debug               = Log:SetPrefix(2, "|cff808080[SLT:Debug]|r", true)
Info                = Log:SetPrefix(3, "|cffffffff[SLT:Info]|r", true)
Warn                = Log:SetPrefix(4, "|cffffff00[SLT:Warn]|r", true)
Error               = Log:SetPrefix(5, "|cffff0000[SLT:Error]|r", true)
Fatal               = Log:SetPrefix(6, "|cff8b0000[SLT:Fatal]|r", true)

Log.LogLevel        = 3
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

function OnLoad(self)
  -- Create and init the DB 
  _DB = SVManager("SylingTrackerDB")
end


function OnQuit(self)
  -- Do a clean in the database (remove empty table) when the player log out
  Database.Clean()
end 


__SlashCmd__ "slt" "config"
function OpenOptions()
  local loaded, reason = LoadAddOn("SylingTracker_Options")
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


