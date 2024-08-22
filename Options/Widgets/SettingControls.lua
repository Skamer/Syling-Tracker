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
  LAST_SET_SETTINGS_TIME = {}
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Abstract__() function PrepareFromSetting(self, value, hasDefault, defaultValue) end

  __Abstract__() function SyncFromOutside(self, value) end

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
        self:RegisterSyncEvents()
      elseif settingType == "itemBar" then 
        value, hasDefault, defaultValue = GetItemBarSetting(setting, ...)
      end
    else 
      self:UnregisterSyncEvents()
    end
    
    if value == nil and hasDefault then 
      value = defaultValue
    end

    
    self.Setting        = setting
    self.SettingType    = settingType
    self.Default        = defaultValue

    if setting then 
      self:PrepareFromSetting(value, hasDefault, defaultValue)
      self:RegisterSyncEvents()
    end
  end

  function TriggerSetSetting(self, setting, value, notify)
    local settingType = self.SettingType

    LAST_SET_SETTINGS_TIME[self] = GetTime()

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

  function OnSystemEvent(self, event, setting, ...)
    local bindSetting = self.Setting 
    if not bindSetting or bindSetting ~= setting then 
      return 
    end

    --  This is to prevent the widget to react on its own event. 
    local lastSetSettingTIme = LAST_SET_SETTINGS_TIME[self]
    if lastSetSettingTIme and (GetTime() - lastSetSettingTIme) <= 0.05 then 
      return 
    end

    if event == "SylingTracker_SETTING_CHANGED" then 
      local value = ...
      self:SyncFromOutside(value)
    elseif event == "SylingTracker_UI_SETTING_CHANGED" then
      local value = ...
      self:SyncFromOutside(value)
    elseif event == "SylingTracker_TRACKER_SETTING_UPDATED" then 
      local eventTrackerID, value = ...
      local bindTrackerID = self.SettingExtraArgs[1]
      if bindTrackerID and eventTrackerID and bindTrackerID == eventTrackerID then
        self:SyncFromOutside(value)
      end
    elseif event == "SylingTracker_ITEMBAR_SETTING_UPDATED" then
      local value = ...
      self:SyncFromOutside(value)
    end
  end

  function RegisterSyncEvents(self)
    local settingType = self.SettingType
    if not self.RegisterSystemEvent and settingType then
      return 
    end

    if settingType == "setting" then 
      self:RegisterSystemEvent("SylingTracker_SETTING_CHANGED")
    elseif settingType == "uiSetting" then 
      self:RegisterSystemEvent("SylingTracker_UI_SETTING_CHANGED")
    elseif settingType == "tracker" then 
      self:RegisterSystemEvent("SylingTracker_TRACKER_SETTING_UPDATED")
    elseif settingType == "itemBar" then
      self:RegisterSystemEvent("SylingTracker_ITEMBAR_SETTING_UPDATED")
    end
  end

  function UnregisterSyncEvents(self)
    local settingType = self.SettingType
    if not self.UnegisterSystemEvent and settingType then 
      return 
    end

    if settingType == "setting" then 
      self:UnegisterSystemEvent("SylingTracker_SETTING_CHANGED")
    elseif settingType == "uiSetting" then 
      self:UnegisterSystemEvent("SylingTracker_UI_SETTING_CHANGED")
    elseif settingType == "tracker" then 
      self:UnegisterSystemEvent("SylingTracker_TRACKER_SETTING_UPDATED")
    elseif settingType == "itemBar" then
      self:UnegisterSystemEvent("SylingTracker_ITEMBAR_SETTING_UPDATED")
    end
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
    -- self:InstantApplyStyle()
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
    -- self:InstantApplyStyle()
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
    -- self:InstantApplyStyle()
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
    -- self:InstantApplyStyle()
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
    -- self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:BindSetting()
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
  local function OnValueChangedHandler(self, value, userInput)
    if not userInput then 
      return 
    end

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
    self:GetChild("Slider"):SetMinMaxValues(min, max)
  end

  __Arguments__ { Number }
  function SetValueStep(self, valueStep)
    self:GetChild("Slider"):SetValueStep(valueStep)
  end

  __Arguments__ { Number }
  function SetValue(self, value) self:GetChild("Slider"):SetValue(value) end

  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    if value ~= nil then
      self:SetValue(value)
    elseif hasDefault then
      self:SetValue(defaultValue)
    end
  end

  function SyncFromOutside(self, value)
    self:SetValue(value)
  end

  function OnAcquire(self)
    -- self:InstantApplyStyle()
  end

  function OnRelease(self)
    -- self:SetID(0)
    -- self:Hide()
    -- self:ClearAllPoints()
    -- self:SetParent(nil)
    
    self:BindSetting()
    --- It's important these functions are called after Setting has been set 
    --- to nil for avoiding the setting value is updated by an incorrect value
    ResetStyles(self, true)
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

    self:SetMinMaxValues(0, 100)
    self:SetValueStep(1)
  end
end)

__Widget__()
class "SettingsPosition"(function(_ENV)
  inherit "Frame" extend "IBindSetting"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnPositionChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnXPosChanged(self, slider, value, userInput)
    if self.Position then 
      OnPositionChanged(self, Position(value, self.Position.y), userInput)
    end
  end

  local function OnYPosChanged(self, slider, value, userInput)
    if self.Position then 
      OnPositionChanged(self, Position(self.Position.x, value), userInput)
    end
  end

  local function OnPositionChangedHandler(self, pos, userInput)
    if not userInput then 
      return 
    end

    local setting = self.Setting
    if setting then
      self:TriggerSetSetting(setting, pos)
    end

    self.Position.x = pos.x 
    self.Position.y = pos.y
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetXLabel(self, text)
    Style[self].XSlider.Label.text = text
  end

  function SetYLabel(self, text)
    Style[self].YSlider.Label.text = text
  end

  function SetXMinMaxValues(self, ...) 
    self:GetChild("XSlider"):SetMinMaxValues(...)
  end

  function SetYMinMaxValues(self, ...)
    self:GetChild("YSlider"):SetMinMaxValues(...)
  end

  function SetMinMaxValues(self, ...)
    self:GetChild("XSlider"):SetMinMaxValues(...)
    self:GetChild("YSlider"):SetMinMaxValues(...)
  end

  function SetValueStep(self, ...)
    self:GetChild("XSlider"):SetValueStep(...)
    self:GetChild("YSlider"):SetValueStep(...)
  end

  function SetValue(self, ...)
    self:GetChild("XSlider"):SetValue(...)
    self:GetChild("YSlider"):SetValue(...)
  end

  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    local x = value and value.x or 0
    local y = value and value.y or 0

    self:GetChild("XSlider"):SetValue(x)
    self:GetChild("YSlider"):SetValue(y)


    self.Position = Position(x, y)
  end

  function SyncFromOutside(self, value)
    self:GetChild("XSlider"):SetValue(value.x)
    self:GetChild("YSlider"):SetValue(value.y)
  end

  function OnRelease(self)
    self:BindSetting()

    --- It's important these functions are called after Setting has been set 
    --- to nil for avoiding the setting value is updated by an incorrect value
    ResetStyles(self, true)

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

  property "Position" {
    type = Position
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    XSlider = SettingsSlider,
    YSlider = SettingsSlider,
  }
  function __ctor(self)
    local xSlider = self:GetChild("XSlider")
    local ySlider = self:GetChild("YSlider")

    xSlider.OnValueChanged = xSlider.OnValueChanged + function(...)
      OnXPosChanged(self, ...)
    end

    ySlider.OnValueChanged = ySlider.OnValueChanged + function(...)
      OnYPosChanged(self, ...)
    end

    self.OnPositionChanged = self.OnPositionChanged + OnPositionChangedHandler
  end
end)

__Widget__()
class "SettingsSize"(function(_ENV)
  inherit "Frame" extend "IBindSetting"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnWidthChangedHandler(slider, value, userInput)
    local parent = slider:GetParent()
    if parent.HeightValue then 
      OnValueChanged(parent, Size(value, parent.HeightValue), userInput)
    end    
  end

  local function OnHeightChangedHandler(slider, value, userInput)
    local parent = slider:GetParent()
    if parent.WidthValue then 
      OnValueChanged(parent, Size(parent.WidthValue, value), userInput)
    end
  end

  local function OnValueChangedHandler(self, size, userInput)
    if not userInput then 
      return 
    end

    local setting = self.Setting
    if setting then 
      self:TriggerSetSetting(setting, size)
    end

    self.WidthValue = size.width
    self.HeightValue = size.height
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetWidthLabel(self, text)
    Style[self].WidthSlider.Label.text = text 
  end

  function SetHeightLabel(self, text)
    Style[self].HeightSlider.Label.text = text
  end

  function SetWidthMinMaxValues(self, ...)
    self:GetChild("WidthSlider"):SetMinMaxValues(...)
  end

  function SetHeightMinMaxValues(self, ...)
    self:GetChild("HeightSlider"):SetMinMaxValues(...)
  end

  function SetMinMaxValues(self, ...)
    self:SetWidthMinMaxValues(...)
    self:SetHeightMinMaxValues(...)
  end

  function SetValueStep(self, ...)
    self:GetChild("WidthSlider"):SetValueStep(...)
    self:GetChild("HeightSlider"):SetValueStep(...)
  end

  function SetValue(self, ...)
    self:GetChild("WidthSlider"):SetValue(...)
    self:GetChild("HeightSlider"):SetValue(...)
  end

  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    local width = value and value.width or 0
    local height = value and value.height or 0

    self:GetChild("WidthSlider"):SetValue(width)
    self:GetChild("HeightSlider"):SetValue(height)

    self.WidthValue = width
    self.HeightValue = height
  end

  function OnRelease(self)
    self:BindSetting()

    --- It's important these functions are called after Setting has been set 
    --- to nil for avoiding the setting value is updated by an incorrect value
    ResetStyles(self, true)

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

  property "HeightValue" {
    type = Number
  }

  property "WidthValue" {
    type = Number
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    WidthSlider = SettingsSlider,
    HeightSlider = SettingsSlider,
  }
  function __ctor(self)
    local widthSlider = self:GetChild("WidthSlider")
    local heightSlider = self:GetChild("HeightSlider")

    widthSlider.OnValueChanged = widthSlider.OnValueChanged + OnWidthChangedHandler
    heightSlider.OnValueChanged = heightSlider.OnValueChanged + OnHeightChangedHandler

    self.OnValueChanged = self.OnValueChanged + OnValueChangedHandler
  end
end)

__Widget__()
class "SettingsFramePointPicker" (function(_ENV)
  inherit "Frame" extend "IBindSetting"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__ { FramePointPicker = "OnValueChanged" }
  event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnValueChangedHandler(self, new, old, userInput)
    if not userInput then 
      return 
    end

    local setting = self.Setting
    if setting then
      self:TriggerSetSetting(setting, new)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function PrepareFromSetting(self, value, hasDefault, defaultValue)
    if value then 
      self:SetValue(value)
    end
  end

  function SetValue(self, ...) self:GetChild("FramePointPicker"):SetValue(...) end
  function SetText(self, ...) self:GetChild("FramePointPicker"):SetText(...) end
  function DisablePoint(self, ...) self:GetChild("FramePointPicker"):DisablePoint(...) end
  function EnablePoint(self, ...) self:GetChild("FramePointPicker"):EnablePoint(...) end
  function DisablePoints(self, ...) self:GetChild("FramePointPicker"):DisablePoints(...) end
  function EnablePoints(self, ...) self:GetChild("FramePointPicker"):EnablePoints(...) end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:SetParent(nil)

    self:BindSetting()

    ResetStyles(self, true)


    self:SetValue()
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    FramePointPicker = FramePointPicker
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
    -- self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:BindSetting()

    self:SetID(0)
    self:Hide()
    -- self:ClearAllPoints()
    self:SetParent(nil)

    ResetStyles(self, true)


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
    fontHeightSetting:SetMinMaxValues(6, 48)
    fontHeightSetting:SetValueStep(1)

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
    -- self:InstantApplyStyle()
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
        Anchor("LEFT", 0, 0, "Label", "RIGHT"),
        Anchor("RIGHT")
      } 
    }
  },

  [SettingsPosition] = {
    height = 70,
    marginRight = 0,

    XSlider = {
      Label = { text = "X"},
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    YSlider = {
      Label = { text = "Y"},
      location = {
        Anchor("TOPLEFT", 0, 0, "XSlider", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "XSlider", "BOTTOMRIGHT")
      }
    }
  },
  [SettingsSize] = {
    height = 70,
    marginRight = 0,

    WidthSlider = {
      Label = { text = "Width"},
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    HeightSlider = {
      Label = { text = "Height"},
      location = {
        Anchor("TOPLEFT", 0, 0, "WidthSlider", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, 0, "WidthSlider", "BOTTOMRIGHT")
      }
    }
  },

  [SettingsFramePointPicker] = {
    height = 105,
    marginRight = 0,
    
    FramePointPicker = {
      location = {
        Anchor("CENTER")
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
          return expanded and AtlasType("UI-HUD-Minimap-Zoom-Out", true) or AtlasType("UI-HUD-Minimap-Zoom-In", true)
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