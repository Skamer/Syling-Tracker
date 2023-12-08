-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Core.Tooltip"                     ""
-- ========================================================================= --

TOOLTIP = CreateFrame("GameTooltip", "SylingTracker_Tooltip", UIParent, "GameTooltipTemplate" )

function GetTooltip()
  return TOOLTIP
end

API.GetTooltip = GetTooltip