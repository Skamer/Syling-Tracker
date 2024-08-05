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