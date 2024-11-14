-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling        "SylingTracker_Options.SettingDefinitions.AutoQuests"          ""
-- ========================================================================= --
export {
  L                                   = _Locale,
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.AutoQuests" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildAutoQuestTab(self)
    ---------------------------------------------------------------------------
    -- [Auto Quest] Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(100)
    backgroundSection:SetTitle(L.BACKGROUND)
    Style[backgroundSection].marginTop = 10
    self.AutoQuestTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(100)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindUISetting("autoQuest.showBackground")
    self.AutoQuestTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(200)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindUISetting("autoQuest.backgroundColor")
    self.AutoQuestTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    -- [Auto Quest] Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(200)
    borderSection:SetTitle(L.BORDER)
    self.AutoQuestTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(100)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindUISetting("autoQuest.showBorder")
    self.AutoQuestTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(200)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindUISetting("autoQuest.borderColor")
    self.AutoQuestTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(300)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("autoQuest.borderSize")
    self.AutoQuestTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    -- [Auto Quest] Header Section
    ---------------------------------------------------------------------------
    local headerSection = Widgets.ExpandableSection.Acquire(false, self)
    headerSection:SetExpanded(false)
    headerSection:SetID(300)
    headerSection:SetTitle(L.HEADER)
    self.AutoQuestTabControls.headerSection = headerSection

    local headerTextFont = Widgets.SettingsMediaFont.Acquire(false, headerSection)
    headerTextFont:SetID(100)
    headerTextFont:BindUISetting("collections.header.label.mediaFont")
    self.AutoQuestTabControls.headerTextFont = headerTextFont

    local headerTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, headerSection)
    headerTextColorPicker:SetID(200)
    headerTextColorPicker:SetLabel(L.TEXT_COLOR)
    headerTextColorPicker:BindUISetting("collections.header.label.textColor")
    self.AutoQuestTabControls.headerTextColorPicker = headerTextColorPicker

    local headerTextTransform = Widgets.SettingsDropDown.Acquire(false, headerSection)
    headerTextTransform:SetID(300)
    headerTextTransform:SetLabel(L.TEXT_TRANSFORM)
    headerTextTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    headerTextTransform:BindUISetting("collections.header.label.textTransform")
    self.AutoQuestTabControls.headerTextTransform = headerTextTransform

    local headerTextJustifyH = Widgets.SettingsDropDown.Acquire(false, headerSection)
    headerTextJustifyH:SetID(400)
    headerTextJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    headerTextJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    headerTextJustifyH:BindUISetting("collections.header.label.justifyH")
    self.AutoQuestTabControls.headerTextJustifyH = headerTextJustifyH
  end

  function ReleaseAutoQuestTab(self)
    for index, control in pairs(self.AutoQuestTabControls) do 
      control:Release()
      self.AutoQuestTabControls[index] = nil
    end
  end

  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)
    tabControl:AddTabPage({
      name = L.AUTO_QUEST,
      onAcquire = function() self:BuildAutoQuestTab() end, 
      onRelease = function() self:ReleaseAutoQuestTab() end, 
    })

    tabControl:Refresh()
    tabControl:SelectTab(1)

    self.SettingControls.tabControl = tabControl
  end

  function ReleaseSettingControls(self)
    for k, control in pairs(self.SettingControls) do 
      control:Release() 
      self.SettingControls[k] = nil
    end
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

  property "AutoQuestTabControls" {
    set = false ,
    default = function() return newtable(false, true) end 
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.AutoQuests] = {
    height = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})

