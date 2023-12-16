-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.Slider"                   ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --

export {
  FromUIProperty  = Wow.FromUIProperty,

  GetDecimalCount = SylingTracker.Utils.GetDecimalCount,
  TruncateDecimal = SylingTracker.Utils.TruncateDecimal
}

local BLZ_MINIMAL_SLIDER_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_MinimalSliderBar]]

__Widget__()
class "MinimalSlider"  { Slider }


__Widget__()
class "Slider" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  --- NOTE: This is not the original "OnValueChanged" of slider, but an event build
  --- around of it. The reason is the original may give the value 0.199999 if the 
  --- user sets to 0.2 for example. This may also cause the event to be triggered 
  --- multiple time.

  --- The build event will fix these issues where the real value is given, and triggered 
  --- only when it has changed.
  event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                              Enumerations                               --
  -----------------------------------------------------------------------------
  enum "Label" {
    Left    = "LeftText",
    Right   = "RightText",
    Top     = "TopText",
    Min     = "MinText",
    Max     = "MaxText"
  }
  -----------------------------------------------------------------------------
  --                          Helper functions                               --
  -----------------------------------------------------------------------------
  local function NoModification(value)
	  return value
  end
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------

  local function OnSliderValueChanged(self, new)
    --- (e.g, if the user sets the value to "0.2", the value given may be "0.1999999")
    --- so we need to truncate the decimals, and round it. 
    --- the amount of decimal truncated is based on the value step. 
    --- For example:
    --- value step    number of decimal keeped
    ---   0.2                 1
    ---   0.25                2
    ---   0.002               3
    ---   0.200               1 
    local valueRounded = TruncateDecimal(new, self.DecimalCount, true)

    self.Value = valueRounded
  end
  
  local function OnValueChangedHandler(self, new)
    self:GetChild("Slider"):SetValue(new, false)
    self:FormatValue(new)
    self:OnValueChanged(new)
  end

  local function OnValueStepChangedHandler(self, new)
    self.DecimalCount = GetDecimalCount(new)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------

  __Arguments__ { Label, Any/nil }
  function SetLabelFormatter(self, labelType, value)
    if not self.formatters then 
      self.formatters = {}
    end

    local formatter = nil 
    if value == nil then
      formatter = NoModification
    elseif type(value) == "function" then 
      formatter = value
    else 
      formatter = function(v)
        return value 
      end
    end

    self.formatters[labelType] = formatter
  end

  function FormatValue(self, value)
    if not self.formatters then 
      return 
    end

    for labelName, formatter in pairs(self.formatters) do 
      local label = self:GetChild(labelName)
      label:SetText(formatter(value))
      Style[label].visible = true
    end 
  end

  __Arguments__ { Number }
  function SetValue(self, value)
    --- (e.g, if the user sets the value to "0.2", the value given may be "0.1999999")
    --- so we need to truncate the decimals, and round it. 
    --- the amount of decimal truncated is based on the value step. 
    --- For example:
    --- value step    number of decimal keeped
    ---   0.2                 1
    ---   0.25                2
    ---   0.002               3
    ---   0.200               1 
    local valueRounded = TruncateDecimal(value, self.DecimalCount, true)

    self.Value = valueRounded
  end

  function GetValue(self)
    return self.Value
  end

  __Arguments__ {  MinMax }
  function SetMinMaxValues(self, minMaxValues)
    self.MinMaxValues = minMaxValues
  end

  __Arguments__ { Number  }
  function SetValueStep(self, valueStep)
    self.ValueStep = valueStep
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    -- Reset the properties 
    self.Value = nil
    self.MinMaxValues = nil
    self.ValueStep = nil
    self.DecimalCount = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Value" {
    type = Number,
    default = 0,
    handler = OnValueChangedHandler
  }


  __Observable__()
  property "MinMaxValues" {
    type = MinMax,
    default = MinMax(0, 100),
  }

  __Observable__()
  property "ValueStep" {
    type    = Number,
    default = 1,
    handler = OnValueStepChangedHandler
  }

  property "DecimalCount" {
    type    = Number,
    default = 0
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Slider = MinimalSlider,
    Back = Button,
    Forward = Button,
    LeftText = FontString,
    RightText = FontString,
    TopText = FontString,
    MinText = FontString,
    MaxText = FontString
  }
  function __ctor(self) 
    local slider = self:GetChild("Slider")
    local back = self:GetChild("Back")
    local forward = self:GetChild("Forward")

    local function OnStepperClicked(forward)
      local value = slider:GetValue()
      local step = slider:GetValueStep()
      if forward then
        slider:SetValue(value + step)
      else
        slider:SetValue(value - step)
	    end
    end

    back.OnClick = back.OnClick + function() OnStepperClicked(false) end 
    forward.OnClick = forward.OnClick + function() OnStepperClicked(true) end

    self.OnSliderValueChanged = function(slider, value) 
      OnSliderValueChanged(self, value)
    end

    slider.OnValueChanged = slider.OnValueChanged + self.OnSliderValueChanged
  end 
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [MinimalSlider] = {
    width = 200,
    height = 10,
    orientation = "HORIZONTAL",
    enableMouse = true,
    obeyStepOnDrag = true,


    LeftBGTexture = {
      --- Minimal_SliderBar_Left, true
      file = BLZ_MINIMAL_SLIDER_FILE,
      width = 11,
      height = 17,
      texCoords = { left = 0.4375, right = 0.78125, top = 0.3203125, bottom = 0.453125},
      location = {
        Anchor("LEFT")
      }
    },
    RightBGTexture = {
      --- Minimal_SliderBar_Right, true
      file = BLZ_MINIMAL_SLIDER_FILE,
      width = 11,
      height = 17,
      texCoords = { left = 0.03125, right = 0.375, top = 0.484375, bottom = 0.6171875},
      location = {
        Anchor("RIGHT")
      }
    },
    MiddleBGTexture = {
      ---_Minimal_SliderBar_Middle, true
      file = BLZ_MINIMAL_SLIDER_FILE,
      height = 17,
      texCoords = { left = 0, right = 0.03125, top = 0.0078125, bottom = 0.140625},
      horizTile = true,
      location = {
        Anchor("LEFT", 0, 0, "LeftBGTexture", "RIGHT"),
        Anchor("RIGHT", 0, 0, "RightBGTexture", "LEFT")
      }
    },

    ThumbTexture = {
      --- Minimal_SliderBar_Button, true
      file = BLZ_MINIMAL_SLIDER_FILE,
      width = 20,
      height = 19,
      texCoords = { left = 0.03125, right = 0.65625, top = 0.15625, bottom = 0.3046875},      
    }
  },

  [Slider] = {
    width   = 250,
    height  = 40,

    Slider = {
      minMaxValues = FromUIProperty("MinMaxValues"),
      valueStep = FromUIProperty("ValueStep"),


      location = {
        Anchor("TOPLEFT", 19, 0),
        Anchor("BOTTOMRIGHT", -19, 0)
      }
    },

    Back = {
      size = Size(11, 19),
      location = {
        Anchor("RIGHT", -4, 0, "Slider", "LEFT")
      },

      BackgroundTexture = {
        --- Minimal_SliderBar_Button_Left, true
        file = BLZ_MINIMAL_SLIDER_FILE,
        width = 11,
        height = 19,
        texCoords = { left = 0.03125, right = 0.375, top = 0.3203125, bottom = 0.46875},   
        drawLayer = "BACKGROUND",
        setAllPoints = true
      }
    },

    Forward = {
      size = Size(9, 18),
      location = {
        Anchor("LEFT", 4, 0, "Slider", "RIGHT")
      },

      BackgroundTexture = {
        --- Minimal_SliderBar_Button_Right, true
        file = BLZ_MINIMAL_SLIDER_FILE,
        width = 9,
        height = 18,
        texCoords = { left = 0.03125, right = 0.3125, top = 0.6328125, bottom = 0.7734375},   
        drawLayer = "BACKGROUND",
        setAllPoints = true
      }
    },

    LeftText = {
      visible = false,
      fontObject = GameFontNormal,
      drawLayer = "OVERLAY",
      location = {
        Anchor("RIGHT", -25, 0, "Slider", "LEFT")
      }
    },
    RightText = {
      visible = false,
      fontObject = GameFontNormal,
      drawLayer = "OVERLAY",
      location = {
        Anchor("LEFT", 25, 0, "Slider", "RIGHT")
      }
    },
    TopText = {
      visible = false,
      fontObject = GameFontNormal,
      drawLayer = "OVERLAY",
      location = {
        Anchor("BOTTOM", 0, -9, "Slider", "TOP")
      }
    },
    MinText = {
      visible = false,
      fontObject = GameFontNormal,
      drawLayer = "OVERLAY",
      location = {
        Anchor("TOP", 0, 6, "Slider", "BOTTOMLEFT")
      }
    },
    MaxText = {
      visible = false,
      fontObject = GameFontNormal,
      drawLayer = "OVERLAY",
      location = {
        Anchor("TOP", 0, 6, "Slider", "BOTTOMRIGHT")
      }
    }
  }
})