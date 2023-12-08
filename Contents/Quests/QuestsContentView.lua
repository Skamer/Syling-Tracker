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
export {
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
}

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
        Style[self].Quests = NIL
      else
        Style[self].Quests.visible = self.Expanded
        local questListView = self:GetPropertyChild("Quests")
        questListView:UpdateView(data.quests, metadata)
        Style[self].Categories = NIL
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

  function SetCategoriesShown(self, show)
    local data = self.Data
    local questsData = data and data.quests
    if questsData then 
      if show then 
        Style[self].Categories.visible = self.Expanded
        local categoriesListView = self:GetPropertyChild("Categories")
        categoriesListView:UpdateView(questsData, self.Metadata)
        Style[self].Quests = NIL     
      else 
        Style[self].Quests.visible = self.Expanded
        local questListView = self:GetPropertyChild("Quests")
        questListView:UpdateView(data.quests, metadata)
        Style[self].Categories = NIL
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "ShowCategories" {
    type = Boolean,
    default = false,
    handler = function(self, new) self:SetCategoriesShown(new) end
  }
end)

__ChildProperty__(QuestsContentView, "Quests")
__UIElement__()
class(tostring(QuestsContentView) .. ".Quests") { QuestListView }

__ChildProperty__(QuestsContentView, "Categories")
__UIElement__()
class(tostring(QuestsContentView) .. ".Categories") { QuestCategoryListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("quests.showCategories", false)

GenerateUISettings("quests", "content")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromQuestsAndCategoriesLocation()
  return FromUISetting("quests.showHeader"):Map(function(visible)
    if visible then 
      return {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    end

    return {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
    }
  end)
end

QuestsContentView.FromQuestsAndCategoriesLocation = FromQuestsAndCategoriesLocation
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestsContentView] = {
    showCategories                    = FromUISetting("quests.showCategories"),

    Header = {
      visible                         = FromUISetting("quests.showHeader"),
      showBackground                  = FromUISetting("quests.header.showBackground"),
      showBorder                      = FromUISetting("quests.header.showBorder"),
      backdropColor                   = FromUISetting("quests.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("quests.header.borderColor"),
      borderSize                      = FromUISetting("quests.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("quests.header.label.mediaFont"),
        textColor                     = FromUISetting("quests.header.label.textColor"),
        justifyH                      = FromUISetting("quests.header.label.justifyH"),
        justifyV                      = FromUISetting("quests.header.label.justifyV"),
        textTransform                 = FromUISetting("quests.header.label.textTransform"),
      }
    },

    [QuestsContentView.Quests] = {
      location                        = FromQuestsAndCategoriesLocation()
    },

    [QuestsContentView.Categories] = {
      location                        = FromQuestsAndCategoriesLocation()
    },
  }
})