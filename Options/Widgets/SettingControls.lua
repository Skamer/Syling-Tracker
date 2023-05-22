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
  SetSetting        = SylingTracker.API.SetSetting
}

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
  --                               Events                                    --
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
  function __ctor(self) end

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
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
})