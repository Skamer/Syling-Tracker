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
  FromUIProperty = Wow.FromUIProperty,

  GetDecimalCount = SylingTracker.Utils.GetDecimalCount,
  TruncateDecimal = SylingTracker.Utils.TruncateDecimal
}

__Widget__()
class "MinimalSlider"(function(_ENV)
  inherit "Scorpio.UI.Slider"

  SLIDERS_PREVIOUS_VALUE = {}
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  --- As "OnValueChanged" may send value like "0.20000117" while the real value is 0.2
  ---  and be fired multiple times even when there are no change,
  --- "OnSanitizeValueChanged" is here for fixing these issues. 
  event "OnSanitizeValueChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnValueChangedHandler(self, value, ...)
    local shouldRaiseEvent = true 
    local previousValue = SLIDERS_PREVIOUS_VALUE[self]

    -- (e.g, if the user sets the value to "0.2", the value given may be "0.1999999")
    -- so we need to truncate the decimals, and round it. 
    --- the amount of decimal truncated is based on the value step. 
    -- For example:
    -- value step    number of decimal keeped
    --   0.2                 1
    --   0.25                2
    --   0.002               3
    --   0.200               1 
    local decimalCount = self.DecimalCount
    local sanitizeValue = decimalCount > 0 and TruncateDecimal(value, decimalCount, true) or floor(value)
    
    if previousValue ~= nil and previousValue == sanitizeValue then 
      shouldRaiseEvent = false 
    else 
      SLIDERS_PREVIOUS_VALUE[self] = sanitizeValue 
    end
    
    if shouldRaiseEvent then 
      self:OnSanitizeValueChanged(sanitizeValue, ...)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetValueStep(self, step)
    self.DecimalCount = GetDecimalCount(step)

    super.SetValueStep(self, step)
  end

  function GetValue(self)
    local value = super.GetValue(self)
    local decimalCount = self.DecimalCount
    local sanitizeValue = decimalCount > 0 and TruncateDecimal(value, decimalCount, true) or floor(value)
    return sanitizeValue
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "DecimalCount" {
    type = Number,
    default = 0
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    self.OnValueChanged = self.OnValueChanged + OnValueChangedHandler
  end
end)

__Widget__()
class "Slider" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__ { Slider = "OnSanitizeValueChanged"}
  event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnValueChangedHandler(self, value, ...)
    self:FormatText(value)
  end

  local function OnStepperClicked(slider, forward)
    local value = slider:GetValue()
    local step = slider:GetValueStep()
    
    if forward then
      slider:SetValue(value + step, true)
    else
      slider:SetValue(value - step, true)
    end
  end

  local function OnTextBoxTextSetHandler(textBox, ...)
    textBox:SetCursorPosition(0)
  end

  local function OnTextBoxEnterPressed(textBox)
    local slider = textBox:GetParent():GetChild("Slider")
    local value = textBox:GetText()

    slider:SetValue(value, true)
    textBox:ClearFocus()
  end

  local function OnTextBoxEscapePressed(textBox)
    textBox:ClearFocus()
  end

  local function OnTextBoxEditFocusLost(textBox, ...)
    local parent = textBox:GetParent()
    local slider = parent:GetChild("Slider")
    parent:FormatText(slider:GetValue())
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function FormatText(self, value)
    local formatter = self.TextFormatter
    if formatter then 
      value = formatter(value)
    end

    self:GetChild("TextBox"):SetText(tostring(value))
  end

  function SetValue(self, ...) self:GetChild("Slider"):SetValue(...)  end 
  function GetValue(self) return self:GetChild("Slider"):GetValue() end
  function SetMinMaxValues(self, ...) self:GetChild("Slider"):SetMinMaxValues(...) end
  function SetValueStep(self, ...) self:GetChild("Slider"):SetValueStep(...) end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TextFormatter" {
    Type = Function
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Slider  = MinimalSlider,
    Back    = Button,
    Forward = Button,
    TextBox = Scorpio.UI.EditBox,
  }
  function __ctor(self)
    local slider = self:GetChild("Slider")
    local back = self:GetChild("Back")
    local forward = self:GetChild("Forward")
    local textBox = self:GetChild("TextBox")

    -- local slider = self:GetChild("Slider")
    back.OnClick = back.OnClick + function() OnStepperClicked(slider, false) end
    forward.OnClick = forward.OnClick + function() OnStepperClicked(slider, true) end 
    self.OnValueChanged = self.OnValueChanged + OnValueChangedHandler

    textBox:SetNumericFullRange(true) -- full range -> include decimal and negative numbers
    textBox.OnTextSet = textBox.OnTextSet + OnTextBoxTextSetHandler
    textBox.OnEnterPressed = textBox.OnEnterPressed + OnTextBoxEnterPressed
    textBox.OnEscapePressed = textBox.OnEscapePressed + OnTextBoxEscapePressed
    textBox.OnEditFocusLost = textBox.OnEditFocusLost + OnTextBoxEditFocusLost
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [MinimalSlider] = {
    width                             = 200,
    height                            = 8,
    orientation                       = "HORIZONTAL",
    enableMouse                       = true,
    obeyStepOnDrag                    = true,
    backdrop                          = {
                                        bgFile    = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
                                        edgeFile  = [[Interface\Buttons\WHITE8X8]],
                                        edgeSize  = 1   
                                      },
    backdropColor                     = { r = 0.1, g = 0.1, b = 0.1, a = 0.75},
    backdropBorderColor               = { r = 0.45, g = 0.45, b = 0.45, a = 0.75},
    hitRectInsets                     = { top = -4, left = 0, bottom = -4, right = 0 },

    ThumbTexture = {
      color                           = { r = 240/255, g = 181/255, b = 0, a = 0.75},
      width                           = 18,
      height                          = 6,
    }
  },
  
  [Slider] = {
    width                             = 250,
    height                            = 40,

    Slider = {
      location                        = { Anchor("LEFT") }
    },

    Back = {
      size                            = Size(16, 16),
      location                        = { Anchor("RIGHT", -6, 0, "Slider", "LEFT") },

      BackgroundTexture = {
        atlas                         = AtlasType("common-icon-backarrow"),
        drawLayer                     = "BACKGROUND",
        vertexColor                   = Color(0.8, 0.8, 0.8, 1),
        setAllPoints                  = true,
      },
      hitRectInsets                   = { top = -2, left = -2, bottom = -2, right = -2 },
    },

    Forward = {
      size                            = Size(16, 16),
      location                        = { Anchor("LEFT", 6, 0, "Slider", "RIGHT") },

      BackgroundTexture = {
        atlas                         = AtlasType("common-icon-forwardarrow"),
        drawLayer                     = "BACKGROUND",
        vertexColor                   = Color(0.8, 0.8, 0.8, 1),
        setAllPoints                  = true,
      },
      hitRectInsets                   = { top = -2, left = -2, bottom = -2, right = -2 }, 
    },

    TextBox = {
      height                          = 30,
      width                           = 50,
      autoFocus                       = false,
      fontObject                      = GameFontNormal,
      textColor                       = Color.WHITE,
      historyLines                    = 1,
      location                        = { Anchor("LEFT", 25, 0, "Slider", "RIGHT") }
    }
  }
})