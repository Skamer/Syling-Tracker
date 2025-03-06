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
local TOOLTIP = CreateFrame("GameTooltip", "SylingTracker_Tooltip", UIParent, "GameTooltipTemplate")
local TOOLTIP_TOKEN = 0

function GetTooltip()
  return TOOLTIP
end

function UseTooltip()
  local token = TOOLTIP_TOKEN + 1
  TOOLTIP_TOKEN = token 

  return TOOLTIP, token 
end

__Async__() function ProcessTooltipPendingData(isPendingFunc, readyFunc, token, interval)
  local isPending = isPendingFunc()

  while isPending and token == TOOLTIP_TOKEN do 
    Delay(interval)

    isPending = isPendingFunc() 
  end

  if token == TOOLTIP_TOKEN then 
    readyFunc()
  end
end

function SetTooltipPendingData(isPendingFunc, readyFunc, token, interval)
  ProcessTooltipPendingData(isPendingFunc, readyFunc, token, interval)
end

API.GetTooltip = GetTooltip
API.UseTooltip = UseTooltip
API.SetTooltipPendingData = SetTooltipPendingData