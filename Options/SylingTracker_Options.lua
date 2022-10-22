-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Options"                          ""
-- ========================================================================= --
SLT_LOGO_WHITE = [[Interface\AddOns\SylingTracker_Options\Media\logo_white]]

_SETTINGS_PANEL = nil

--- Create the text transform  entries
TEXT_TRANSFORM_ENTRIES = Array[SUI.EntryData]()
TEXT_TRANSFORM_ENTRIES:Insert({ text = "Normal"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = "UPPERCASE"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = "lowercase"})

__SystemEvent__()
function SLT_OPEN_OPTIONS()
  if not _SETTINGS_PANEL then 
      local panel = SUI.SettingsPanel.Acquire()
      panel:SetParent(UIParent)
      panel:SetPoint("CENTER")
      panel:SetTitle("SylingTracker Options")
      panel:SetAddonVersion(SLT_VERSION)
      panel:SetAddonLogo(SLT_LOGO_WHITE)
      panel:InstantApplyStyle()

      --- Create categories
      panel:CreateCategory("general", "General")

      --- General category entries
      panel:AddCategoryEntry({ text = "Settings", value = SLT.SettingDefinitions.General}, "general")

      --- Refresh the panel for creating entries
      panel:Refresh()

      --- We select the first entry of general category
      panel:SelectEntry("general", 1)

      _SETTINGS_PANEL = panel
  end

  _SETTINGS_PANEL:Show()
end

__SystemEvent__()
function SLT_CLOSE_OPTIONS()
  if _SETTINGS_PANEL then 
    _SETTINGS_PANEL:Hide() 
  end
end