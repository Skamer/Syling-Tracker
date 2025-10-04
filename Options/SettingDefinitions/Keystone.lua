-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling         "SylingTracker_Options.SettingDefinitions.Keystone"           ""
-- ========================================================================= --
export {
  L                                   = _Locale,
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.Keystone" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                        [Top Info] Tab Builder                           --
  -----------------------------------------------------------------------------
  function BuildTopInfoTab(self)
    ---------------------------------------------------------------------------
    --- Dungeon Name Section
    ---------------------------------------------------------------------------
    local dungeonNameSection = Widgets.ExpandableSection.Acquire(false, self)
    dungeonNameSection:SetExpanded(false)
    dungeonNameSection:SetID(50)
    dungeonNameSection:SetTitle(L.DUNGEON_NAME)
    self.TopInfoTabControls.dungeonNameSection = dungeonNameSection

    local dungeonNameFont = Widgets.SettingsMediaFont.Acquire(false, dungeonNameSection)
    dungeonNameFont:SetID(10)
    dungeonNameFont:BindUISetting("keystone.name.mediaFont")
    self.TopInfoTabControls.dungeonNameFont = dungeonNameFont

    local dungeonNameTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, dungeonNameSection)
    dungeonNameTextColorPicker:SetID(20)
    dungeonNameTextColorPicker:SetLabel(L.TEXT_COLOR)
    dungeonNameTextColorPicker:BindUISetting("keystone.name.textColor")
    self.TopInfoTabControls.dungeonNameTextColorPicker = dungeonNameTextColorPicker
  end
  -----------------------------------------------------------------------------
  --                        [TopInfo] Release Builder                        --
  -----------------------------------------------------------------------------
  function ReleaseTopInfoTab(self)
    for index, control in pairs(self.TopInfoTabControls) do 
      control:Release()
      self.TopInfoTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                        [Timers] Tab Builder                             --
  -----------------------------------------------------------------------------
  function AcquireTimersTab(self)
    ---------------------------------------------------------------------------
    --- Timer Section
    ---------------------------------------------------------------------------
    local timerSection = Widgets.ExpandableSection.Acquire(false, self)
    timerSection:SetExpanded(false)
    timerSection:SetID(10)
    timerSection:SetTitle("Timer")
    self.TimersControls.timerSection = timerSection

    local timerFont = Widgets.SettingsMediaFont.Acquire(false, timerSection)
    timerFont:SetID(10)
    timerFont:BindUISetting("keystone.timer.mediaFont")
    self.TimersControls.timerFont = timerFont

    ---------------------------------------------------------------------------
    --- Sub Timers Section
    ---------------------------------------------------------------------------
    local subTimersSection = Widgets.ExpandableSection.Acquire(false, self)
    subTimersSection:SetExpanded(false)
    subTimersSection:SetID(20)
    subTimersSection:SetTitle("Sub Timers")
    self.TimersControls.subTimersSection = subTimersSection

    local subTimersFont = Widgets.SettingsMediaFont.Acquire(false, subTimersSection)
    subTimersFont:SetID(10)
    subTimersFont:BindUISetting("keystone.subTimers.mediaFont")
    self.TimersControls.subTimersFont = subTimersFont
  end
  -----------------------------------------------------------------------------
  --                        [Timers] Release Builder                        --
  -----------------------------------------------------------------------------
  function ReleaseTimersTab(self)
    for index, control in pairs(self.TimersControls) do 
      control:Release()
      self.TimersControls[index] = nil
    end
  end

  -----------------------------------------------------------------------------
  --                        [Enemy Forces] Tab Builder                       --
  -----------------------------------------------------------------------------
  _ENTRIES_KEYSTONE_FORMAT_TYPES_DROPDOWN = Array[Widgets.EntryData]()
  _ENTRIES_KEYSTONE_FORMAT_TYPES_DROPDOWN:Insert({ text = "Only Percent", value = "OnlyPercent"})
  _ENTRIES_KEYSTONE_FORMAT_TYPES_DROPDOWN:Insert({ text = "Only Absolute", value = "OnlyAbsolute"})
  _ENTRIES_KEYSTONE_FORMAT_TYPES_DROPDOWN:Insert({ text = "Absolute And Percent", value = "AbsoluteAndPercent"})
  -- _ENTRIES_KEYSTONE_FORMAT_TYPES_DROPDOWN:Insert({ text = "Custom", value = "Custom"})

  _ENTRIES_KEYSTONE_CURRENT_PULL_FORMAT_TYPES_DROPDOWN = Array[Widgets.EntryData]()
  _ENTRIES_KEYSTONE_CURRENT_PULL_FORMAT_TYPES_DROPDOWN:Insert({ text = "Only Final Percent", value = "OnlyFinalPercent"})
  _ENTRIES_KEYSTONE_CURRENT_PULL_FORMAT_TYPES_DROPDOWN:Insert({ text = "Only Final Count", value = "OnlyFinalCount"})
  _ENTRIES_KEYSTONE_CURRENT_PULL_FORMAT_TYPES_DROPDOWN:Insert({ text = "Only Additive Percent", value = "OnlyAdditivePercent"})
  _ENTRIES_KEYSTONE_CURRENT_PULL_FORMAT_TYPES_DROPDOWN:Insert({ text = "Only Additive Count", value = "OnlyAdditiveCount"})
  -- _ENTRIES_KEYSTONE_CURRENT_PULL_FORMAT_TYPES_DROPDOWN:Insert({ text = "Custom", value = "Custom"})

  function AcquireEnemyForcesTab(self)
    local formatType = Widgets.SettingsDropDown.Acquire(false, self)
    formatType:SetID(10)
    formatType:SetLabel("Format Type")
    formatType:SetEntries(_ENTRIES_KEYSTONE_FORMAT_TYPES_DROPDOWN)
    formatType:BindUISetting("keystone.enemyForces.formatType")
    self.EnemyForcesControls.formatType = formatType

    local currentPullFormatType = Widgets.SettingsDropDown.Acquire(false, self)
    currentPullFormatType:SetID(20)
    currentPullFormatType:SetLabel("Current Pull Format Type")
    currentPullFormatType:SetEntries(_ENTRIES_KEYSTONE_CURRENT_PULL_FORMAT_TYPES_DROPDOWN)
    currentPullFormatType:BindUISetting("keystone.enemyForces.currentPullFormatType")
    self.EnemyForcesControls.currentPullFormatType = currentPullFormatType
    ---------------------------------------------------------------------------
    --- Header Section
    ---------------------------------------------------------------------------
    local headerSection = Widgets.ExpandableSection.Acquire(false, self)
    headerSection:SetExpanded(false)
    headerSection:SetID(30)
    headerSection:SetTitle("Header")
    Style[headerSection].marginTop = 20
    self.EnemyForcesControls.headerSection = headerSection

    local headerFont = Widgets.SettingsMediaFont.Acquire(false, headerSection)
    headerFont:SetID(10)
    headerFont:BindUISetting("keystone.enemyForces.header.mediaFont")
    self.EnemyForcesControls.headerFont = headerFont
  end

  -----------------------------------------------------------------------------
  --                        [Enemy Forces] Release Builder                   --
  -----------------------------------------------------------------------------
  function ReleaseEnemyForcesTab(self)
    for index, control in pairs(self.EnemyForcesControls) do 
      control:Release()
      self.EnemyForcesControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)

    tabControl:AddTabPage({
      name = L.TOP_INFO,
      onAcquire = function() self:BuildTopInfoTab() end,
      onRelease = function() self:ReleaseTopInfoTab() end,
    })

    tabControl:AddTabPage({
      name = "Timers",
      onAcquire = function() self:AcquireTimersTab() end,
      onRelease = function() self:ReleaseTimersTab() end,
    })

    tabControl:AddTabPage({
      name = "Enemy Forces",
      onAcquire = function() self:AcquireEnemyForcesTab() end,
      onRelease = function() self:ReleaseEnemyForcesTab() end
    })
    

    tabControl:Refresh()
    tabControl:SelectTab(1)

    self.SettingControls.tabControl = tabControl
  end

  function ReleaseSettingControls(self)
    self.SettingControls.tabControl:Release()
    self.SettingControls.tabControl = nil

    self:ReleaseTopInfoTab()
    self:ReleaseTimersTab()
    self:ReleaseEnemyForcesTab()
  end

  function OnBuildSettings(self)
    self:BuildSettingControls()
  end 

  function OnRelease(self)
    self:ReleaseSettingControls()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SettingControls" {
    set = false,
    default = function() return newtable(false, true) end 
  }

  property "TopInfoTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "TimersControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "EnemyForcesControls" {
    set = false,
    default = function() return newtable(false, true) end
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Keystone] = {
    height        = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})