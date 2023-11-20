-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.QuestsContentView"            ""
-- ========================================================================= -
__UIElement__()
class "QuestsContentView"(function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    
    local showCategories = self.ShowCategories
    
    if data and data.quests then
      
      if showCategories then
        Style[self].Categories.visible = self.Expanded
        local categoriesListView = self:GetPropertyChild("Categories")
        categoriesListView:UpdateView(data.quests, metadata)
      else
        Style[self].Quests.visible = self.Expanded
        local questListView = self:GetPropertyChild("Quests")
        questListView:UpdateView(data.quests, metadata)
      end
    else
      Style[self].Quests = NIL
      Style[self].Categories = NIL
    end 
  end

  function OnExpand(self)
    if self:GetPropertyChild("Quests") then 
      Style[self].Quests.visible = true 
    end

    if self:GetPropertyChild("Categories") then 
      Style[self].Categories.visible = true 
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Quests") then 
      Style[self].Quests.visible = false
    end

    if self:GetPropertyChild("Categories") then 
      Style[self].Categories.visible = false
    end
  end

  property "ShowCategories" {
    type = Boolean,
    default = true
  }
end)

__ChildProperty__(QuestsContentView, "Quests")
__UIElement__()
class(tostring(QuestsContentView) .. ".Quests") { QuestListView }

__ChildProperty__(QuestsContentView, "Categories")
__UIElement__()
class(tostring(QuestsContentView) .. ".Categories") { QuestCategoryListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestsContentView] = {
    [QuestsContentView.Quests] = {
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    [QuestsContentView.Categories] = {
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },
  }
})