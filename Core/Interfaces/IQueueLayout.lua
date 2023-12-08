-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Core.IQueueLayout"                      ""
-- ========================================================================= --
LAYOUT_TASK_TOKENS         = Toolset.newtable(true)
CANCEL_LAYOUT_TASK_TOKENS  = Toolset.newtable(true)

interface "IQueueLayout" (function(_ENV)
  require "Scorpio.UI.Frame"

  --- Redefine this method in putting your logic to the layout process.
  --- Don't call it directly, use instead "Layout".
  __Abstract__() function OnLayout(self) end 
  
  
  __Async__() function Layout(self)
    -- Update the process token 
    local token = (LAYOUT_TASK_TOKENS[self] or 0) + 1
    LAYOUT_TASK_TOKENS[self] = token

    Next()

    if token ~= LAYOUT_TASK_TOKENS[self] then 
      return 
    end

    if CANCEL_LAYOUT_TASK_TOKENS[self] then 
      return 
    end

    self:OnLayout()

    -- Release the tokens 
    LAYOUT_TASK_TOKENS[self]        = nil 
    CANCEL_LAYOUT_TASK_TOKENS[self] = nil  
  end

  --- Cancel the queue 
  --- You probably want to do that when the frame is released. 
  function CancelLayout(self)
    CANCEL_LAYOUT_TASK_TOKENS[self] = true
  end
end)