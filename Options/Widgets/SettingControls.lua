-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.SettingControls"          ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --

export {
  ResetStyles       = SylingTracker.Utils.ResetStyles,
  TruncateDecimal   = SylingTracker.Utils.TruncateDecimal,
  GetSetting        = SylingTracker.API.GetSetting,
  SetSetting        = SylingTracker.API.SetSetting,
  GetUISetting      = SylingTracker.API.GetUISetting,
  SetUISetting      = SylingTracker.API.SetUISetting,
}

__Widget__() 
class "SettingsText" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__{ String/"" }
  function SetText(self, text)
    Style[self].Text.text = text 
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    ResetStyles(self, true)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Text = FontString
  }
  function __ctor(self) end 

end)

__Widget__()
class "SettingsEditBox" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/"" }
  function SetLabel(self, label)
    Style[self].Label.text = label 
  end

  function SetInstructions(self, instructions)
    self:GetChild("EditBox"):SetInstructions(instructions)
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function GetValue(self)
    return self:GetChild("EditBox"):GetText()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    ResetStyles(self, true)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label = FontString,
    EditBox = EditBox
  }
  function __ctor(self) end
end)

__Widget__()
class "SettingsCheckBox" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__{ CheckBox = "OnClick"}
  event "OnCheckBoxClick"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnCheckBoxClickHandler(self, checkbox)
    if self.Setting then 
      local value = self:IsChecked()
      if self.InvertSetting then  
        SetSetting(self.Setting, not value)
      else 
        SetSetting(self.Setting, value)
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/"" }
  function SetLabel(self, label)
    Style[self].Label.text = label 
  end

  __Arguments__ { Boolean/nil }
  function SetChecked(self, checked)
    Style[self].CheckBox.checked = checked
  end

  function IsChecked(self)
    return self:GetChild("CheckBox"):GetChecked()
  end

  __Arguments__ { String, Boolean/false }
  function BindSetting(self, settingId, invert)
      local value = GetSetting(settingId)

      if value ~= nil then 
        
        if invert then 
          self:SetChecked(not value)
        else 
          self:SetChecked(value )
        end

        self.Setting = settingId
      end

      self.InvertSetting = invert
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    for name, v in Style.GetCustomStyles(self) do 
      Style[self][name] = CLEAR
    end

    ResetStyles(self, true)

    self.Setting = nil 
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Setting" {
    type = String
  }

  property "InvertSetting" {
    type = Boolean,
    default = false
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label     = FontString,
    CheckBox  = CheckBox
  }
  function __ctor(self) 
    self.OnCheckBoxClickHandler = function() OnCheckBoxClickHandler(self) end

    self.OnCheckBoxClick = self.OnCheckBoxClick + self.OnCheckBoxClickHandler
  end 
end)

__Widget__()
class "SettingsDropDown" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__{ DropDown = "OnEntrySelected"}
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/"" }
  function SetLabel(self, label)
    Style[self].Label.text = label 
  end

  __Arguments__ { EntryData}
  function AddEntry(self, entry)
    self:GetChild("DropDown"):AddEntry(entry)
  end

  __Arguments__ { Array[EntryData] }
  function SetEntries(self, entries)
    self:GetChild("DropDown"):SetEntries(entries)
  end

  __Arguments__ { Any }
  function SelectByValue(self, value)
    self:GetChild("DropDown"):SelectByValue(value)
  end

  __Arguments__ { String + Number}
  function SelectById(self, id)
    self:GetChild("DropDown"):SelectById(value)
  end

  function SetMediaType(self, mediaType)
    self:GetChild("DropDown"):SetMediaType(mediaType)
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    self:GetChild("DropDown"):ClearEntries()

    ResetStyles(self, true)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label     = FontString,
    DropDown  = DropDown
  }
  function __ctor(self) end 
end)

__Widget__()
class "SettingsSlider" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__{ Slider = "OnValueChanged"}
  event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnValueChangedHandler(self, value)
    if self.Setting then 
      SLT.Settings.Set(self.Setting, value)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/"" }
  function SetLabel(self, label)
    Style[self].Label.text = label 
  end

  __Arguments__ { Number, Number }
  function SetMinMaxValues(self, min, max)
    self:GetChild("Slider"):SetMinMaxValues(MinMax(min, max))
  end

  __Arguments__ { Number }
  function SetValueStep(self, valueStep)
    self:GetChild("Slider"):SetValueStep(valueStep)
  end

  __Arguments__ { Number }
  function SetValue(self, value)
    self:GetChild("Slider"):SetValue(value)
  end

  __Arguments__ { Slider.Label, Any/nil }
  function SetSliderLabelFormatter(self, labelType, value)
    self:GetChild("Slider"):SetLabelFormatter(labelType, value)
  end

    __Arguments__ { String }
  function BindSetting(self, settingId)
      local value = GetSetting(settingId)

      if value ~= nil then 
        self:SetValue(value)

        self.Setting = settingId
      end
  end 

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    ResetStyles(self, true)

    self.Setting = nil
    --- It's important these functions are called after Setting has been set 
    --- to nil for avoiding the setting vlaue is updated by an incorrect value
    self:SetValue(0)
    self:SetValueStep(1)
    self:SetMinMaxValues(0, 100)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Setting" {
    type = String
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label   = FontString,
    Slider  = Slider
  }
  function __ctor(self)
    self.OnValueChanged = self.OnValueChanged + OnValueChangedHandler 
  end
end)

__Widget__()
class "SettingsColorPicker" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__ { ColorPicker = "OnColorChanged"}
  event "OnColorChanged"

  __Bubbling__ { ColorPicker = "OnColorConfirmed"}
  event "OnColorConfirmed"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/"" }
  function SetLabel(self, label)
    Style[self].Label.text = label 
  end

  __Arguments__ { ColorFloat/nil, ColorFloat/nil, ColorFloat/nil, ColorFloat/nil}
  function SetColor(self, r, g, b, a)
    self:GetChild("ColorPicker"):SetColor(r, g, b, a)
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    ResetStyles(self, true)


    self:SetColor()
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label = FontString,
    ColorPicker = ColorPicker
  }
  function __ctor(self) 
  end
end)

__Widget__()
class "SettingsMediaFont" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnFontChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnFontSettingSelected(self, dropdown, entry)
    if self.Font then 
      local font = entry:GetEntryData().value

      OnFontChanged(self, FontType(
        font, 
        self.Font.height,
        self.Font.outline, 
        self.Font.monochrome
      ))
    end
  end

  local function OnFontHeightSettingChanged(self, slider, value)
    if self.Font then 
      OnFontChanged(self, FontType(
        self.Font.font, 
        value,
        self.Font.outline, 
        self.Font.monochrome
      ))
    end
  end

  local function OnFontOutlineSettingChanged(self, dropdown, entry)
    if self.Font then 
      local fontOuline = entry:GetEntryData().value

      OnFontChanged(self, FontType(
        self.Font.font, 
        self.Font.height,
        fontOuline, 
        self.Font.monochrome
      ))
    end
  end

  local function OnFontMonochromeSettingClick(self, checkbox)
    if self.Font then 
      local monochrome = checkbox:IsChecked()

      OnFontChanged(self, FontType(
        self.Font.font, 
        self.Font.height,
        self.Font.outline, 
        monochrome
      ))
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/nil }
  function BindSetting(self, setting)
    local font 
    if setting then 
      font = GetSetting(setting)
    end

    if font then 
      if font.font then
        self:GetChild("FontSetting"):SelectByValue(font.font)
      end

      if font.height then 
        self:GetChild("FontHeightSetting"):SetValue(font.height)
      end

      if font.outline then 
        self:GetChild("FontOutlineSetting"):SelectByValue(font.outline)
      end

      if font.monochrome then 
        self:GetChild("FontMonochromeSetting"):SetValue(font.monochrome)
      end
    end

    self.Font       = font 
    self.Setting    = setting
    self.UISetting  = nil
  end

  __Arguments__ { String/nil }
  function BindUISetting(self, uiSetting)
    local font 
    if uiSetting then 
      font = GetUISetting(uiSetting)
    end

    if font then 
      if font.font then
        self:GetChild("FontSetting"):SelectByValue(font.font)
      end

      if font.height then 
        self:GetChild("FontHeightSetting"):SetValue(font.height)
      end

      if font.outline then 
        self:GetChild("FontOutlineSetting"):SelectByValue(font.outline)
      end

      if font.monochrome then 
        self:GetChild("FontMonochromeSetting"):SetValue(font.monochrome)
      end
    end

    self.Font       = font 
    self.UISetting  = uiSetting
    self.Setting    = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Setting" {
    type = String
  }

  property "UISetting" {
    type = String
  }

  property "Font" {
    type = FontType
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    FontSetting           = SettingsDropDown,
    FontHeightSetting     = SettingsSlider,
    FontOutlineSetting    = SettingsDropDown,
    FontMonochromeSetting = SettingsCheckBox
  }
  function __ctor(self)
    local fontSetting = self:GetChild("FontSetting")
    fontSetting:SetLabel("Font")
    fontSetting:SetMediaType("font")

    local fontHeightSetting = self:GetChild("FontHeightSetting")
    fontHeightSetting:InstantApplyStyle()
    fontHeightSetting:SetLabel("Font Size")
    fontHeightSetting:SetMinMaxValues(6, 48)
    fontHeightSetting:SetValueStep(1)
    fontHeightSetting:SetSliderLabelFormatter(Widgets.Slider.Label.Right)

    local fontOutlineSetting = self:GetChild("FontOutlineSetting")
    fontOutlineSetting:SetLabel("Font Outline")
    fontOutlineSetting:AddEntry({ text = "NONE", value = "NONE"})
    fontOutlineSetting:AddEntry({ text = "NORMAL", value = "NORMAL"})
    fontOutlineSetting:AddEntry({ text = "THICK", value = "THICK"})

    local fontMonochromeSetting = self:GetChild("FontMonochromeSetting")
    fontMonochromeSetting:SetLabel("Font Monochrome")


    -- bind handlers 
    fontSetting.OnEntrySelected = fontSetting.OnEntrySelected + function(...)
      OnFontSettingSelected(self, ...)
    end

    fontHeightSetting.OnValueChanged = fontHeightSetting.OnValueChanged + function(...)
      OnFontHeightSettingChanged(self, ...)
    end

    fontOutlineSetting.OnEntrySelected = fontOutlineSetting.OnEntrySelected + function(...)
      OnFontOutlineSettingChanged(self, ...)
    end

    fontMonochromeSetting.OnCheckBoxClick = fontMonochromeSetting.OnCheckBoxClick + function(...)
      OnFontMonochromeSettingClick(self, ...)
    end

    self.OnFontChanged = self.OnFontChanged + function(_, font)
      if self.UISetting then
        SetUISetting(self.UISetting, font)
      elseif self.Setting then 
        SetSetting(self.Setting, font)
      end

      self.Font.font = font.font
      self.Font.height = font.height 
      self.Font.outline = font.outline
      self.Font.monochrome = font.monochrome
    end
  end
end)

-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingsText] = {
    height = 35,
    marginRight = 0,

    Text = {
      fontObject = GameFontNormal,
      textColor = NORMAL_FONT_COLOR,
      setAllPoints = true,
      justifyV = "MIDDLE",
      justifyH = "LEFT"
    }
  },

  [SettingsEditBox] = {
    height  = 35,
    marginRight = 0,

    Label = {
      fontObject = GameFontNormal,
      textColor = NORMAL_FONT_COLOR,
      justifyH = "LEFT",
      wordWrap = false,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT", 0, 0, nil, "CENTER"),  
      }
    },

    EditBox = {
      location = {
        Anchor("LEFT", 0, 0, "Label", "RIGHT")
      } 
    }
  },

  [SettingsCheckBox] = {
    height = 35,
    marginRight = 0,

    Label = {
      fontObject = GameFontNormal,
      textColor = NORMAL_FONT_COLOR,
      justifyH = "LEFT",
      wordWrap = false,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT", 0, 0, nil, "CENTER"),  
      }
    },

    CheckBox = {
      location = {
        Anchor("LEFT", 0, 0, "Label", "RIGHT")
      }
    }
  },

  [SettingsDropDown] = {
    height = 35,
    marginRight = 0,

    Label = {
      fontObject = GameFontNormal,
      textColor = NORMAL_FONT_COLOR,
      justifyH = "LEFT",
      wordWrap = false,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT", 0, 0, nil, "CENTER"),  
      }
    },

    DropDown = {
      location = {
        Anchor("LEFT", 0, 0, "Label", "RIGHT")
      }
    }
  },

  [SettingsSlider] = {
    height  = 35,
    marginRight = 0,

    Label = {
      fontObject = GameFontNormal,
      textColor = NORMAL_FONT_COLOR,
      justifyH = "LEFT",
      wordWrap = false,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT", 0, 0, nil, "CENTER"),  
      }
    },

    Slider = {
      location = {
        Anchor("LEFT", 0, 0, "Label", "RIGHT")
      } 
    }
  },

  [SettingsColorPicker] = {
    height = 35,
    marginRight = 0,

    Label = {
      fontObject = GameFontNormal,
      textColor = NORMAL_FONT_COLOR,
      justifyH = "LEFT",
      wordWrap = false,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT", 0, 0, nil, "CENTER"),  
      }
    },

    ColorPicker = {
      location = {
        Anchor("LEFT", -6, 0, nil, "CENTER")
      }
    }
  },

  [SettingsMediaFont] = {
    height = 140,
    marginRight = 0,

    FontSetting = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    FontHeightSetting = {
      location = {
        Anchor("TOPLEFT", 0, 0, "FontSetting", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "FontSetting", "BOTTOMRIGHT")
      }
    },

    FontOutlineSetting = {
      location = {
        Anchor("TOPLEFT", 0, 0, "FontHeightSetting", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "FontHeightSetting", "BOTTOMRIGHT")
      }      
    },

    FontMonochromeSetting = {
      location = {
        Anchor("TOPLEFT", 0, 0, "FontOutlineSetting", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "FontOutlineSetting", "BOTTOMRIGHT")
      }      
    }
  }
})