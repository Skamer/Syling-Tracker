-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker_Options.Bootstrap"                      ""
-- ========================================================================= --

LOGO_WHITE = [[Interface\AddOns\SylingTracker_Options\Media\logo_white]]
SETTINGS_PANEL = nil 

__SystemEvent__()
__Async__() function SylingTracker_OPEN_OPTIONS()
  if not SETTINGS_PANEL then 
    local panel = Widgets.SettingsPanel.Acquire()
    panel:Hide()
    panel:SetParent(UIParent)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("HIGH")
    panel:SetTitle("Syling Tracker Options")
    panel:EnableMouse(true)
    panel:SetAddonVersion("2.0.0")
    panel:SetAddonLogo(LOGO_WHITE)
    panel:InstantApplyStyle()
    
    --- Create categories
    panel:CreateCategory("general", "General")
    panel:CreateCategory("trackers", "My Trackers")
    panel:CreateCategory("contents", "Contents")
    -- panel:CreateCategory("userContents", "My Contents")

    panel:AddCategoryEntry({ text = "Settings" }, "general")
    panel:AddCategoryEntry({ text = "Media"}, "general")
    panel:AddCategoryEntry({ text = "Item Bar" }, "general")
    panel:AddCategoryEntry({ text = "Context Menu"}, "general")
    panel:AddCategoryEntry({ text = "Objective", value = SettingDefinitions.Objective}, "general")

    -- My Trackers entries 
    _M:CreateTrackerEntries(panel)

    -- Contents entries
    panel:AddCategoryEntry({ text = "Quests"}, "contents")
    panel:AddCategoryEntry({ text = "World Quests"}, "contents")
    panel:AddCategoryEntry({ text = "Bonus objectives"}, "contents")
    panel:AddCategoryEntry({ text = "Scenario"}, "contents")
    panel:AddCategoryEntry({ text = "Mythic +"}, "contents")
    panel:AddCategoryEntry({ text = "Dungeon"}, "contents")
    panel:AddCategoryEntry({ text = "Achievements"}, "contents")
    panel:AddCategoryEntry({ text = "Torghast"}, "contents")
    panel:AddCategoryEntry({ text = "Quests"}, "contents")
    
    --- Refresh the panel for creating entries
    panel:Refresh()

    for i = 1, 6 do 
      Next()
    end

    SETTINGS_PANEL = panel 
  end

  SETTINGS_PANEL:Show()
end

function CreateTrackerEntries(self, panel)
  panel:AddCategoryEntry({ 
    text = "|A:tradeskills-icon-add:16:16|a |cff00ff00Create a tracker|r",
    value = SettingDefinitions.CreateTracker,
    styles = {
      marginTop = 10
    }
  }, "trackers")
end