-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.IView"                        ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
Linear = Utils.Math.Linear

_AnimationMethods = {
  ["Linear"] = Linear,
  ["QuadraticEaseIn"] = Utils.Math.QuadraticEaseIn,
  ["QuadraticEaseOut"] = Utils.Math.QuadracticEaseInout,
  ["QuadracticEaseInout"] = Utils.Math.QuadracticEaseInout,
  ["ExponentialEaseIn"] = Utils.Math.ExponentialEaseIn,
  ["ExponentialEaseOut"] = Utils.Math.ExponentialEaseOut,
  ["ExponentialEaseInOut"] = Utils.Math.ExponentialEaseInOut
}


interface "IView" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  -- This is important to not redefine this method, 
  -- use "OnUpdate" for updating your view.
  function UpdateView(self, data, updater)
    self:OnViewUpdate(data, updater)
  end
  
  -- You need redefine its function for handling the stuffs for your views
  -- when updated.
  -- REVIEW: Probably add an content id (e.g, quest, scenario) as arguement ?
  function OnViewUpdate(self, data, updater) end


  --- This is helper function you can use.
  -- Redefine this function in putting your logic to recompute the height frame.
  -- I advise you to not call directly this function, but instead to use "AdjustHeight"
  function OnAdjustHeight(self, useAnimation) end 


  --- This is helper function will call "OnAdjustHeight".
  --- This is safe to call it multiple time in short time, resulting only a one 
  --- call of "OnAdjustHeight"
  function AdjustHeight(self, useAnimation)
    self._useAnimation = useAnimation
    if not self._pendingAdjustHeight then 
      self._pendingAdjustHeight = true 

      Scorpio.Delay(0.1, function() 
        local aborted = false
        if self._cancelAdjustHeight then 
          aborted = self._cancelAdjustHeight 
        end

        if not aborted then 
          self:OnAdjustHeight(self._useAnimation)
        end

        self._pendingAdjustHeight = nil
        self._cancelAdjustHeight = nil
        self._useAnimation = nil
      end)
    end 
  end


  -- __Async__()
  -- function AdjustHeight(self, useAnimation)
  --   self._useAnimation = useAnimation
  --   if self._pendingAjustHeight then 
  --     return 
  --   end
    
  --   self._pendingAdjustHeight = true 

  --   Delay(0.1)

  --   local aborted = false 
  --   if self._cancelAdjustHeight then 
  --     aborted = self._cancelAdjustHeight
  --   end

  --   if not aborted then 
  --     self:OnAdjustHeight(self._useAnimation)
  --   end

  --   self._pendingAdjustHeight = nil
  --   self._cancelAdjustHeight = nil
  --   self._useAnimation = nil
  -- end


  function ForceAdjustHeight(self, useAnimation)
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()
    self:OnAdjustHeight(useAnimation)
  end 

  __Async__() function SetAnimatedHeight(self, height, info)
    -- If it's currently animated, cancel it
    if self.__animatingHeight then
      self.__cancelAnimatingHeight = true
      
      -- We need to wait the next update for avoiding to cancel the new 
      -- animation
      Next()
    end

    local duration = self.AnimationInfo and self.AnimationInfo.duration or 1
    local method = self.AnimationInfo and self.AnimationInfo.method or "Linear"
    local start = GetTime()
    local target = start + duration
    local startHeight = self:GetHeight()
    self.__animatingHeight = true

    if info then 
      if info.duration then 
        duration = info.duration
      end 

      if info.method then 
        method = info.method 
      end 
    end

    local methodFunc = _AnimationMethods[method]
    if not methodFunc then 
      methodFunc = Linear 
    end

    while GetTime() <= target and not self.__cancelAnimatingHeight do 
      local current = GetTime() 
      -- local ratio   = (current - start) / (target - start)
      -- PixelUtil.SetHeight(self, methodFunc(current - start, startHeight, height - startHeight, duration))
      -- self:SetHeight(Round(methodFunc(current - start, startHeight, height - startHeight, duration)))
      PixelUtil.SetHeight(self, methodFunc(current - start, startHeight, height - startHeight, duration))
      Next()
    end

    if not self.__cancelAnimatingHeight then
      self:SetHeight(height)
      -- PixelUtil.SetHeight(self, height)
    end
    
    self.__cancelAnimatingHeight = nil
    self.__animatingHeight = nil
  end

  function CancelAnimatingHeight(self)
    if self.__animatingHeight then 
      self.__cancelAnimatingHeight = true 
    end 
  end 

  

  --- Cancel the "OnAdjustHeight" call if there is one in queue.
  --- You probably do when the obj is releasing.
  function CancelAdjustHeight(self)
    if self._pendingAdjustHeight then 
      self._cancelAdjustHeight = true
    end
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  --- Indicate to view holder, in which order this should be displayed.
  --- NOTE: The holder may ignore this property, and follow its own order system 
  property "Order" {
    type = Number,
    default = 100,
    event = "OnOrderChanged"
  }

  --- The ID of view
  --- REVIEW: Check if this property may have some usefull stuff. 
  property "ID" {
    type = String
  }

  -- The name of view
  --- REVIEW: Same thing as ID
  property "Name" {
    type = String
  }

  --- Indicate to view holder, if this view is active. 
  --- NOTE: The holder is free to not respect  this property, and follow its own
  --- active system 
  property "Active" {
    type = Boolean,
    default = true,
    event = "OnActiveChanged"
  }

  property "AnimationInfo" {
    type = Table
  }
end)