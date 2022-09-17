-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker_Options"                          ""
-- ========================================================================= --
local ADDON_LOGO = [[Interface\AddOns\SylingTracker_Options\Media\logo_white]]

function OnLoad(self)
  local panel = SUI.Panel("Panel", UIParent)
  panel:SetPoint("CENTER")
  panel:SetTitle("SylingTracker Options")
  panel:SetAddonVersion("1.0.2")
  panel:SetAddonLogo(ADDON_LOGO)
  panel:CreateCategory("general", "")
  panel:CreateCategory("trackers", "Trackers")
  panel:CreateCategory("contents", "Contents")
  panel:CreateCategory("advanced", "Advanced")

  panel:AddCategoryEntry({ text = "General"}, "general")
  panel:AddCategoryEntry({ text = "Item Bar"}, "general")
  panel:AddCategoryEntry({ text = "Profiles"}, "general")

  panel:AddCategoryEntry({ text = "Main"}, "trackers")
  panel:AddCategoryEntry({ text = "Mythic +"}, "trackers")

  panel:AddCategoryEntry({ text = "Quests"}, "contents")
  panel:AddCategoryEntry({ text = "Campaign"}, "contents")
  panel:AddCategoryEntry({ text = "World Quests"}, "contents")
  panel:AddCategoryEntry({ text = "Dungeon"}, "contents")
  panel:AddCategoryEntry({ text = "Keystone"}, "contents")
  panel:AddCategoryEntry({ text = "Achievements"}, "contents")
  panel:AddCategoryEntry({ text = "Torghast"}, "contents")

  panel:AddCategoryEntry({ text = "Skins"}, "advanced")
  panel:Refresh()
end