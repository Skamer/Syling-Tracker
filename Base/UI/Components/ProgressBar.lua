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
  function __ctor(self) 
    super(self)

    self.OnSizeChanged = self.OnSizeChanged + OnSizeChanged
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
})