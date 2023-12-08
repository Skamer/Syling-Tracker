-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Core.ISizeAnimation"                    ""
-- ========================================================================= --
export {
  FromUISetting         = API.FromUISetting,
  Linear                = Utils.Linear,
  QuadraticEaseIn       = Utils.QuadraticEaseIn,
  QuadracticEaseOut     = Utils.QuadracticEaseOut,
}

ANIMATION_TIMING_FUNCTIONS = {
  ["Linear"]                = Linear,
  ["QuadraticEaseIn"]       = QuadraticEaseIn,
  ["QuadraticEaseOut"]      = QuadracticEaseOut,
}

ANIMATE_HEIGHT_TASK_TOKENS        = Toolset.newtable(true)
CANCEL_ANIMATE_HEIGHT_TASK_TOKENS = Toolset.newtable(true)

interface "ISizeAnimation" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Async__()
  __Arguments__ { Number, Any/nil}
  function AnimateToTargetHeight(self, height, customAnimationConfig)
    -- Update the tokens
    local token = (ANIMATE_HEIGHT_TASK_TOKENS[self] or 0) + 1
    ANIMATE_HEIGHT_TASK_TOKENS[self] = token

    local duration    = customAnimationConfig and customAnimationConfig.duration or self.AnimationDuration
    local timingFunc  = customAnimationConfig and customAnimationConfig.timingFunction or self.AnimationTimingFunction

    if type(timingFunc) == "string" then 
      if ANIMATION_TIMING_FUNCTIONS[timingFunc] then 
        timingFunc = ANIMATION_TIMING_FUNCTIONS[timingFunc]
      else 
        -- @TODO: Get the function if it's function string 
      end
    end

    local startTime   = GetTime()
    local endTime     = startTime + duration
    local startHeight = self:GetHeight(true) -- Important: We need to get the explicit height for avoiding errors.
    local progress    = 0

    
    while GetTime() < endTime and token == ANIMATE_HEIGHT_TASK_TOKENS[self] and not CANCEL_ANIMATE_HEIGHT_TASK_TOKENS[self] do 
      local currentTime = GetTime() - startTime
      progress = math.max(0, math.min(1, currentTime / duration))
      
      if token == ANIMATE_HEIGHT_TASK_TOKENS[self] then 
        self:SetHeight(timingFunc(startHeight, height, progress))
      end
      
      Next()
    end

    if token ~= ANIMATE_HEIGHT_TASK_TOKENS[self] then 
      return 
    end
    
    if not CANCEL_ANIMATE_HEIGHT_TASK_TOKENS[self] then
      self:SetHeight(height)
    end

    -- Release the tokens
    CANCEL_ANIMATE_HEIGHT_TASK_TOKENS[self] = nil 
    ANIMATE_HEIGHT_TASK_TOKENS[self]        = nil
  end

  function CancelAnimatingHeight(self)
    CANCEL_ANIMATE_HEIGHT_TASK_TOKENS[self] = true
  end

  ANIMATE_WIDTH_TASK_TOKENS        = Toolset.newtable(true)
  CANCEL_ANIMATE_WIDTH_TASK_TOKENS = Toolset.newtable(true)

  __Async__()
  function AnimateToTargetWidth(self, width, customAnimationConfig)
    -- Update the tokens
    local token = (ANIMATE_WIDTH_TASK_TOKENS[self] or 0) + 1
    ANIMATE_WIDTH_TASK_TOKENS[self] = token

    local duration    = customAnimationConfig and customAnimationConfig.duration or self.AnimationDuration
    local timingFunc  = customAnimationConfig and customAnimationConfig.timingFunction or self.AnimationTimingFunction

    if type(timingFunc) == "string" then 
      if ANIMATION_TIMING_FUNCTIONS[timingFunc] then 
        timingFunc = ANIMATION_TIMING_FUNCTIONS[timingFunc]
      else 
        -- @TODO: Get the function if it's function string 
      end
    end

    local startTime   = GetTime()
    local endTime     = startTime + duration
    local startWidth  = self:GetWidth(true) -- Important: We need to get the explicit width for avoiding errors.
    local progress    = 0

    while GetTime() < endTime and token == ANIMATE_WIDTH_TASK_TOKENS[self] and not CANCEL_ANIMATE_WIDTH_TASK_TOKENS[self] do 
      local currentTime = GetTime() - startTime
      progress = math.max(0, math.min(1, currentTime / duration))
      
      self:SetWidth(timingFunc(startWidth, width, progress))

      Next()
    end

    if token ~= ANIMATE_WIDTH_TASK_TOKENS[self] then 
      return 
    end

    if not CANCEL_ANIMATE_WIDTH_TASK_TOKENS[self] then 
      self:SetWidth(width)
    end

    -- Release the tokens
    CANCEL_ANIMATE_WIDTH_TASK_TOKENS[self]  = nil 
    ANIMATE_WIDTH_TASK_TOKENS[self]         = nil
  end

  function CancelAnimatingWidth(self)
    CANCEL_ANIMATE_WIDTH_TASK_TOKENS[self] = nil
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
    default = QuadracticEaseOut,
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
