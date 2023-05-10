-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Core.SharedInterfaces"                    ""
-- ========================================================================= --

interface "IQueueLayout" (function(_ENV)
  require "Frame"

  --- Redefine this method in putting your logic to the layout process.
  --- Don't call it directly, use instead "Layout".
  __Abstract__() 
  function OnLayout(self) end

  --- Queue the "OnLayout" method.
  --- This is safe to call it multiple time in short time, resulting only a 
  --- one call.
  function Layout(self)
    if not self.__pendingLayout then 
      self.__pendingLayout = true 

      Scorpio.Delay(0.1, function()
        local aborted = false 

        if self.__cancelLayout then 
          aborted = self.__cancelLayout
        end

        if not aborted then 
          self:OnLayout()
        end

        self.__pendingLayout = nil 
        self.__cancelLayout = nil 
      end)
    end
  end

  --- Cancel the queue 
  --- You probably want to do that when the frame is released. 
  function CancelLayout(self)
    if self.__pendingLayout then 
      self.__cancelLayout = true 
    end
  end
end)

interface "IQueueAdjustHeight" (function(_ENV)
  --- Redefine this method in putting your logic to compute the height frame. 
  --- Don't call it directly, use instead "AdjustHeight" or "ForceAdjustHeight".
  __Abstract__()
  function OnAdjustHeight(self) end 

  --- This function will queue the "OnAdjustHeight" method.
  --- This is safe to call it multiple times in a short time, resulting only a 
  --- one call. 
  function AdjustHeight(self)
    if not self.__pendingAdjustHeight then 
      self.__pendingAdjustHeight = true 

      Scorpio.Delay(0.1, function()
        local aborted = false 

        if self.__cancelAdjustHeight then 
          aborted = self.__cancelAdjustHeight
        end

        if not aborted then 
          self:AdjustHeight()
        end

        self.__pendingAdjustHeight = nil 
        self.__cancelAdjustHeight = nil 
      end)
    end
  end

  --- The function will cancel the current queue, and will call directly the 
  --- "OnAdjustHeight" method.
  function ForceAdjustHeight(self)
    self:CancelAdjustHeight()
    self:OnAdjustHeight()
  end

  --- Cancel the queue. 
  --- You probably want to do that when the frame is released. 
  function CancelAdjustHeight()
    if self.__pendingAdjustHeight then 
      self.__cancelAdjustHeight = true 
    end
  end
end)
