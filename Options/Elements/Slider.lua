-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling            "SylingTracker_Options.Elements.Slider"                    ""
-- ========================================================================= --
__Widget__()
class "SUI.MinimalSlider"  { Slider }


__Widget__()
class "SUI.Slider" (function(_ENV)
  inherit "Frame"

  event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                              Enumerations                               --
  -----------------------------------------------------------------------------
  enum "Label" {
    Left = "LeftText",
    Right = "RightText",
    Top = "TopText",
    Min = "MinText",
    Max = "MaxText"
  }
  -----------------------------------------------------------------------------
  --                          Helper functions                               --
  -----------------------------------------------------------------------------
  local function NoModification(value)
	  return value;
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

  function SetValue(self, value)
    self:GetChild("Slider"):SetValue(value)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "MinMaxValues" {
    type = MinMax,
    handler = function(self, val) Style[self].Slider.minMaxValues = val end 
  }

  property "ValueStep" {
    type = Number,
    handler = function(self, val) Style[self].Slider.valueStep = val end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Slider = SUI.MinimalSlider,
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


    slider.OnValueChanged = slider.OnValueChanged + function(_, value)
      self:FormatValue(value)

      self:OnValueChanged(value)
    end

    self:InstantApplyStyle()
  end 
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.MinimalSlider] = {
    size = Size(200, 10),
    orientation = "HORIZONTAL",
    enableMouse = true,
    obeyStepOnDrag = true,


    LeftBGTexture = {
      atlas = AtlasType("Minimal_SliderBar_Left", true),
      location = {
        Anchor("LEFT")
      }
    },
    RightBGTexture = {
      atlas = AtlasType("Minimal_SliderBar_Right", true),
      location = {
        Anchor("RIGHT")
      }
    },
    MiddleBGTexture = {
      atlas = AtlasType("_Minimal_SliderBar_Middle", true),
      location = {
        Anchor("LEFT", 0, 0, "LeftBGTexture", "RIGHT"),
        Anchor("RIGHT", 0, 0, "RightBGTexture", "LEFT")
      }
    },

    ThumbTexture = {
      atlas = AtlasType("Minimal_SliderBar_Button", true)
    }
  },

  [SUI.Slider] = {
    size = Size(250, 40),
    minMaxValues = MinMax(10, 250),
    valueStep = 10,

    Slider = {
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
        atlas = AtlasType("Minimal_SliderBar_Button_Left", true),
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
        atlas = AtlasType("Minimal_SliderBar_Button_Right", true),
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

function OnLoad(self)
  local widget = SUI.Slider("SUISLider", UIParent)
  widget:SetPoint("CENTER", 0, -200)
  widget:SetLabelFormatter(SUI.Slider.Label.Right, FormatTest)
  widget:SetValue(25)
  widget:SetValue(50)

end