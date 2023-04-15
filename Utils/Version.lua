-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Version"                        ""
-- ========================================================================= --

ADDON_VERSION     = GetAddOnMetadata("SylingTracker", "Version")
SCORPIO_VERSION   = tonumber(GetAddOnMetadata("Scorpio", "Version"):match("%d+$"))

function Utils.GetAddonVersion()
  return ADDON_VERSION
end

function Utils.GetScorpioVersion()
  return SCORPIO_VERSION
end