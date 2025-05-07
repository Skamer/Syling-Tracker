-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
if not C_AddOns.IsAddOnLoaded("PetTracker") then return end
-- ========================================================================= --
Syling         "SylingTracker_Options.SettingDefinitions.Pets"               ""
-- ========================================================================= --
export {
  L                                   = _Locale,
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.Pets" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  function BuildGeneralTab(self)
    local hideOwnedPetsCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    hideOwnedPetsCheckBox:SetID(10)
    hideOwnedPetsCheckBox:SetLabel("Hide owned pets")
    hideOwnedPetsCheckBox:BindUISetting("pets.hideOwned")
    self.GeneralTabControls.hideOwnedPetsCheckBox = hideOwnedPetsCheckBox

    local petsColumnsSlider = Widgets.SettingsSlider.Acquire(false, self)
    petsColumnsSlider:SetID(20)
    petsColumnsSlider:SetLabel("Columns")
    petsColumnsSlider:SetMinMaxValues(1, 10)
    petsColumnsSlider:BindUISetting("pets.columns")
    self.GeneralTabControls.borderSizeSlider = petsColumnsSlider
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
    showHeaderCheckBox:BindUISetting("pets.showHeader")
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
    showBackgroundCheckBox:BindUISetting("pets.header.showBackground")
    self.HeaderTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindUISetting("pets.header.backgroundColor")
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
    showBorderCheckBox:BindUISetting("pets.header.showBorder")
    self.HeaderTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindUISetting("pets.header.borderColor")
    self.HeaderTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("pets.header.borderSize")
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
    titleFont:BindUISetting("pets.header.label.mediaFont")
    self.HeaderTabControls.titleFont = titleFont

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(false, titleSection)
    textColorPicker:SetID(20)
    textColorPicker:SetLabel(L.TEXT_COLOR)
    textColorPicker:BindUISetting("pets.header.label.textColor")
    self.HeaderTabControls.textColorPicker = textColorPicker

    local textTransform = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textTransform:SetID(30)
    textTransform:SetLabel(L.TEXT_TRANSFORM)
    textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    textTransform:BindUISetting("pets.header.label.textTransform")
    self.HeaderTabControls.textTransform = textTransform

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    textJustifyV:BindUISetting("pets.header.label.justifyV")
    self.HeaderTabControls.textJustifyV = textJustifyV

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    textJustifyH:BindUISetting("pets.header.label.justifyH")
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
  --                        [Pet] Tab Builder                                --
  -----------------------------------------------------------------------------
  function AcquireFixedColorSubOptions(self, parent, baseOrder, prefix, info)
    local fixedColorPickerKey = prefix .. "FixedColorPicker"

    if not self.PetTabControls[fixedColorPickerKey] then
      local fixedColorInfo = info.fixedColor 

      if fixedColorInfo then 
        local fixedColorPicker = Widgets.SettingsColorPicker.Acquire(false, parent)
        fixedColorPicker:SetID(baseOrder + 1)
        fixedColorPicker:SetLabel(fixedColorInfo.label)
        fixedColorPicker:BindUISetting(fixedColorInfo.setting)
        self.PetTabControls[fixedColorPickerKey] = fixedColorPicker
      end
    end
  end

  function ReleaseNameFixedColorSubOptions(self, prefix)
    local fixedColorPicker = self.PetTabControls[prefix.."FixedColorPicker"]
    if fixedColorPicker then 
      fixedColorPicker:Release()
      self.PetTabControls[prefix.."FixedColorPicker"] = nil 
    end
  end

  function BuildPetTab(self)
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(30)
    backgroundSection:SetTitle(L.BACKGROUND)
    Style[backgroundSection].marginTop = 10
    self.PetTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindUISetting("pet.showBackground")
    self.PetTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local useFixedColorBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    useFixedColorBackgroundCheckBox:SetID(20)
    useFixedColorBackgroundCheckBox:SetLabel(L.USE_FIXED_COLOR)
    useFixedColorBackgroundCheckBox:BindUISetting("pet.useFixedColorForBackground")
    self.PetTabControls.useFixedColorBackgroundCheckBox = useFixedColorBackgroundCheckBox

    useFixedColorBackgroundCheckBox:SetUserHandler("OnCheckBoxClick", function(checkbox)
      if checkbox:IsChecked() then 
        self:AcquireFixedColorSubOptions(backgroundSection, 20, "background", {
          fixedColor = { label = L.COLOR, setting = "pet.backgroundColor" }
        })
      else 
        self:ReleaseNameFixedColorSubOptions("background") 
      end 
    
    end)

    if useFixedColorBackgroundCheckBox:IsChecked() then 
      self:AcquireFixedColorSubOptions(backgroundSection, 30, "background", {
        fixedColor = { label = L.COLOR, setting = "pet.backgroundColor" }
      })
    else  
      self:ReleaseNameFixedColorSubOptions("background")
    end
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(40)
    borderSection:SetTitle(L.BORDER)
    self.PetTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindUISetting("pet.showBorder")
    self.PetTabControls.showBorderCheckBox = showBorderCheckBox


    local useFixedColorBoderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    useFixedColorBoderCheckBox:SetID(20)
    useFixedColorBoderCheckBox:SetLabel(L.USE_FIXED_COLOR)
    useFixedColorBoderCheckBox:BindUISetting("pet.useFixedColorForBorder")
    self.PetTabControls.useFixedColorBoderCheckBox = useFixedColorBoderCheckBox

    useFixedColorBoderCheckBox:SetUserHandler("OnCheckBoxClick", function(checkbox)
      if checkbox:IsChecked() then 
        self:AcquireFixedColorSubOptions(borderSection, 20, "border", {
          fixedColor = { label = L.COLOR, setting = "pet.borderColor" }
        })
      else 
        self:ReleaseNameFixedColorSubOptions("border")
      end
    end)

    if useFixedColorBoderCheckBox:IsChecked() then 
      self:AcquireFixedColorSubOptions(borderSection, 30, "border", {
        fixedColor = { label = L.COLOR, setting = "pet.borderColor" }
      })
    else  
      self:ReleaseNameFixedColorSubOptions("border")
    end

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("pet.borderSize")
    self.PetTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Name Section
    ---------------------------------------------------------------------------
    local nameSection = Widgets.ExpandableSection.Acquire(false, self)
    nameSection:SetExpanded(false)
    nameSection:SetID(50)
    nameSection:SetTitle(L.NAME)
    self.PetTabControls.nameSection = nameSection

    local namefont = Widgets.SettingsMediaFont.Acquire(false, nameSection)
    namefont:SetID(10)
    namefont:BindUISetting("pet.name.mediaFont")
    self.PetTabControls.namefont = namefont

    local nameTextTransform = Widgets.SettingsDropDown.Acquire(false, nameSection)
    nameTextTransform:SetID(20)
    nameTextTransform:SetLabel(L.TEXT_TRANSFORM)
    nameTextTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    nameTextTransform:BindUISetting("pet.name.textTransform")
    self.PetTabControls.textTransform = nameTextTransform

    local nameUseFixedColorCheckBox = Widgets.SettingsCheckBox.Acquire(false, nameSection)
    nameUseFixedColorCheckBox:SetID(30)
    nameUseFixedColorCheckBox:SetLabel(L.USE_FIXED_COLOR)
    nameUseFixedColorCheckBox:BindUISetting("pet.name.useFixedColor")
    self.PetTabControls.nameUseFixedColorCheckBox = nameUseFixedColorCheckBox

    nameUseFixedColorCheckBox:SetUserHandler("OnCheckBoxClick", function(checkbox)
      if checkbox:IsChecked() then 
        self:AcquireFixedColorSubOptions(nameSection, 30, "name", {
          fixedColor = { label = L.TEXT_COLOR, setting = "pet.name.fixedColor" }
        })
      else 
        self:ReleaseNameFixedColorSubOptions("name") 
      end 
    
    end)

    if nameUseFixedColorCheckBox:IsChecked() then 
      self:AcquireFixedColorSubOptions(nameSection, 30, "name", {
        fixedColor = { label = L.TEXT_COLOR, setting = "pet.name.fixedColor" }
      })
    else  
      self:ReleaseNameFixedColorSubOptions("name")
    end
  end
  -----------------------------------------------------------------------------
  --                        [Pet] Release Builder                            --
  -----------------------------------------------------------------------------
  function ReleasePetTab(self)
    for index, control in pairs(self.PetTabControls) do 
      control:Release()
      self.PetTabControls[index] = nil
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
      name = L.PET,
      onAcquire = function() self:BuildPetTab() end,
      onRelease = function() self:ReleasePetTab() end,
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
    self:ReleasePetTab()
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

  property "GeneralTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

  property "HeaderTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "PetTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Pets] = {
    height        = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})