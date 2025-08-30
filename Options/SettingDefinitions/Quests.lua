-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.Quests"            ""
-- ========================================================================= --
export {
  L                                   = _Locale,
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.Quests" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  function BuildGeneralTab(self)
    local enablePOICheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    enablePOICheckBox:SetID(10)
    enablePOICheckBox:SetLabel(L.ENABLE_POI)
    enablePOICheckBox:BindUISetting("quest.enablePOI")
    self.GeneralTabControls.enablePOICheckBox = enablePOICheckBox

    if not IsVanilla() then 
      local questNewRemovePoliciesText = Widgets.SettingsText.Acquire(false, self)
      questNewRemovePoliciesText:SetID(30)
      questNewRemovePoliciesText:SetText("A quest is no longer considered new when:")
      self.GeneralTabControls.questNewRemovePoliciesText = questNewRemovePoliciesText

      local questNewMaxAgeSlider = Widgets.SettingsSlider.Acquire(false, self)
      questNewMaxAgeSlider:SetID(40)
      questNewMaxAgeSlider:SetLabel("- it is older than x seconds")
      questNewMaxAgeSlider:SetMinMaxValues(0, 32140800)
      questNewMaxAgeSlider:BindSetting("questNewMaxAge")
      self.GeneralTabControls.questNewMaxAgeSlider = questNewMaxAgeSlider
      Style[questNewMaxAgeSlider].marginLeft = 20

      local questNewRemoveOnProgressCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
      questNewRemoveOnProgressCheckBox:SetID(50)
      questNewRemoveOnProgressCheckBox:SetLabel("- it has received progress")
      questNewRemoveOnProgressCheckBox:BindSetting("questNewRemoveOnProgress")
      self.GeneralTabControls.questNewRemoveOnProgressCheckBox = questNewRemoveOnProgressCheckBox
      Style[questNewRemoveOnProgressCheckBox].marginLeft = 20
    end
    -- ---------------------------------------------------------------------------
    -- --- Background Section
    -- ---------------------------------------------------------------------------
    -- local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    -- backgroundSection:SetExpanded(false)
    -- backgroundSection:SetID(30)
    -- backgroundSection:SetTitle("Background")
    -- Style[backgroundSection].marginTop = 10
    -- self.GeneralTabControls.backgroundSection = backgroundSection

    -- local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    -- showBackgroundCheckBox:SetID(10)
    -- showBackgroundCheckBox:SetLabel("Show Background")
    -- -- showBackgroundCheckBox:BindTrackerSetting(trackerID, "showBackground")
    -- self.GeneralTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    -- local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    -- backgroundColorPicker:SetID(20)
    -- backgroundColorPicker:SetLabel("Background Color")
    -- -- backgroundColorPicker:BindTrackerSetting(trackerID, "backgroundColor")
    -- self.GeneralTabControls.backgroundColorPicker = backgroundColorPicker
    -- ---------------------------------------------------------------------------
    -- --- Border Section
    -- ---------------------------------------------------------------------------
    -- local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    -- borderSection:SetExpanded(false)
    -- borderSection:SetID(40)
    -- borderSection:SetTitle("Border")
    -- self.GeneralTabControls.borderSection = borderSection

    -- local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    -- showBorderCheckBox:SetID(10)
    -- showBorderCheckBox:SetLabel("Show Border")
    -- -- showBorderCheckBox:BindTrackerSetting(trackerID, "showBorder")
    -- self.GeneralTabControls.showBorderCheckBox = showBorderCheckBox

    -- local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    -- borderColorPicker:SetID(20)
    -- borderColorPicker:SetLabel("Border Color")
    -- -- borderColorPicker:BindTrackerSetting(trackerID, "borderColor")
    -- self.GeneralTabControls.borderColorPicker = borderColorPicker

    -- local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    -- borderSizeSlider:SetID(30)
    -- borderSizeSlider:SetLabel("Border Size")
    -- -- borderSizeSlider:BindTrackerSetting(trackerID, "borderSize")
    -- borderSizeSlider:SetMinMaxValues(1, 10)
    -- self.GeneralTabControls.borderSizeSlider = borderSizeSlider
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
  --                      [Header] Tab Builder                               --
  -----------------------------------------------------------------------------
  function BuildHeaderTab(self)
    local showHeaderCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    showHeaderCheckBox:SetID(10)
    showHeaderCheckBox:SetLabel(L.SHOW)
    showHeaderCheckBox:BindUISetting("quests.showHeader")
    self.HeaderTabControls.showHeaderCheckBox = showHeaderCheckBox
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(30)
    backgroundSection:SetTitle(L.BACKGROUND)
    Style[backgroundSection].marginTop = 10
    self.HeaderTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindUISetting("quests.header.showBackground")
    self.HeaderTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindUISetting("quests.header.backgroundColor")
    self.HeaderTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(40)
    borderSection:SetTitle(L.BORDER)
    self.HeaderTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindUISetting("quests.header.showBorder")
    self.HeaderTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindUISetting("quests.header.borderColor")
    self.HeaderTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("quests.header.borderSize")
    self.HeaderTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Title Section
    ---------------------------------------------------------------------------
    local titleSection = Widgets.ExpandableSection.Acquire(false, self)
    titleSection:SetExpanded(false)
    titleSection:SetID(60)
    titleSection:SetTitle(L.TITLE)
    self.HeaderTabControls.titleSection = titleSection

    local titleFont = Widgets.SettingsMediaFont.Acquire(false, titleSection)
    titleFont:SetID(10)
    titleFont:BindUISetting("quests.header.label.mediaFont")
    self.HeaderTabControls.titleFont = titleFont

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(false, titleSection)
    textColorPicker:SetID(20)
    textColorPicker:SetLabel(L.TEXT_COLOR)
    textColorPicker:BindUISetting("quests.header.label.textColor")
    self.HeaderTabControls.textColorPicker = textColorPicker

    local textTransform = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textTransform:SetID(30)
    textTransform:SetLabel(L.TEXT_TRANSFORM)
    textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    textTransform:BindUISetting("quests.header.label.textTransform")
    self.HeaderTabControls.textTransform = textTransform

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    textJustifyV:BindUISetting("quests.header.label.justifyV")
    self.HeaderTabControls.textJustifyV = textJustifyV

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    textJustifyH:BindUISetting("quests.header.label.justifyH")
    self.HeaderTabControls.textJustifyH = textJustifyH
  end
  -----------------------------------------------------------------------------
  --                      [Header] Tab Release                               --
  -----------------------------------------------------------------------------
  function ReleaseHeaderTab(self)
    for index, control in pairs(self.HeaderTabControls) do 
      control:Release()
      self.HeaderTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                     [Category] Tab Builder                              --
  -----------------------------------------------------------------------------
  function BuildCategoryTab(self)
    local showCategories = Widgets.SettingsCheckBox.Acquire(false, self)
    showCategories:SetID(10)
    showCategories:SetLabel(L.SHOW_QUESTS_BY_CATEGORY)
    showCategories:BindUISetting("quests.showCategories")
    -- enableTrackerCheckBox:BindTrackerSetting(trackerID, "enabled")
    self.CategoryTabControls.showCategories = showCategories
    ---------------------------------------------------------------------------
    --- Title Section
    ---------------------------------------------------------------------------
    local titleSection = Widgets.ExpandableSection.Acquire(false, self)
    titleSection:SetExpanded(false)
    titleSection:SetID(60)
    titleSection:SetTitle(L.TITLE)
    self.CategoryTabControls.titleSection = titleSection

    local titleFont = Widgets.SettingsMediaFont.Acquire(false, titleSection)
    titleFont:SetID(10)
    titleFont:BindUISetting("questCategory.name.font")
    self.CategoryTabControls.titleFont = titleFont

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(false, titleSection)
    textColorPicker:SetID(20)
    textColorPicker:SetLabel(L.TEXT_COLOR)
    textColorPicker:BindUISetting("questCategory.name.textColor")
    self.CategoryTabControls.textColorPicker = textColorPicker

    local textTransform = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textTransform:SetID(30)
    textTransform:SetLabel(L.TEXT_TRANSFORM)
    textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    textTransform:BindUISetting("questCategory.name.textTransform")
    self.CategoryTabControls.textTransform = textTransform

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    textJustifyV:BindUISetting("questCategory.name.justifyV")
    self.CategoryTabControls.textJustifyV = textJustifyV

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    textJustifyH:BindUISetting("questCategory.name.justifyH")
    self.CategoryTabControls.textJustifyH = textJustifyH
  end
  -----------------------------------------------------------------------------
  --                     [Category] Release Builder                          --
  -----------------------------------------------------------------------------
  function ReleaseCategoryTab(self)
    for index, control in pairs(self.CategoryTabControls) do 
      control:Release()
      self.CategoryTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                        [Quest] Tab Builder                              --
  -----------------------------------------------------------------------------
  _QUEST_LEVEL_VISIBILITY_POLICY_ENTRIES = Array[Widgets.EntryData]()
  _QUEST_LEVEL_VISIBILITY_POLICY_ENTRIES:Insert({ text = L.ALWAYS_SHOW, value = "AlwaysShow"})
  _QUEST_LEVEL_VISIBILITY_POLICY_ENTRIES:Insert({ text = L.ALWAYS_HIDE, value = "AlwaysHide"})
  _QUEST_LEVEL_VISIBILITY_POLICY_ENTRIES:Insert({ text = L.HIDE_WHEN_CHARACTER_IS_MAX_LEVEL, value = "HideWhenCharIsMaxLevel"})
  _QUEST_LEVEL_VISIBILITY_POLICY_ENTRIES:Insert({ text = L.SHOW_ONLY_WHEN_QUEST_BELOW_MAX_LEVEL, value = "ShowOnlyWhenBelowMaxLevel"})

  function BuildQuestTab(self)
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(30)
    backgroundSection:SetTitle(L.BACKGROUND)
    Style[backgroundSection].marginTop = 10
    self.QuestTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindUISetting("quest.showBackground")
    self.QuestTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorsSection = Widgets.SettingsExpandableSection.Acquire(false, backgroundSection)
    backgroundColorsSection:SetID(20)
    backgroundColorsSection:SetTitle(L.COLORS)
    self.QuestTabControls.backgroundColorsSection = backgroundColorsSection

    local questBackgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundColorsSection)
    questBackgroundColorPicker:SetID(10)
    questBackgroundColorPicker:SetLabel(CreateAtlasMarkup("QuestNormal", 18, 18) .. " " .. L.NORMAL_QUEST)
    questBackgroundColorPicker:SetLabelStyle("small")
    questBackgroundColorPicker:BindUISetting("quest.backgroundColor")
    self.QuestTabControls.questBackgroundColorPicker = questBackgroundColorPicker

    local dungeonQuestBackgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundColorsSection)
    dungeonQuestBackgroundColorPicker:SetID(20)
    dungeonQuestBackgroundColorPicker:SetLabel(CreateAtlasMarkup("Dungeon", 18, 18) .. " " .. L.DUNGEON_QUEST)
    dungeonQuestBackgroundColorPicker:SetLabelStyle("small")
    dungeonQuestBackgroundColorPicker:BindUISetting("dungeonQuest.backgroundColor")
    self.QuestTabControls.dungeonQuestBackgroundColorPicker = dungeonQuestBackgroundColorPicker

    local raidQuestBackgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundColorsSection)
    raidQuestBackgroundColorPicker:SetID(30)
    raidQuestBackgroundColorPicker:SetLabel(CreateAtlasMarkup("Raid", 18, 18) .. " " .. L.RAID_QUEST)
    raidQuestBackgroundColorPicker:SetLabelStyle("small")
    raidQuestBackgroundColorPicker:BindUISetting("raidQuest.backgroundColor")
    self.QuestTabControls.raidQuestBackgroundColorPicker = raidQuestBackgroundColorPicker

    local legendaryQuestBackgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundColorsSection)
    legendaryQuestBackgroundColorPicker:SetID(40)
    legendaryQuestBackgroundColorPicker:SetLabel(CreateAtlasMarkup("quest-legendary-available", 18, 18) .. " " .. L.LEGENDARY_QUEST)
    legendaryQuestBackgroundColorPicker:SetLabelStyle("small")
    legendaryQuestBackgroundColorPicker:BindUISetting("legendaryQuest.backgroundColor")
    self.QuestTabControls.legendaryQuestBackgroundColorPicker = legendaryQuestBackgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(40)
    borderSection:SetTitle(L.BORDER)
    self.QuestTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindUISetting("quest.showBorder")
    self.QuestTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorsSection = Widgets.SettingsExpandableSection.Acquire(false, borderSection)
    borderColorsSection:SetID(20)
    borderColorsSection:SetTitle(L.COLORS)
    self.QuestTabControls.borderColorsSection = borderColorsSection

    local questBorderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderColorsSection)
    questBorderColorPicker:SetID(10)
    questBorderColorPicker:SetLabel(CreateAtlasMarkup("QuestNormal", 18, 18) .. " " .. L.NORMAL_QUEST)
    questBorderColorPicker:SetLabelStyle("small")
    questBorderColorPicker:BindUISetting("quest.borderColor")
    self.QuestTabControls.questBorderColorPicker = questBorderColorPicker

    local dungeonQuestBorderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderColorsSection)
    dungeonQuestBorderColorPicker:SetID(20)
    dungeonQuestBorderColorPicker:SetLabel(CreateAtlasMarkup("Dungeon", 18, 18) .. " " .. L.DUNGEON_QUEST)
    dungeonQuestBorderColorPicker:SetLabelStyle("small")
    dungeonQuestBorderColorPicker:BindUISetting("dungeonQuest.borderColor")
    self.QuestTabControls.dungeonQuestBorderColorPicker = dungeonQuestBorderColorPicker

    local raidQuestBorderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderColorsSection)
    raidQuestBorderColorPicker:SetID(30)
    raidQuestBorderColorPicker:SetLabel(CreateAtlasMarkup("Raid", 18, 18) .. " " .. L.RAID_QUEST)
    raidQuestBorderColorPicker:SetLabelStyle("small")
    raidQuestBorderColorPicker:BindUISetting("raidQuest.borderColor")
    self.QuestTabControls.raidQuestBorderColorPicker = raidQuestBorderColorPicker

    local legendaryQuestBorderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderColorsSection)
    legendaryQuestBorderColorPicker:SetID(40)
    legendaryQuestBorderColorPicker:SetLabel(CreateAtlasMarkup("quest-legendary-available", 18, 18) .. " " .. L.LEGENDARY_QUEST)
    legendaryQuestBorderColorPicker:SetLabelStyle("small")
    legendaryQuestBorderColorPicker:BindUISetting("legendaryQuest.borderColor")
    self.QuestTabControls.legendaryQuestBorderColorPicker = legendaryQuestBorderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("quest.borderSize")
    self.QuestTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Header Section
    ---------------------------------------------------------------------------
    local headerSection = Widgets.ExpandableSection.Acquire(false, self)
    headerSection:SetExpanded(false)
    headerSection:SetID(50)
    headerSection:SetTitle(L.HEADER)
    self.QuestTabControls.headerSection = headerSection

    ---------------------------------------------------------------------------
    --- Header Sub Sections
    ---------------------------------------------------------------------------
    local headertabControl = Widgets.TabControl.Acquire(false, headerSection)
    headertabControl:SetID(50)
    headertabControl:SetID(1)
    headertabControl:AddTabPage({
      name = L.TITLE,
      onAcquire = function()  
        local font = Widgets.SettingsMediaFont.Acquire(false, headertabControl)
        font:SetID(10)
        font:BindUISetting("quest.name.mediaFont")
        self.QuestHeaderTitleTabControls.font = font

        local textTransform = Widgets.SettingsDropDown.Acquire(false, headertabControl)
        textTransform:SetID(20)
        textTransform:SetLabel(L.TEXT_TRANSFORM)
        textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
        textTransform:BindUISetting("quest.name.textTransform")
        self.QuestHeaderTitleTabControls.textTransform = textTransform

        -- local textJustifyV = Widgets.SettingsDropDown.Acquire(false, headertabControl)
        -- textJustifyV:SetID(30)
        -- textJustifyV:SetLabel(L.TEXT_JUSITFY_V)
        -- textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
        -- textJustifyV:BindUISetting("quest.name.justifyV")
        -- self.QuestHeaderTitleTabControls.textJustifyV = textJustifyV
    
        local textJustifyH = Widgets.SettingsDropDown.Acquire(false, headertabControl)
        textJustifyH:SetID(40)
        textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
        textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
        textJustifyH:BindUISetting("quest.name.justifyH")
        self.QuestHeaderTitleTabControls.textJustifyH = textJustifyH

        local textColorsSection = Widgets.SettingsExpandableSection.Acquire(false, headertabControl)
        textColorsSection:SetID(50)
        textColorsSection:SetTitle(L.TEXT_COLORS)
        self.QuestHeaderTitleTabControls.textColorsSection = textColorsSection
    
        local questTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorsSection)
        questTextColorPicker:SetID(10)
        questTextColorPicker:SetLabel(CreateAtlasMarkup("QuestNormal", 18, 18) .. " " .. L.NORMAL_QUEST)
        questTextColorPicker:SetLabelStyle("small")
        questTextColorPicker:BindUISetting("quest.name.textColor")
        self.QuestHeaderTitleTabControls.questTextColorPicker = questTextColorPicker
    
        local dungeonQuestTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorsSection)
        dungeonQuestTextColorPicker:SetID(20)
        dungeonQuestTextColorPicker:SetLabel(CreateAtlasMarkup("Dungeon", 18, 18) .. " " .. L.DUNGEON_QUEST)
        dungeonQuestTextColorPicker:SetLabelStyle("small")
        dungeonQuestTextColorPicker:BindUISetting("dungeonQuest.name.textColor")
        self.QuestHeaderTitleTabControls.dungeonQuestTextColorPicker = dungeonQuestTextColorPicker
    
        local raidQuestTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorsSection)
        raidQuestTextColorPicker:SetID(30)
        raidQuestTextColorPicker:SetLabel(CreateAtlasMarkup("Raid", 18, 18) .. " " .. L.RAID_QUEST)
        raidQuestTextColorPicker:SetLabelStyle("small")
        raidQuestTextColorPicker:BindUISetting("raidQuest.name.textColor")
        self.QuestHeaderTitleTabControls.raidQuestTextColorPicker = raidQuestTextColorPicker
    
        local legendaryQuestTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorsSection)
        legendaryQuestTextColorPicker:SetID(40)
        legendaryQuestTextColorPicker:SetLabel(CreateAtlasMarkup("quest-legendary-available", 18, 18) .. " " .. L.LEGENDARY_QUEST)
        legendaryQuestTextColorPicker:SetLabelStyle("small")
        legendaryQuestTextColorPicker:BindUISetting("legendaryQuest.name.textColor")
        self.QuestHeaderTitleTabControls.legendaryQuestTextColorPicker = legendaryQuestTextColorPicker
      end,
      onRelease = function()  
        for index, control in pairs(self.QuestHeaderTitleTabControls) do 
            control:Release()
            self.QuestHeaderTitleTabControls[index] = nil
        end
      end,
    })

    headertabControl:AddTabPage({
      name = L.LEVEL,
      onAcquire = function()
        local visibilityPolicy = Widgets.SettingsDropDown.Acquire(false, headertabControl)
        visibilityPolicy:SetID(10)
        visibilityPolicy:SetLabel(L.VISIBILITY_POLICY)
        visibilityPolicy:SetEntries(_QUEST_LEVEL_VISIBILITY_POLICY_ENTRIES)
        visibilityPolicy:BindUISetting("quest.level.visibilityPolicy")
        self.QuestHeaderLevelTabControls.visibilityPolicy = visibilityPolicy

        local font = Widgets.SettingsMediaFont.Acquire(false, headertabControl)
        font:SetID(20)
        font:BindUISetting("quest.level.mediaFont")
        self.QuestHeaderLevelTabControls.font = font
      end,
      onRelease = function()
        for index, control in pairs(self.QuestHeaderLevelTabControls) do 
            control:Release()
            self.QuestHeaderLevelTabControls[index] = nil
        end
      end
    })
    
    -- headertabControl:AddTabPage({
    --   name = "Tag Icon",
    --   onAcquire = function() end,
    --   onRelease = function()
    --   end,
    -- })

    local showTooltip =  Widgets.SettingsCheckBox.Acquire(false, self)
    showTooltip:SetID(60)
    showTooltip:SetLabel("Show Tooltip")
    showTooltip:BindUISetting("quest.showTooltip")
    self.QuestTabControls.showTooltip = showTooltip

    if not IsVanilla() then 
      local showNewQuestIndicator =  Widgets.SettingsCheckBox.Acquire(false, self)
      showNewQuestIndicator:SetID(70)
      showNewQuestIndicator:SetLabel("Show New Quest Indicator")
      showNewQuestIndicator:BindUISetting("quest.showNewQuestIndicator")
      self.QuestTabControls.showNewQuestIndicator = showNewQuestIndicator
    end

    local showRewardsInTooltip =  Widgets.SettingsCheckBox.Acquire(false, self)
    showRewardsInTooltip:SetID(80)
    showRewardsInTooltip:SetLabel(("|cffff7f00(%s)|r %s"):format(L.EXPERIMENTAL, "Show Rewards in Tooltip"))
    showRewardsInTooltip:BindUISetting("quest.tooltip.showRewards")
    self.QuestTabControls.showRewardsInTooltip = showRewardsInTooltip

    headertabControl:Refresh()
    headertabControl:SelectTab(1)

    self.QuestTabControls.headertabControl = headertabControl
    ---------------------------------------------------------------------------
    --- Objectives Section
    ---------------------------------------------------------------------------
    -- local objectivesSection = Widgets.ExpandableSection.Acquire(false, self)
    -- objectivesSection:SetExpanded(false)
    -- objectivesSection:SetID(50)
    -- objectivesSection:SetTitle("Objectives")
    -- self.QuestTabControls.objectivesSection = objectivesSection
  end
  -----------------------------------------------------------------------------
  --                        [Quest] Release Builder                          --
  -----------------------------------------------------------------------------
  function ReleaseQuestTab(self)
    for index, control in pairs(self.QuestTabControls) do 
      control:Release()
      self.QuestTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)
    tabControl:AddTabPage({
      name = L.GENERAL,
      onAcquire = function() self:BuildGeneralTab() end,
      onRelease = function() self:ReleaseGeneralTab() end,
    })
    
    tabControl:AddTabPage({
      name = L.HEADER,
      onAcquire = function() self:BuildHeaderTab() end,
      onRelease = function() self:ReleaseHeaderTab() end,
    })

    tabControl:AddTabPage({
      name = L.CATEGORY,
      onAcquire = function() self:BuildCategoryTab() end,
      onRelease = function() self:ReleaseCategoryTab() end,
    })

    tabControl:AddTabPage({
      name = L.QUEST,
      onAcquire = function() self:BuildQuestTab() end,
      onRelease = function() self:ReleaseQuestTab() end,
    })
    

    tabControl:Refresh()
    tabControl:SelectTab(1)

    self.SettingControls.tabControl = tabControl
  end

  function ReleaseSettingControls(self)
    self.SettingControls.tabControl:Release()
    self.SettingControls.tabControl = nil

    self:ReleaseGeneralTab()
    self:ReleaseHeaderTab()
    self:ReleaseCategoryTab()
    self:ReleaseQuestTab()
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

  property "HeaderTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "CategoryTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "QuestTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "QuestHeaderTitleTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

  property "QuestHeaderLevelTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Quests] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})