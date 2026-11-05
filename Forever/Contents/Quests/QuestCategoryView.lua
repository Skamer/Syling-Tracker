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
  newtable                            = System.Toolset.newtable,
  FromUIProperty                      = Wow.FromUIProperty,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  GetUISetting                        = API.GetUISetting
}

__UIElement__()
class "QuestCategoryView" (function(_ENV)
  inherit "Frame" extend "IView" "IQueueAdjustHeight" "ISizeAnimation"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnExpandedHandler(self, new, old)
    if new then 
      self:OnExpand()
    else
      self:OnCollapse()
    end

    self:AdjustHeight()
  end
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnExpand(self)
    if self:GetPropertyChild("Quests") then 
      Style[self].Quests.visible = true
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Quests") then 
      Style[self].Quests.visible = false 
    end
  end

  function OnViewUpdate(self, data, metadata)

    Style[self].Quests.visible = self.Expanded
    local questListView = self:GetPropertyChild("Quests")
    questListView:UpdateView(data, metadata)

    local id, firstQuestData = next(data)
    self.CategoryName = firstQuestData and firstQuestData.category
  end


  function OnAdjustHeight(self)
    local height = self:TryToComputeHeightFromChildren()
    if height then 
      self:AnimateToTargetHeight(height)
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "CategoryName" {
    type = String,
    default = ""
  }

  __Observable__()
  property "Expanded" {
    type = Boolean,
    default = true,
    handler = OnExpandedHandler
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Button,
    {
      Header = {
        Name = FontString
      }
    }
  }
  function __ctor(self) 
    local header = self:GetChild("Header")
    header.OnClick = header.OnClick + function()
      self.Expanded = not self.Expanded
    end
  end
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
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromNameColor()
  return FromUIProperty("Expanded"):Map(function(expanded)
    local color = API.GetUISetting("questCategory.name.textColor")

    if expanded then 
      return color 
    else 
      return Color(color.r, color.g, color.b, color.a and color.a * 0.5 or 0.5)
    end
  end)
end
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("questCategory.name.font", FontType("PT Sans Narrow Bold", 12, "NORMAL"))
RegisterUISetting("questCategory.name.textColor", Color(1, 0.39, 0))
RegisterUISetting("questCategory.name.textTransform", "UPPERCASE")
RegisterUISetting("questCategory.name.justifyH", "LEFT")
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestCategoryView] = {
    autoAdjustHeight                    = true,

    Header = {
      height                            = 1,
      autoAdjustHeight                  = true,
      Name = {
        text                            = FromUIProperty("CategoryName"),
        mediaFont                       = FromUISetting("questCategory.name.font"),
        textColor                       = FromNameColor(),
        textTransform                   = FromUISetting("questCategory.name.textTransform"),
        justifyH                        = FromUISetting("questCategory.name.justifyH"),
        location                        = {
                                        Anchor("TOP"),
                                        Anchor("LEFT", 10, 8),
                                        Anchor("RIGHT")
                                        }
      },
        location                        = {
                                        Anchor("TOP"),
                                        Anchor("LEFT", 10, 8),
                                        Anchor("RIGHT")
                                        }

    },

    [QuestCategoryView.Quests] = {
      location                        = {
                                      Anchor("TOP", 0, -13, "Header", "BOTTOM"),
                                      Anchor("LEFT"),
                                      Anchor("RIGHT")
                                      }
    }
  },

  [QuestCategoryListView] = {
    viewClass                         = QuestCategoryView,
  }
})