-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.UI.ProgressBar"                    ""
-- ========================================================================= --
__UIElement__()
class "ProgressBar" (function(_ENV)
  inherit "StatusBar"
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ { 
    Text = FontString
  }
  __InstantApplyStyle__()
  function __ctor(self) end
end)

__UIElement__()
class "ProgressWithExtraBar"(function(_ENV)
  inherit "ProgressBar"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnSizeChanged(self)
    self:UpdateExtraBar()
  end

  local function OnExtraValueChanged(self, new)
    self:UpdateExtraBar()
  end
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function UpdateExtraBar(self)
    local extraBarTexture = self:GetChild("ExtraBarTexture")

    -- Seems like a early call 'SetMinMaxValue' trigger it, and the extraBarTexture
    -- is not yet build, so we have to check it before to continue.
    if not extraBarTexture then 
      return 
    end

    local extraValue = self:GetExtraValue()
    local value = self:GetValue()
    local minValue, maxValue = self:GetMinMaxValues()

    -- we do the update if all these criteria are matched
    -- 1. extraValue is not nil 
    -- 2. extraValue is between min and max
    -- 3. extraValue is above as value
    if extraValue and (extraValue > value) and (extraValue >= minValue and extraValue <= maxValue) then 
      local maxWidth = math.floor(self:GetWidth() + 0.5)
      value = Clamp(value, minValue, maxValue)

      extraBarTexture:SetWidth(Lerp(0, maxWidth, ((extraValue - minValue) - (value - minValue)) / (maxValue - minValue)))
      extraBarTexture:SetPoint("LEFT", math.floor(Lerp(0, maxWidth, (value - minValue) / (maxValue - minValue)) + 0.5), 0)
      extraBarTexture:SetPoint("TOP")
      extraBarTexture:SetPoint("BOTTOM")
      extraBarTexture:Show()
    else 
      extraBarTexture:Hide()
    end
  end


  function SetExtraValue(self, value)
    self.ExtraValue = value
  end

  function GetExtraValue(self)
    return self.ExtraValue
  end

  function SetMinMaxValues(self, min, max)
    super.SetMinMaxValues(self, min, max)

    self:UpdateExtraBar()
  end

  function SetValue(self, value)
    super.SetValue(self, value)

    self:UpdateExtraBar()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "ExtraValue" {
    type    = Number,
    handler = OnExtraValueChanged
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    ExtraBarTexture = Texture
  }
  __InstantApplyStyle__()
  function __ctor(self) 
    super(self)

    self.OnSizeChanged = self.OnSizeChanged + OnSizeChanged
  end
end)

class "ProgressWithSegments"(function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Helpers                                   --
  -----------------------------------------------------------------------------
  local function reduceSegment(self, index)
    index = index or self.SegmentCount

    if index < #self then
      for i = self.__ElementCount, index + 1, -1 do 
        local segment = self[i]

        segment:ClearAllPoints()
        segment:Hide()

        self.__ElementCount = i - 1
      end
    end
  end

  local function acquireSegment(self, index)
    local segment = self[index] 

    if not segment then 
      segment = StatusBar("Segment"..index, self)
      segment:InstantApplyStyle()
      
      self[index] = segment
    end

    segment:Show()

    self.__ElementCount = index

    return segment
  end
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function onSizeChanged(self)
    self:Refresh()
  end
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  __AsyncSingle__()
  function Refresh(self)
    Next()

    reduceSegment(self)

    if self.SegmentCount > 0 then
      local previousSegment 
      local minValue, maxValue = self.MinMaxValues.min, self.MinMaxValues.max 
      local totalWidth = math.floor(self:GetWidth() + 0.5) - self.Spacing * (self.SegmentCount - 1) - self.PaddingLeft - self.PaddingRight
      local currentValue = Clamp(self.Value, minValue, maxValue)

      for i = 1, self.SegmentCount do 
        local segment = acquireSegment(self, i)
        local segmentMinValue = (i == 1) and minValue or self.Breakpoints[i - 1]
        local segmentMaxValue = (i == self.SegmentCount) and maxValue or self.Breakpoints[i]
        segment:SetValue(currentValue)
        segment:SetMinMaxValues(segmentMinValue, segmentMaxValue)

        local width = Lerp(0, totalWidth, (segmentMaxValue - segmentMinValue) / (maxValue - minValue))
        segment:SetWidth(width)
        
        if i == 1 then
          segment:SetPoint("LEFT")
        else 
          segment:SetPoint("LEFT", previousSegment, "RIGHT", self.Spacing, 0)
        end

        segment:SetPoint("TOP", 0, -self.PaddingTop)
        segment:SetPoint("BOTTOM", 0, self.PaddingBottom)

        local color = self.SegmentColors[i] or Color.WHITE 
        segment:SetStatusBarColor(color.r, color.g, color.b, color.a)

        previousSegment = segment      
      end 
    end
  end

  __Arguments__{ Number }
  function SetValue(self, value)
    self.Value = value
  end

  function GetValue(self, value)
    return self.Value
  end

  __Arguments__ { Number, Number}
  function SetMinMaxValues(self, min, max)
    self.MinMaxValues = MinMax(min, max)
  end

  function GetMinMaxValues(self)
    return self.MinMaxValues.min, self.MinMaxValues.max
  end

  function SetBreakpoint(self, index, value)
    self.Breakpoints[index] = value
  end

  function ClearBreakpoints(self)
    wipe(self.__Breakpoints)

    Refresh(self)
  end

  function AddBreakpoint(self, value)
    self.Breakpoints[self.BreakpointCount + 1] = value
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SegmentCount" {
    type = Number,
    set = false,
    get = function(self)
      return #self.__Breakpoints + 1
    end
  }

  property "MinMaxValues" { 
    type = MinMax, 
    default = MinMax(0, 100), 
    handler = Refresh 
  }

  property "Value" {
    type = Number,
    default = 0,
    handler = Refresh
  }

  property "Spacing" {
    type = Number,
    default = 0,
    handler = Refresh
  }

  property "PaddingTop" { 
    type = Number, 
    default = 1, 
    handler = Refresh 
  }

  property "PaddingBottom" { 
    type = Number, 
    default = 1, 
    handler = Refresh 
  }

  property "PaddingLeft" { 
    type = Number, 
    default = 0, 
    handler = Refresh 
  }

  property "PaddingRight" { 
    type = Number, 
    default = 0, 
    handler = Refresh
  }

  property "BreakpointCount" {
    type = Number,
    get = function(self) return #self.__Breakpoints end
  }

  __Indexer__(Number)
  property "Breakpoints" {
    type = Number,
    set = function(self, index, value)
      local old = self.__Breakpoints[index] 
      self.__Breakpoints[index] = value

      if old ~= value then 
        Refresh(self)
      end
    end,
    get = function(self, index) return self.__Breakpoints[index] end,
  }

  __Indexer__(Number)
  property "SegmentColors" {
    type = Color,
    set = function(self, index, value)
      local old = self.__SegmentColors[index]
      self.__SegmentColors[index] = value 

      if old ~= value then 
        Refresh(self)
      end
    end,
    get = function(self, index) return self.__SegmentColors[index] end
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  function __new(...)
    local self = super.__new(...)

    self.__Breakpoints = {}
    self.__SegmentColors = {}

    return self
  end

  __Template__ {
    FText = Frame,
    {
      FText = {
        Text = FontString
      }
    }
  }
  __InstantApplyStyle__()
  function __ctor(self)
    self.OnSizeChanged = self.OnSizeChanged + onSizeChanged
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ProgressBar] = {
    height = 20,
    minMaxValues = MinMax(0, 100),
    clipChildren = true,
    
    backdrop = { 
      bgFile              = [[Interface\Buttons\WHITE8X8]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1
    },
    backdropColor         = { r = 0, g = 0, b = 0, a = 0.5},
    backdropBorderColor   = { r = 0, g = 0, b = 0, a = 1 },
    
    StatusBarTexture = {
      file                = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      drawLayer           = "BACKGROUND",
      subLevel            = 1,
      snapToPixelGrid     = false,
      texelSnappingBias    = 0,
    },
    statusBarColor        = { r = 0, g = 148/255, b = 1, a = 0.9 },

    Text = {
      setAllPoints        = true,
      mediaFont           = FontType("PT Sans Bold Italic", 12),
      textColor           = Color.WHITE,
      justifyH            = "CENTER",
      justifyV            = "MIDDLE",
    }
  },

  [ProgressWithExtraBar] = {
    ExtraBarTexture = {
      file                = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      drawLayer           = "BACKGROUND",
      subLevel            = 2,
      snapToPixelGrid     = false,
      texelSnappingBias   = 0,
      vertexColor         = { r = 0, g = 148/255, b = 1, a = 0.6},
    }
  },

  [ProgressWithSegments] = {
    width = 250,
    height = 20,
    clipChildren = true,

    backdrop = { 
      bgFile              = [[Interface\Buttons\WHITE8X8]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1
    },
    
    backdropColor         = { r = 0, g = 0, b = 0, a = 0.5},
    backdropBorderColor   = { r = 0, g = 0, b = 0, a = 1 },

    FText = {
      setAllPoints          = true,
      frameStrata           = "HIGH",

      Text = {
        setAllPoints        = true,
        mediaFont           = FontType("PT Sans Bold Italic", 12),
        textColor           = Color.WHITE,
        justifyH            = "CENTER",
        justifyV            = "MIDDLE",
      },
    },

    [StatusBar] = {
      StatusBarTexture = {
        file                = [[Interface\Buttons\WHITE8X8]],
        drawLayer           = "BACKGROUND",
        subLevel            = -1,
        snapToPixelGrid     = false,
        texelSnappingBias    = 0,
      },
    }
  },
})