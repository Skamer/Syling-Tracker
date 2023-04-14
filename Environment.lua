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
end
-------------------------------------------------------------------------------
-- Setup the logging features                                                --
-------------------------------------------------------------------------------
__Arguments__ { String/nil, String/nil, String/nil, Any * 0}
__Static__() function DebugTools.Log(level, category, message, ...)
  if not message then 
    return 
  end

  level = level or "INFO"

  Scorpio.FireSystemEvent("SylingTracker_LOG", level, category, message, ...)
end

__Arguments__ { String/nil, String/nil, Any * 0 }
__Static__() function DebugTools.Trace(category, message, ...)
  DebugTools.Log("TRACE", category, message, ...)
end

__Arguments__ { String/nil, String/nil, Any * 0 }
__Static__() function DebugTools.Debug(category, message, ...)
  DebugTools.Log("DEBUG", category, message, ...)
end

__Arguments__ { String/nil, String/nil, Any * 0 }
__Static__() function DebugTools.Info(category, message, ...)
  DebugTools.Log("INFO", category, message, ...)
end

__Arguments__ { String/nil, String/nil, Any * 0 }
__Static__() function DebugTools.Warn(category, message, ...)
  DebugTools.Log("WARN", category, message, ...)
end

__Arguments__ { String/nil, String/nil, Any * 0 }
__Static__() function DebugTools.Error(category, message, ...)
  DebugTools.Log("ERROR", category, message, ...)
end

__Arguments__ { String/nil, String/nil, Any * 0 }
__Static__() function DebugTools.Fatal(category, message, ...)
  DebugTools.Log("FATAL", category, message, ...)
end

