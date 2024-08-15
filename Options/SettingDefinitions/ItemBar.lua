-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.ItemBar"           ""
-- ========================================================================= --
export {
  newtable                      = Toolset.newtable,
}

__Widget__()
class "SettingDefinitions.ItemBar" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  _ORIENTATION_ENTRIES = Array[Widgets.EntryData]()
  _ORIENTATION_ENTRIES:Insert({ text = "Vertical", value = Orientation.VERTICAL})
  _ORIENTATION_ENTRIES:Insert({ text = "Horizontal", value = Orientation.HORIZONTAL})

  function BuildGeneralTab(self)
    ---------------------------------------------------------------------------
    --- Enable
    ---------------------------------------------------------------------------
    local enableCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    enableCheckBox:SetID(10)
    enableCheckBox:SetLabel("Enable")
    enableCheckBox:BindItemBarSetting("enabled")
    self.GeneralTabControls.enableCheckBox = enableCheckBox
    ---------------------------------------------------------------------------
    --- Lock
    ---------------------------------------------------------------------------
    local lockCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    lockCheckBox:SetID(20)
    lockCheckBox:SetLabel("Lock")
    lockCheckBox:BindItemBarSetting("locked")
    self.GeneralTabControls.lockCheckBox = lockCheckBox
    ---------------------------------------------------------------------------
    --- Column Count
    ---------------------------------------------------------------------------
    local columnCountSlider = Widgets.SettingsSlider.Acquire(false, self)
    columnCountSlider:SetID(30)
    columnCountSlider:SetLabel("Column Count")
    columnCountSlider:SetMinMaxValues(1, 12)
    columnCountSlider:BindItemBarSetting("columnCount")
    self.GeneralTabControls.columnCountSlider = columnCountSlider
    ---------------------------------------------------------------------------
    --- Row Count
    ---------------------------------------------------------------------------    
    local rowCountSlider = Widgets.SettingsSlider.Acquire(false, self)
    rowCountSlider:SetID(40)
    rowCountSlider:SetLabel("Row Count")
    rowCountSlider:SetMinMaxValues(1, 12)
    rowCountSlider:BindItemBarSetting("rowCount")
    self.GeneralTabControls.rowCountSlider = rowCountSlider
    ---------------------------------------------------------------------------
    --- Margin Left
    ---------------------------------------------------------------------------
    local marginLeftSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginLeftSlider:SetID(50)
    marginLeftSlider:SetLabel("Margin Left")
    marginLeftSlider:SetMinMaxValues(0, 50)
    marginLeftSlider:BindItemBarSetting("marginLeft")
    self.GeneralTabControls.marginLeftSlider = marginLeftSlider
    ---------------------------------------------------------------------------
    --- Margin Right
    ---------------------------------------------------------------------------    
    local marginRightSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginRightSlider:SetID(60)
    marginRightSlider:SetLabel("Margin Right")
    marginRightSlider:SetMinMaxValues(0, 50)
    marginRightSlider:BindItemBarSetting("marginRight")
    self.GeneralTabControls.marginRightSlider = marginRightSlider
    ---------------------------------------------------------------------------
    --- Margin Top
    ---------------------------------------------------------------------------
    local marginTopSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginTopSlider:SetID(70)
    marginTopSlider:SetLabel("Margin Top")
    marginTopSlider:SetMinMaxValues(0, 50)
    marginTopSlider:BindItemBarSetting("marginTop")
    self.GeneralTabControls.marginTopSlider = marginTopSlider
    ---------------------------------------------------------------------------
    --- Margin Bottom
    ---------------------------------------------------------------------------
    local marginBottomSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginBottomSlider:SetID(80)
    marginBottomSlider:SetLabel("Margin Bottom")
    marginBottomSlider:BindItemBarSetting("marginBottom")
    marginBottomSlider:SetMinMaxValues(0, 50)
    self.GeneralTabControls.marginBottomSlider = marginBottomSlider
    ---------------------------------------------------------------------------
    --- Orientation
    ---------------------------------------------------------------------------
    local orientationDropDown = Widgets.SettingsDropDown.Acquire(false, self)
    orientationDropDown:SetID(90)
    orientationDropDown:SetLabel("Orientation")
    orientationDropDown:SetEntries(_ORIENTATION_ENTRIES)
    orientationDropDown:BindItemBarSetting("orientation")
    self.GeneralTabControls.orientationDropDown = orientationDropDown
    ---------------------------------------------------------------------------
    --- Left to Right
    ---------------------------------------------------------------------------
    local leftToRightCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    leftToRightCheckBox:SetID(100)
    leftToRightCheckBox:SetLabel("Left to Right")
    leftToRightCheckBox:BindItemBarSetting("leftToRight")
    self.GeneralTabControls.leftToRightCheckBox = leftToRightCheckBox
    ---------------------------------------------------------------------------
    --- Top to Bottom
    ---------------------------------------------------------------------------
    local topToBottomCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    topToBottomCheckBox:SetID(110)
    topToBottomCheckBox:SetLabel("Top to Bottom")
    topToBottomCheckBox:BindItemBarSetting("topToBottom")
    self.GeneralTabControls.topToBottomCheckBox = topToBottomCheckBox
    ---------------------------------------------------------------------------
    --- Sort by Distance
    ---------------------------------------------------------------------------
    local sortByDistanceCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    sortByDistanceCheckBox:SetID(120)
    sortByDistanceCheckBox:SetLabel("Sort by distance")
    self.GeneralTabControls.sortByDistanceCheckBox = sortByDistanceCheckBox
  end
  -----------------------------------------------------------------------------
  --                    [General] Tab Release                                --
  -----------------------------------------------------------------------------
  function ReleaseGeneralTab(self)
    for index, control in pairs(self.GeneralTabControls) do 
      control:Release()
      self.GeneralTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                   [General] Item Builder                                --
  -----------------------------------------------------------------------------
  function BuildItemTab(self)
    local widthSlider = Widgets.SettingsSlider.Acquire(false, self)
    widthSlider:SetID(10)
    widthSlider:SetLabel("Width")
    widthSlider:SetMinMaxValues(6, 92)
    widthSlider:BindItemBarSetting("elementWidth")
    self.ItemTabControls.widthSlider = widthSlider
    
    local heightSlider = Widgets.SettingsSlider.Acquire(false, self)
    heightSlider:SetID(20)
    heightSlider:SetLabel("Height")
    heightSlider:SetMinMaxValues(6, 92)
    heightSlider:BindItemBarSetting("elementHeight")
    self.ItemTabControls.heightSlider = heightSlider

    local hSpacingSlider = Widgets.SettingsSlider.Acquire(false, self)
    hSpacingSlider:SetID(30)
    hSpacingSlider:SetLabel("Horizontal Spacing")
    hSpacingSlider:SetMinMaxValues(0, 24)
    hSpacingSlider:BindItemBarSetting("hSpacing")
    self.ItemTabControls.hSpacingSlider = hSpacingSlider
    
    local vSpacingSlider = Widgets.SettingsSlider.Acquire(false, self)
    vSpacingSlider:SetID(40)
    vSpacingSlider:SetLabel("Vertical Spacing")
    vSpacingSlider:SetMinMaxValues(0, 24)
    vSpacingSlider:BindItemBarSetting("vSpacing")
    self.ItemTabControls.vSpacingSlider = vSpacingSlider
  end
  -----------------------------------------------------------------------------
  --                    [General] Tab Release                                --
  -----------------------------------------------------------------------------
  function ReleaseItemTab(self)
    for index, control in pairs(self.ItemTabControls) do 
      control:Release()
      self.ItemTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)
    tabControl:AddTabPage({
      name = "General",
      onAcquire = function() self:BuildGeneralTab() end,
      onRelease = function() self:ReleaseGeneralTab() end, 
    })

    tabControl:AddTabPage({
      name = "Item",
      onAcquire = function() self:BuildItemTab() end,
      onRelease = function() self:ReleaseItemTab() end 
    })

    tabControl:Refresh()
    tabControl:SelectTab(1)

    self.SettingControls.tabControl = tabControl
  end

  function ReleaseSettingControls(self)
    self.SettingControls.tabControl:Release()
    self.SettingControls.tabControl = nil
  end

  function OnBuildSettings(self)
    self:BuildSettingControls()
  end

  function OnRelease(self)
    self:SetID(0)
    self:SetParent()
    self:ClearAllPoints()
    self:Hide()

    self:ReleaseSettingControls()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SettingControls" {
    set = false,
    default = function() return newtable(false, true) end 
  }

  property "GeneralTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

  property "ItemTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.ItemBar] = {
    height = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true),
  },
})