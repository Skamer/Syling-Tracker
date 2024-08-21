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
namespace                       "SylingTracker"
-- ========================================================================= --
__Sealed__() __Final__() interface "API" {}
-- ========================================================================= --
__Sealed__() __Final__() interface "DebugTools" {}
-- ========================================================================= --
__Sealed__() __Final__() interface "Utils" {}
-- ========================================================================= --
_G.SylingTracker = {
  API         = API,
  DebugTools  = DebugTools,
  Utils       = Utils
}

-------------------------------------------------------------------------------
-- Version utils                                                             --
-------------------------------------------------------------------------------
ADDON_VERSION     = GetAddOnMetadata("SylingTracker", "Version")
SCORPIO_VERSION   = tonumber(GetAddOnMetadata("Scorpio", "Version"):match("%d+$"))
WOW_TOC_VERSION   = select(4, GetBuildInfo())

__AutoCache__()
function GetAddonVersion() 
  return ADDON_VERSION
end

__AutoCache__()
function GetScorpioVersion()
  return SCORPIO_VERSION
end

__AutoCache__()
function IsRetail()
  return WOW_TOC_VERSION >= 110000
end

__AutoCache__()
function IsCataclysm()
  return WOW_TOC_VERSION >= 40000 and WOW_TOC_VERSION < 50000
end

__AutoCache__()
function IsVanilla()
  return WOW_TOC_VERSION >= 10000 and WOW_TOC_VERSION < 20000
end

-- Export as Utils
Utils.GetAddonVersion     = GetAddonVersion
Utils.GetScorpioVersion   = GetScorpioVersion
Utils.IsRetail            = IsRetail 
Utils.IsCataclysm         = IsCataclysm
Utils.IsVanilla           = IsVanilla

function OnLoad(self)
  _DB = SVManager("SylingTrackerDB")

  _DB:SetDefault({ dbVersion = 2 })
  _DB:SetDefault{ minimap = { hide = false }}
end
-------------------------------------------------------------------------------
-- Setup the track data features                                             --
-------------------------------------------------------------------------------
__Arguments__ { Any, String}
__Static__() function DebugTools.TrackData(data, dataName)
  if ViragDevTool and ViragDevTool.AddData then
    local status, err = pcall(ViragDevTool.AddData, ViragDevTool, data, "|cffff0000Syling Tracker|r - " .. dataName)
  end 

  if DevTool and DevTool.AddData then 
    pcall(DevTool.AddData, DevTool, data, "|cffff0000Syling Tracker|r - " .. dataName)
  end
end