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

  -- Global setting API
  GetSetting        = SylingTracker.API.GetSetting,
  SetSetting        = SylingTracker.API.SetSetting,

  -- UI setting API
  GetUISetting      = SylingTracker.API.GetUISetting,
  SetUISetting      = SylingTracker.API.SetUISetting,

  -- Tracker setting API
  SetTrackerSetting = SylingTracker.API.SetTrackerSetting,
  GetTrackerSetting = SylingTracker.API.GetTrackerSetting,

  -- ItemBar setting API
  GetItemBarSetting = SylingTracker.API.GetItemBarSetting,
  SetItemBarSetting = SylingTracker.API.SetItemBarSetting
}

enum "BindSettingType" {
  "setting",
  "uiSetting",
  "tracker",
  "itemBar"
}

interface "IBindSetting" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Abstract__() function PrepareFromSetting(self, value, hasDefault, defaultValue) end

  __Arguments__ { String/nil, BindSettingType/"setting", Any * 0}
  function BindSetting(self, setting, settingType, ...)
    local value, hasDefault, defaultValue

    wipe(self.SettingExtraArgs)
    for i = 1, select("#", ...) do 
      local arg = select(i, ...)
      tinsert(self.SettingExtraArgs, arg)
    end

    if setting then 
      if settingType == "setting" then 
        value, hasDefault, defaultValue = GetSetting(setting, ...)
      elseif settingType == "uiSetting" then 
        value, hasDefault, defaultValue = GetUISetting(setting, ...)
      elseif settingType == "tracker" then
        local trackerID = ...
        value, hasDefault, defaultValue = GetTrackerSetting(trackerID, setting, select(2, ...))
      elseif settingType == "itemBar" then 
        value, hasDefault, defaultValue = GetItemBarSetting(setting, ...)
      end
    end
    
    if value == nil and hasDefault then 
      value = defaultValue
    end

    self:PrepareFromSetting(value, hasDefault, defaultValue)

    self.Setting        = setting
    self.SettingType    = settingType
    self.Default        = defaultValue
  end

  function TriggerSetSetting(self, setting, value, notify)
    local settingType = self.SettingType
    if settingType == "setting" then 
      SetSetting(setting, value, nil, unpack(self.SettingExtraArgs))
    elseif settingType == "uiSetting" then 
      SetUISetting(setting, value, nil, unpack(self.SettingExtraArgs))
    elseif settingType == "tracker" then
      local trackerID = self.SettingExtraArgs[1]
      SetTrackerSetting(trackerID, setting, value, nil, unpack(self.SettingExtraArgs, 2))
    elseif settingType == "itemBar" then 
      SetItemBarSetting(setting, value, nil, unpack(self.SettingExtraArgs))
    end
  end

  __Arguments__ { String/nil, Any * 0  }
  function BindUISetting(self, setting, ... )
    return self:BindSetting(setting, "uiSetting", ...)
  end

  __Arguments__ { String/nil, String/nil, Any * 0 }
  function BindTrackerSetting(self, trackerID, setting, ...)
    return self:BindSetting(setting, "tracker", trackerID, ...)
  end

  __Arguments__ { String/nil, Any * 0 }
  function BindItemBarSetting(self, setting, ... )
    return self:BindSetting(setting, "itemBar", ...)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Setting" {
    type    = String
  }

  property "SettingType" {
    type    = BindSettingType
  }

  property "SettingExtraArgs" {
    set = false,
    default = function() return {} end
  }
end)

__Widget__()
class "SettingsSectionHeader" (function(_ENV)
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

  -- function OnRelease(self)
  --   self:SetID(0)
  --   self:Hide()
  --   self:ClearAllPoints()
  --   self:SetParent(nil)
  -- end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Title = FontString
  }
  function __ctor(self) end 
end)

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
    -- self:SetID(0)
    -- self:Hide()
    -- self:ClearAllPoints()
    -- self:SetParent(nil)

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
    -- self:SetID(0)
    -- self:Hide()
    -- self:ClearAllPoints()
    -- self:SetParent(nil)

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
  inherit "Frame" extend "IBindSetting"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__{ CheckBox = "OnClick"}
  event "OnCheckBoxClick"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnCheckBoxClickHandler(self, checkbox)
    local setting = self.Setting
    if setting then
      local value = self.InvertSetting and (not self:IsChecked()) or self:IsChecked()
      self:TriggerSetSetting(setting, value)
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

  __Arguments__ { Boolean/ false}
  function SetInvertedSetting(self, invert)
    self.InvertSetting = invert
  end

  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    if self.InvertSetting then
      self:SetChecked(not value)
    else 
      self:SetChecked(value )
    end
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    -- self:SetID(0)
    -- self:Hide()
    -- self:ClearAllPoints()
    -- self:SetParent(nil)

    for name, v in Style.GetCustomStyles(self) do 
      Style[self][name] = CLEAR
    end

    ResetStyles(self, true)

    self.InvertSetting  = nil

    self:BindSetting()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "InvertSetting" {
    type    = Boolean,
    default = false
  }

  property "Default" {
    type    = Any
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
  inherit "Frame" extend "IBindSetting"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__{ DropDown = "OnEntrySelected"}
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEntrySelectedHandler(self, entry)
    local setting = self.Setting
    if setting then
      local data = entry:GetEntryData()
      self:TriggerSetSetting(setting, data.value)
    end
  end
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

  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    if value then 
      self:SelectByValue(value)
    end
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    -- self:SetID(0)
    -- self:Hide()
    -- self:ClearAllPoints()
    -- self:SetParent(nil)

    self:GetChild("DropDown"):ClearEntries()

    ResetStyles(self, true)

    self.Setting      = nil 
    self.SettingType  = nil
    self.Default      = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Default" {
    type = Any
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label     = FontString,
    DropDown  = DropDown
  }
  function __ctor(self) 
    self.OnEntrySelected = self.OnEntrySelected + OnEntrySelectedHandler
  end 
end)

__Widget__()
class "SettingsSlider" (function(_ENV)
  inherit "Frame" extend "IBindSetting"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__{ Slider = "OnValueChanged"}
  event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnValueChangedHandler(self, value)
    local setting = self.Setting
    if setting then
      self:TriggerSetSetting(setting, value)
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

  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    if value then 
      self:SetValue(value)
    elseif hasDefault then
      self:SetValue(defaultValue)
    end
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    -- self:SetID(0)
    -- self:Hide()
    -- self:ClearAllPoints()
    -- self:SetParent(nil)

    ResetStyles(self, true)

    self:BindSetting()
    --- It's important these functions are called after Setting has been set 
    --- to nil for avoiding the setting value is updated by an incorrect value
    self:SetValue(0)
    self:SetValueStep(1)
    self:SetMinMaxValues(0, 100)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Default" {
    type = Any
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
  inherit "Frame" extend "IBindSetting"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__ { ColorPicker = "OnColorChanged"}
  event "OnColorChanged"

  __Bubbling__ { ColorPicker = "OnColorConfirmed"}
  event "OnColorConfirmed"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnColorConfirmedHandler(self, r, g, b, a)
    local setting = self.Setting
    if setting then
      local color = Color(r, g, b, a)
      self:TriggerSetSetting(setting, color)
    end
  end
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

  __Arguments__ { String }
  function SetLabelStyle(self, style)
    if style == "small" then 
      Style[self].Label.fontObject = GameFontNormalSmall
    end
  end

  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    if value then 
      self:SetColor(value.r, value.g, value.b, value.a)
    end
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    -- self:ClearAllPoints()
    self:SetParent(nil)

    ResetStyles(self, true)

    self:BindSetting()

    self:SetColor()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Default" {
    type    = Any
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label = FontString,
    ColorPicker = ColorPicker
  }
  function __ctor(self)
    self.OnColorConfirmed = self.OnColorConfirmed + OnColorConfirmedHandler
  end
end)

__Widget__()
class "SettingsMediaFont" (function(_ENV)
  inherit "Frame" extend "IBindSetting"
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

  local function OnFontChangedHandler(self, font)
    local setting = self.Setting
    if setting then 
      self:TriggerSetSetting(setting, font)
    end

    self.Font.font = font.font
    self.Font.height = font.height 
    self.Font.outline = font.outline
    self.Font.monochrome = font.monochrome
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    if value then 
      if value.font then
        self:GetChild("FontSetting"):SelectByValue(value.font)
      end

      if value.height then 
        self:GetChild("FontHeightSetting"):SetValue(value.height)
      end

      if value.outline then 
        self:GetChild("FontOutlineSetting"):SelectByValue(value.outline)
      end

      if value.monochrome then 
        self:GetChild("FontMonochromeSetting"):SetChecked(value.monochrome)
      end
    end

    self.Font = value
  end

  function OnRelease(self)
    self:BindSetting()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Default" {
    type    = Any
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
    fontSetting:SetMediaType("font")

    local fontHeightSetting = self:GetChild("FontHeightSetting")
    fontHeightSetting:InstantApplyStyle()
    fontHeightSetting:SetMinMaxValues(6, 48)
    fontHeightSetting:SetValueStep(1)
    fontHeightSetting:SetSliderLabelFormatter(Widgets.Slider.Label.Right)

    local fontOutlineSetting = self:GetChild("FontOutlineSetting")
    fontOutlineSetting:AddEntry({ text = "NONE", value = "NONE"})
    fontOutlineSetting:AddEntry({ text = "NORMAL", value = "NORMAL"})
    fontOutlineSetting:AddEntry({ text = "THICK", value = "THICK"})

    local fontMonochromeSetting = self:GetChild("FontMonochromeSetting")

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

    self.OnFontChanged = self.OnFontChanged + OnFontChangedHandler
  end
end)

__Widget__()
class "SettingsExpandableSection" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnChildChangedHandler(self, child, isAdded)
    if isAdded and child:GetID() > 0 then 
      child:SetShown(self.Expanded)
    end
  end
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  function UpdateVisibility(self)
    local button = self:GetChild("Button")
    
    for name, frame in self:GetChilds() do
      if Class.IsObjectType(frame, Frame) and frame:GetID() > 0 then 
        frame:SetShown(self.Expanded)
      end
    end
  end

  function SetTitle(self, title)
    Style[self].Button.Text.text = title
  end

  __Arguments__ { Boolean/nil}
  function SetExpanded(self, expanded)
    self.Expanded = expanded
  end

  function IsExpanded(self)
    return self.Expanded
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

    self.Expanded = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------  
  __Observable__()
  property "Expanded" {
    type = Boolean,
    default = false,
    handler = UpdateVisibility
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Button = Button,
    {
      Button = {
        Text = FontString,
        ExpandTexture = Texture,
      }
    }
  }
  function __ctor(self) 
    local button = self:GetChild("Button")
    button.OnClick = button.OnClick + function()
      self:SetExpanded(not self:IsExpanded())
    end

    self.OnChildChanged = self.OnChildChanged + OnChildChangedHandler
  end

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingsSectionHeader] = {
    height = 45,
    marginRight = 0,

    Title = {
      justifyH = "LEFT",
      justifyV = "MIDDLE",
      fontObject = GameFontHighlightLarge,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  },

  [SettingsText] = {
    height = 35,
    marginRight = 0,

    Text = {
      fontObject = Game11Font,
      textColor = Color.NORMAL,
      setAllPoints = true,
      justifyV = "MIDDLE",
      justifyH = "LEFT"
    }
  },

  [SettingsEditBox] = {
    height  = 35,
    marginRight = 0,

    Label = {
      fontObject = Game11Font,
      textColor = Color.NORMAL,
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
      fontObject = Game11Font,
      textColor = Color.NORMAL,
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
      fontObject = Game11Font,
      textColor = Color.NORMAL,
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
      fontObject = Game11Font,
      textColor = Color.NORMAL,
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
      fontObject = Game11Font,
      textColor = Color.NORMAL,
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
      Label = { text = "Font"},
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    FontHeightSetting = {
      Label = { text = "Font Size"},
      location = {
        Anchor("TOPLEFT", 0, 0, "FontSetting", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "FontSetting", "BOTTOMRIGHT")
      }
    },

    FontOutlineSetting = {
      Label = { text = "Font Outline"},
      location = {
        Anchor("TOPLEFT", 0, 0, "FontHeightSetting", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "FontHeightSetting", "BOTTOMRIGHT")
      }      
    },

    FontMonochromeSetting = {
      Label = { text = "Font Monochrome"},
      location = {
        Anchor("TOPLEFT", 0, 0, "FontOutlineSetting", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "FontOutlineSetting", "BOTTOMRIGHT")
      }      
    }
  },

  [SettingsExpandableSection] = {
    height = 35,
    marginRight = 0,
    layoutManager = Layout.VerticalLayoutManager(),
    paddingTop = 35,
    paddingBottom = 0,
    paddingLeft = 20,
    paddingRight = 20,
    marginRight = 0,

    Button = {
      height = 35,

      Text = {
        fontObject = Game11Font,
        justifyH = "LEFT",
        text = "Text Color",
        setAllPoints = true,
      },

      ExpandTexture = {
        atlas = Wow.FromUIProperty("Expanded"):Map(function(expanded)
          return expanded and AtlasType("poi-door-arrow-up", true) or AtlasType("poi-door-arrow-down", true)
        end),
        location = {
          Anchor("LEFT", 0, 0, nil, "CENTER")
        }
      },

      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT"),
      },

      HighlightTexture = {
        file = [[Interface\Buttons\WHITE8X8]],
        vertexColor = { r = 1, g = 1, b = 1, a = 0.05},
        setAllPoints = true,
      },
    },

    [SettingsColorPicker] = {
      Label = {
        fontObject = GameFontNormalSmall
      }
    }
  }
})