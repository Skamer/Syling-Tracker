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
local ADDON_VERSION     = GetAddOnMetadata("SylingTracker", "Version")
local SCORPIO_VERSION   = tonumber(GetAddOnMetadata("Scorpio", "Version"):match("%d+$"))
local WOW_TOC_VERSION   = select(4, GetBuildInfo())

local STARTED_TIME = 0
local STARTED_TIME_PLAYED = 0

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
function IsMidnight()
  return WOW_TOC_VERSION >= 120000
end

__AutoCache__()
function IsMoP()
  return WOW_TOC_VERSION >= 50000 and WOW_TOC_VERSION < 60000
end

__AutoCache__()
function IsCataclysm()
  return WOW_TOC_VERSION >= 40000 and WOW_TOC_VERSION < 50000
end

__AutoCache__()
function IsVanilla()
  return WOW_TOC_VERSION >= 10000 and WOW_TOC_VERSION < 20000
end

function GetTimePlayed()
  if STARTED_TIME_PLAYED == 0 then 
    return 0
  end
  
  return STARTED_TIME_PLAYED + (time() - STARTED_TIME)
end

-- Export as Utils
Utils.GetAddonVersion     = GetAddonVersion
Utils.GetScorpioVersion   = GetScorpioVersion
Utils.GetTimePlayed       = GetTimePlayed
Utils.IsRetail            = IsRetail
Utils.IsMidnight          = IsMidnight
Utils.IsMoP               = IsMoP 
Utils.IsCataclysm         = IsCataclysm
Utils.IsVanilla           = IsVanilla

function OnLoad(self)
  self:InitTimePLayed()

  _DB = SVManager("SylingTrackerDB")

  _DB:SetDefault({ dbVersion = 2 })
  _DB:SetDefault{ minimap = { hide = false }}
end

__Async__()
function InitTimePLayed()
  RequestTimePlayed()

  local _, totalTimePlayed = Wait("TIME_PLAYED_MSG")

  STARTED_TIME = time()
  STARTED_TIME_PLAYED = totalTimePlayed
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