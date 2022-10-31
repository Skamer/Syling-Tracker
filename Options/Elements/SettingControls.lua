-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.SettingControls"         ""
-- ========================================================================= --
export {
  ResetStyles       = SLT.Utils.ResetStyles,
  TruncateDecimal   = SLT.Utils.Math.TruncateDecimal
}

__Widget__()
class "SUI.SettingsSectionHeader" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/"" }
  function SetTitle(self, title)
    Style[self].Title.text = title
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Title = FontString
  }
  function __ctor(self) end 

end)

__Widget__() 
class "SUI.SettingsText" (function(_ENV)
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
class "SUI.SettingsEditBox" (function(_ENV)
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
    EditBox = SUI.EditBox
  }
  function __ctor(self) end
end)

__Widget__()
class "SUI.SettingsCheckBox" (function(_ENV)
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
        SLT.Settings.Set(self.Setting, not value)
      else 
        SLT.Settings.Set(self.Setting, value)
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
      local value = SLT.Settings.Get(settingId)

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
    CheckBox  = SUI.CheckBox
  }
  function __ctor(self) 
    self.OnCheckBoxClickHandler = function() OnCheckBoxClickHandler(self) end

    self.OnCheckBoxClick = self.OnCheckBoxClick + self.OnCheckBoxClickHandler
  end 
end)

__Widget__()
class "SUI.SettingsDropDown" (function(_ENV)
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

    ResetStyles(self, true)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label     = FontString,
    DropDown  = SUI.DropDown
  }
  function __ctor(self) end 
end)


__Widget__()
class "SUI.SettingsSlider" (function(_ENV)
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

  __Arguments__ { SUI.Slider.Label, Any/nil }
  function SetSliderLabelFormatter(self, labelType, value)
    self:GetChild("Slider"):SetLabelFormatter(labelType, value)
  end

    __Arguments__ { String }
  function BindSetting(self, settingId)
      local value = SLT.Settings.Get(settingId)

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
    Slider  = SUI.Slider
  }
  function __ctor(self)
    self.OnValueChanged = self.OnValueChanged + OnValueChangedHandler 
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.SettingsSectionHeader] = {
    height = 45,
    marginRight = 0,

    Title = {
      justifyH = "LEFT",
      justifyV = "TOP",
      fontObject = GameFontHighlightLarge,
      location = {
        Anchor("TOPLEFT", 7, -16)
      }
    }
  },

  [SUI.SettingsCheckBox] = {
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

  [SUI.SettingsEditBox] = {
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

  [SUI.SettingsDropDown] = {
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
  
  [SUI.SettingsSlider] = {
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
  }
})