-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Core.IQueueAdjustHeight"                  ""
-- ========================================================================= --
ADJUST_HEIGHT_TASK_TOKEN    = Toolset.newtable(true)
CANCEL_ADJUST_HEIGHT_TOKEN  = Toolset.newtable(true)

interface "IQueueAdjustHeight" (function(_ENV)
  require "Scorpio.UI.Frame"

  --- Redefine this method in putting your logic to compute the height frame. 
  --- Don't call it directly, use instead "AdjustHeight" or "ForceAdjustHeight".
  __Abstract__() function OnAdjustHeight(self) end

  __Async__() function AdjustHeight(self)
    -- Update the token 
    local token = (ADJUST_HEIGHT_TASK_TOKEN[self] or 0) + 1
    ADJUST_HEIGHT_TASK_TOKEN[self] = token 

    Next()

    if token ~= ADJUST_HEIGHT_TASK_TOKEN[self] then 
      return
    end

    if not CANCEL_ADJUST_HEIGHT_TOKEN[self] then 
      self:OnAdjustHeight()
    end

    -- Release the tokens
    CANCEL_ADJUST_HEIGHT_TOKEN[self]  = nil
    ADJUST_HEIGHT_TASK_TOKEN[self]    = nil
  end

  --- The function will cancel the current queue, and will call directly the 
  --- "OnAdjustHeight" method.
  function ForceAdjustHeight(self)
    self:CancelAdjustHeight()
    self:OnAdjustHeight()
  end

  --- Cancel the queue. 
  --- You probably want to do that when the frame is released. 
  function CancelAdjustHeight(self)
    CANCEL_ADJUST_HEIGHT_TOKEN[self] = true
  end
end)