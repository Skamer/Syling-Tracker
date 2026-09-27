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
  FromUIProperty                      = Wow.FromUIProperty,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
  GetCacheValue                       = API.GetCacheValue,
  SetCacheValue                       = API.SetCacheValue
}

__UIElement__()
class "QuestsContentFilterBarItem" (function(_env)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Matches(self, value)
    if self.FilterState == nil or self.Filter == nil then 
      return true 
    end

    local isMatch = (self.Filter(value) == true)

    return isMatch == self.FilterState
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Handler" {
    type = Function
  }

  property "Filter" {
    type = Function
  }

  property "id" {
    type = Any
  }

  __Observable__()
  property "FilterState" {
    type = Boolean,
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon = Texture,
    ExclusionIcon = Texture,
  }
  function __ctor(self)
    self.OnClick = self.OnClick + function()
      if self.FilterState == nil then
          self.FilterState = true
      elseif self.FilterState == true then
          self.FilterState = false
      else
          self.FilterState = nil
      end

      self.Handler(self.FilterState)
    end
  end

end)

__UIElement__()
class "QuestsContentView"(function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    self:UpdateCacheID(metadata)

    local showCategories = self.ShowCategories
    
    if data and data.quests then
      local questsData = self:ApplyFilters(data.quests)
      
      if showCategories then
        Style[self].Categories.visible = self.Expanded
        local categoriesListView = self:GetPropertyChild("Categories")
        categoriesListView:UpdateView(questsData, metadata)
        Style[self].Quests = NIL
      else
        Style[self].Quests.visible = self.Expanded
        local questListView = self:GetPropertyChild("Quests")
        questListView:UpdateView(questsData, metadata)
        Style[self].Categories = NIL
      end
    else
      Style[self].Quests = NIL
      Style[self].Categories = NIL
    end 
  end

  function OnExpand(self)
    Style[self].FilterBar.visible = true

    if self:GetPropertyChild("Quests") then 
      Style[self].Quests.visible = true 
    end

    if self:GetPropertyChild("Categories") then 
      Style[self].Categories.visible = true 
    end
  end

  function OnCollapse(self)
    Style[self].FilterBar.visible = false

    if self:GetPropertyChild("Quests") then 
      Style[self].Quests.visible = false
    end

    if self:GetPropertyChild("Categories") then 
      Style[self].Categories.visible = false
    end
  end

  function HasAnyFilter(self)
    return self.FilterInZoneQuests ~= nil 
    or self.FilterCompletedQuests ~= nil
    or self.FilterDungeonQuests ~= nil 
    or self.FilterRaidQuests ~= nil
  end

  function ApplyFilters(self, questsData)
    if not self:HasAnyFilter() then
        return questsData
    end

    local resultsData = {}
    local filterBar = self:GetChild("FilterBar")

    for questID, questData in pairs(questsData) do 
      local keepQuest = true 

      for i = 1, filterBar.Count do 
        local filterButton = filterBar.Elements[i]

        if not filterButton:Matches(questData) then 
          keepQuest = false 
          break;
        end 
      end

      if keepQuest then 
        resultsData[questID] = questData 
      end
    end

    return resultsData
  end

  function RegisterFilters(self)
    local filters = {
      { 
        id = "FilterInZoneQuests",
        order = 1,
        icon = { from = "svg", value = [[Interface\AddOns\SylingTracker\Media\Textures\Icons\zone.svg]]},
        filter = function(questData)
            local currentZone = GetRealZoneText()
            local currentMinimapZone = GetMinimapZoneText()
            local header = questData.header

            return questData.isOnMap or questData.hasLocalPOI or header == currentZone or header == currentMinimapZone
        end,
      },
      {
        id = "FilterCompletedQuests",
        order = 2,
        icon = { from = "atlas", value = AtlasType("QuestTurnin")},
        filter = function(questData) return questData.isComplete end,
      },
      {
        id = "FilterDungeonQuests",
        order = 3,
        icon = { from = "atlas", value = AtlasType("questlog-questtypeicon-dungeon")},
        filter = function(questData) return questData.isDungeon end, 
      },
      { 
        id = "FilterRaidQuests", 
        order = 4,
        icon = { from = "atlas", value = AtlasType("questlog-questtypeicon-raid")},
        filter = function(questData) return questData.isRaid end,
      }
    }

    table.sort(filters, function(a, b) return (a.order or 0) < (b.order or 0) end)

    local filterBar = self:GetChild("FilterBar")
    filterBar.Count = #filters

    for index, definition in ipairs(filters) do 
      local filterButton = filterBar.Elements[index]
      filterButton.id = definition.id
      Style[filterButton].Icon.mediaTexture = definition.icon
      filterButton.Filter = definition.filter
      filterButton.Handler = function(value)
        self[definition.id] = value 
        self:InstantRefreshView()
      end
    end
  end


  function SetCategoriesShown(self, show)
    local data = self.Data
    local questsData = data and data.quests
    if questsData then 
      if show then 
        Style[self].Categories.visible = self.Expanded
        local categoriesListView = self:GetPropertyChild("Categories")
        categoriesListView:UpdateView(self:ApplyFilters(questsData), self.Metadata)
        Style[self].Quests = NIL     
      else 
        Style[self].Quests.visible = self.Expanded
        local questListView = self:GetPropertyChild("Quests")
        questListView:UpdateView(self:ApplyFilters(questsData), metadata)
        Style[self].Categories = NIL
      end
    end
  end

  function UpdateCacheID(self, metadata)
    local trackerID = metadata.trackerID
    local contentID = metadata.contentID 

    if trackerID == nil or contentID == nil then 
      return 
    end 

    self.CacheID = trackerID .. "_" .. contentID .. "_QuestsContentView"
  end

  function LoadFromCache(self)
    if self.CacheID == nil then 
      return 
    end

    local filterBar = self:GetChild("FilterBar")

    for i = 1, filterBar.Count do 
      local filterButton = filterBar.Elements[i]
      local id = filterButton.id
      if id then 
        local value = GetCacheValue(self.CacheID, id)

        -- we set the field directly for avoiding to retrigger a SaveToCache as this 
        -- useless after a cache loading
        self["__"..id] = value

        -- Update the button state from cache 
        filterButton.FilterState = value
      end 
    end
  end

  function SaveToCache(self, key, value)

    if self.CacheID == nil then 
      return 
    end

    SetCacheValue(self.CacheID, key, value)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "CacheID" {
    type = String,
    handler = function(self, new) self:LoadFromCache() end
  }

  property "ShowCategories" {
    type = Boolean,
    default = false,
    handler = function(self, new) self:SetCategoriesShown(new) end
  }

  -- Important: Don't forget to use field for filter properties.
  property "FilterInZoneQuests" { 
    type = Boolean,
    field = "__FilterInZoneQuests", 
    handler = function(self, new, _, prop) self:SaveToCache(prop, new) end 
  }

  property "FilterCompletedQuests" { 
    type = Boolean,
    field = "__FilterCompletedQuests", 
    handler = function(self, new, _, prop) self:SaveToCache(prop, new) end 
  }

  property "FilterDungeonQuests" { 
    type = Boolean, 
    field = "__FilterDungeonQuests", 
    handler = function(self, new, _, prop) self:SaveToCache(prop, new) end 
  }
  property "FilterRaidQuests" { 
    type = Boolean,
    field = "__FilterRaidQuests", 
    handler = function(self, new, _, prop) self:SaveToCache(prop, new) end 
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    FilterBar = ElementPanel
  } function __ctor(self)
    -- We need instant apply style for having a valid elementType
    self:GetChild("FilterBar"):InstantApplyStyle()

    self:RegisterFilters()
  end

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
        Anchor("TOP", 0, -10, "FilterBar", "BOTTOM"),
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
  [QuestsContentFilterBarItem] = {
    registerForClicks                 = { "AnyDown"},
    alpha                             = FromUIProperty("FilterState"):Map(function(state)
                                          return state ~= nil and 1 or 0.35
                                      end),

    Icon = {
      setAllPoints                    = true,
    },

    ExclusionIcon = {
      visible                         = FromUIProperty("FilterState"):Map(function(state)
                                          return state == false
                                      end),
      setAllPoints                    = true,
      drawLayer                       = "OVERLAY",
      svg                             = [[Interface\AddOns\SylingTracker\Media\Textures\Icons\redslash.svg]],
    }
  },

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

    FilterBar = {
      elementType                     = QuestsContentFilterBarItem,
      elementHeight                   = 24,
      elementWidth                    = 24,

      hSpacing                        = 5,
      vSpacing                        = 5,
      leftToRight                     = true,
      
      location                        = {
                                        Anchor("TOP", 0, -10, "Header", "BOTTOM" ),
                                        Anchor("LEFT"), Anchor("RIGHT")
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