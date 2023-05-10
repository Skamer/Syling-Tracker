-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.Frame"                   ""
-- ========================================================================= --
export {
  Linear                = Utils.Linear,
  QuadraticEaseIn       = Utils.QuadraticEaseIn,
  QuadracticEaseOut     = Utils.QuadracticEaseOut,
  QuadraticEaseInOut    = Utils.QuadraticEaseInOut,
  ExponentialEaseIn     = Utils.ExponentialEaseIn,
  ExponentialEaseOut    = Utils.ExponentialEaseOut,
  ExponentialEaseInOut  = Utils.ExponentialEaseInOut
}

ANIMATION_TIMING_FUNCTIONS = {
  ["Linear"]                = Linear,
  ["QuadraticEaseIn"]       = QuadraticEaseIn,
  ["QuadraticEaseOut"]      = QuadracticEaseOut,
  ["QuadracticEaseInout"]   = QuadraticEaseInOut,
  ["ExponentialEaseIn"]     = ExponentialEaseIn,
  ["ExponentialEaseOut"]    = ExponentialEaseOut,
  ["ExponentialEaseInOut"]  = ExponentialEaseInOut 
}

class "Frame" (function(_ENV)
  inherit "Scorpio.UI.Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetHeight(self, height, animate, customAnimationConfig)
    if animate == nil then 
      animate = self.HeightAnimation 
    end

    if animate then 
      self:AnimateToTargetHeight(height, customAnimationConfig)
    else 
      super.SetHeight(self, height)
    end
  end

  function SetWidth(self, width, animate, customAnimationConfig)
    if animate == nil then 
      animate = self.WidthAnimation
    end

    if animate then 
      self:AnimateToTargetWidth(width, customAnimationConfig)
    else 
      super.SetWidth(self, width)
    end
  end

  __Async__()
  function AnimateToTargetHeight(self, height, customAnimationConfig)
    -- If it's currently animated, cancel it 
    if self.__animatingHeight then 
      self.__cancelHeightAnimation = true 

      -- We need to wait the next update for avoiding to cancel the new
      -- animation 
      Next()
    end

    local duration = customAnimationConfig and customAnimationConfig.duration or self.AnimationDuration
    local timingFunc = customAnimationConfig and customAnimationConfig.timingFunction or self.AnimationTimingFunction
    local start = GetTime()
    local target = start + duration
    local startHeight = self:GetHeight()
    self.__animatingHeight = true 

    if type(timingFunc) == "string" then 
      if ANIMATION_TIMING_FUNCTIONS[timingFunc] then 
        timingFunc = ANIMATION_TIMING_FUNCTIONS[timingFunc]
      else 
        -- @TODO: Get the function if it's function string 
      end
    end

    while GetTime() <= target and not self.__cancelHeightAnimation do 
      local current = GetTime()
      
      -- IMPORTANT: We must say explicitely to not animate the height here for avoiding 
      -- infinite loop
      self:SetHeight(timingFunc(current - start, startHeight, height - startHeight, duration), false)

      Next()
    end

    if not self.__cancelHeightAnimation then
      self:SetHeight(height, false)
    end

    self.__cancelHeightAnimation = nil 
    self.__animatingHeight = nil 
  end

  function CancelAnimatingHeight(self)
    if self.__animatingHeight then 
      self.__cancelHeightAnimation = true 
    end
  end

  __Async__()
  function AnimateToTargetWidth(self, width, animationInfo)
    -- If it's currently animated, cancel it 
    if self.__animatingWidth then 
      self.__cancelWidthAnimation = true 

      -- We need to wait the next update for avoiding to cancel the new
      -- animation 
      Next()
    end

    local duration = customAnimationConfig and customAnimationConfig.duration or self.AnimationDuration
    local timingFunc = customAnimationConfig and customAnimationConfig.timingFunction or self.AnimationTimingFunction
    local start = GetTime()
    local target = start + duration
    local startWidth = self:GetWidth()
    self.__animatingWidth = true 

    if type(timingFunc) == "string" then 
      if ANIMATION_TIMING_FUNCTIONS[timingFunc] then 
        timingFunc = ANIMATION_TIMING_FUNCTIONS[timingFunc]
      else 
        -- @TODO: Get the function if it's a function string 
      end
    end

    while GetTime() <= target and not self.__cancelWidthAnimation do 
      local current = GetTime()
      
      -- IMPORTANT: We must say explicitely to not animate the width here for avoiding 
      -- infinite loop
      self:SetWidth(timingFunc(current - start, startWidth, width - startWidth, duration), false)

      Next()
    end

    if not self.__cancelWidthAnimation then
      self:SetWidth(width, false)
    end

    self.__cancelWidthAnimation = nil 
    self.__animatingWidth = nil 
  end

  function CancelAnimatingWidth(self)
    if self.__animatingWidth then 
      self.__cancelWidthAnimation = true 
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  --- say whether the frame must do an animation when the height is changed.
  property "HeightAnimation" {
    type = Boolean,
    default = false 
  }

   --- say whether the frame must do an animation when the width is changed.
  property "WidthAnimation" {
    type = Boolean,
    default = false 
  }

  --- the animation duration. 
  property "AnimationDuration" {
    type = Number,
    default = 1
  }

  --- the animation timing function 
  property "AnimationTimingFunction" {
    type = String + Callable,
    default = Linear,
    field = "__animationTimingFunction",
    set = function(self, value)
      if value and type(valie) == "string" then 
        value = ANIMATION_METHODS[value]
      end

      self.__animationTimingFunction = value 
    end,
    get = function(self) return self.__animationTimingFunction end 
  }
end)