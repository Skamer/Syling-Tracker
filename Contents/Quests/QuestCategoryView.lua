-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.QuestCategoryView"            ""
-- ========================================================================= -
export {
  newtable = System.Toolset.newtable,
  FromUIProperty = Wow.FromUIProperty,
}

__UIElement__()
class "QuestCategoryView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    Style[self].Quests.visible = true 
    local questListView = self:GetPropertyChild("Quests")
    questListView:UpdateView(data, metadata)

    local id, firstQuestData = next(data)
    self.CategoryName = firstQuestData and firstQuestData.category
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "CategoryName" {
    type = String,
    default = ""
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Name = FontString
  }
  function __ctor(self) end
end)

__ChildProperty__(QuestCategoryView, "Quests")
__UIElement__()
class(tostring(QuestCategoryView) .. ".Quests") { QuestListView }


__UIElement__()
class "QuestCategoryListView" (function(_ENV)
  inherit "ListView"

  __Iterator__()
  function IterateData(self, data, metadata)
    wipe(self.CategoriesRange)
    wipe(self.CategoriesData)
    wipe(self.CategoriesOrder)

    local yield = coroutine.yield

    if data then
      -- 1. Split the quests data in their respective category
      for questID, questData in pairs(data) do 
        local categoryName = questData.category
        local categoryData = self.CategoriesData[categoryName]
        if not categoryData then 
          categoryData = newtable(false, true)
          self.CategoriesData[categoryName] = categoryData
          tinsert(self.CategoriesOrder, categoryName)
        end

        local bestRange = self.CategoriesRange[categoryName]
        if not bestRange or questData.distance < bestRange then 
          self.CategoriesRange[categoryName] = questData.distance or 99999
        end

        categoryData[questID] = questData
      end

      -- 2. Sort the category by their best range 
      table.sort(self.CategoriesOrder, function(a, b)
        return self.CategoriesRange[a] < self.CategoriesRange[b]
      end)

      -- 3. Yield the results
      for index, categoryName in ipairs(self.CategoriesOrder) do 
        yield(categoryName, self.CategoriesData[categoryName], metadata)
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "CategoriesData" {
    set = false, 
    default = function() return {} end 
  }

  property "CategoriesRange" {
    set = false, 
    default = function() return {} end
  }

  property "CategoriesOrder" {
    set = false, 
    default = function() return {} end
  }
end)

-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestCategoryView] = {
    -- height = 32,
    -- minResize = { width = 0, height = 32},
    clipChildren = true,
    autoAdjustHeight = true,

    Name = {
      text = FromUIProperty("CategoryName"),
      mediaFont =  FontType("PT Sans Narrow Bold", 12),
      textColor = Color(1, 0.39, 0),
      textTransform = "UPPERCASE", 
      justifyH = "LEFT",
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 10, 8),
        Anchor("RIGHT")
      }
    },

    [QuestCategoryView.Quests] = {
      location = {
        Anchor("TOP", 0, -13, "Name", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  },

  [QuestCategoryListView] = {
    viewClass = QuestCategoryView,
  }
})

function OnLoad(self)
  local object = QuestCategoryView("testCategory", UIParent)
  object:SetPoint("CENTER")
end