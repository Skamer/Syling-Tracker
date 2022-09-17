-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Elements.CategoryList"            ""
-- ========================================================================= --

__Widget__()
class "SUI.CategoryEntryButton" (function(_ENV)
  inherit "Button" extend "SUI.IButtonEntry"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------  
  __Arguments__ { SUI.EntryData }
  function SetupFromEntryData(self, data)
    Style[self].Label.text = data.text or ""
  end

  function RefreshState(self)
    local label = self:GetChild("Label")
    local texture = self:GetChild("Texture")
    if self.selected then 
      label:SetFontObject("GameFontHighlight")
      texture:SetAtlas("Options_List_Active", true)
      texture:Show()
    else
       label:SetFontObject("GameFontNormal")
       if self:IsMouseOver() then 
          texture:SetAtlas("Options_List_Hover", true)
          texture:Show()
       else 
          texture:Hide()
       end
    end
  end

  property "selected" {
    type = Boolean,
    default = false,
    handler = RefreshState
  }

  __Template__ {
    Label = FontString,
    Texture = Texture
  }
  function __ctor(self)
    self.OnEnter = self.OnEnter + function() self:RefreshState() end
    self.OnLeave = self.OnLeave + function() self:RefreshState() end 
    self.OnClick = self.OnClick + function() self.selected = true end
  end

end)

__Widget__()
class "SUI.CategoryHeader" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Label = FontString
  }
  function __ctor(self) end 

end)

__Widget__()
class "SUI.Category" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Number/nil }
  function SetSelectedByIndex(self, selectedIndex)
    local previousSelectedIndex = self.__selectedIndex
    local previousSelectedEntry = nil 

    if previousSelectedIndex then 
      previousSelectedEntry = self.Entries[previousSelectedIndex]

      if previousSelectedEntry then
        previousSelectedEntry.selected = false 
        self.__selectedIndex = nil 
      end 
    end

    if selectedIndex then 
      local selectedEntry = self.Entries[selectedIndex]
      if selectedEntry then 
        selectedEntry.selected = true 
        self.__selectedIndex = selectedIndex
      end
    end
  end

  __Arguments__ { ( SUI.IEntry)/nil }
  function SetSelectedByEntry(self, selectedEntry)
    local selectedIndex = nil

    if selectedEntry then 
      for index, entry in pairs(self.Entries) do
        if entry == selectedEntry then
          selectedIndex = index
        end
      end
    end

    self:SetSelectedByIndex(selectedIndex)
  end

  function GetEntryIndex(self, entry)
    for index, e in pairs(self.Entries) do 
      if e == entry then 
        return index 
      end
    end
  end

  __Arguments__ { Number, (-SUI.IEntry)/nil }
  function AcquireEntry(self, index, entryClass)
    entryClass = entryClass or self.DefaultEntryClass

    local entry = entryClass.Acquire()

    
    entry:SetParent(self)
    entry:SetID(index)
    
    --- If the Entry is a button, register onClick
    if Class.IsObjectType(entry, SUI.IButtonEntry) then 
      entry.OnClick = entry.OnClick + self.OnEntryClickHandler
    end

    self.Entries[index] = entry

    return entry
  end

  function ReleaseEntries(self)
    for index, entry in pairs(self.Entries) do 
      --- If the Entry is a button, remove onClick
      if Class.IsObjectType(entry, SUI.IButtonEntry) then 
        entry.OnClick = entry.OnClick - self.OnEntryClickHandler
      end

      entry:Release()

      self.Entries[index] = nil
    end
  end

  function Refresh(self)
    self:ReleaseEntries()

    for index, entryData in self.EntriesData:GetIterator() do 
      local entry = self:AcquireEntry(index, entryData.widgetClass)
      entry:SetupFromEntryData(entryData)
    end
  end

  __Arguments__ { EntryData }
  function AddEntry(self, entry)
    self.EntriesData:Insert(entry)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  ----------------------------------------------------------------------------- 
  property "Entries" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }

  property "EntriesData" {
    set = false,
    default = function() return Array[SUI.EntryData]() end
  }

  property "DefaultEntryClass" {
    type = -SUI.IEntry,
    default = SUI.CategoryEntryButton
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = SUI.CategoryHeader
  }
  function __ctor(self)
    -- Create the event handlers 
    self.OnEntryClickHandler = function(entry, ...)
      local index = self:GetEntryIndex(entry)
      self:SetSelectedByIndex(index) 

      self:OnEntrySelected(entry, self.EntriesData[index])
    end
  end

end)


__Widget__()
class "SUI.CategoryList" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String }
  function AcquireCategory(self, id)
    return self.Categories[id]
  end

  __Arguments__ { String, String/"" }
  function CreateCategory(self, id, text)
    
    -- A category must have a id different than others categories already 
    -- added
    if self:AcquireCategory(id) then 
      return 
    end

    local category = SUI.Category.Acquire() 
    local index = self.CategoriesCount + 1

    category:SetParent(self)
    category:SetID(index)

    Style[category].Header.Label.text = text

    category.OnEntrySelected = category.OnEntrySelected + self.OnCategoryEntrySelectedHandler

    self.Categories[id] = category
    self.CategoriesCount = index
  end

  __Arguments__ { SUI.EntryData, String }
  function AddCategoryEntry(self, entryData, categoryId)
    local category = self:AcquireCategory(categoryId)

    if category then 
      category:AddEntry(entryData)
    end 
  end

  function Refresh(self)
    for _, category in pairs(self.Categories) do 
      category:Refresh()
    end 
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Categories" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }

  property "CategoriesCount" {
    type = Number,
    default = 0
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    self.OnCategoryEntrySelectedHandler = function(category, entry, entryData)
      for id, c in pairs(self.Categories) do 
        if c ~= category then 
          c:SetSelectedByIndex()
        end

        self:OnEntrySelected(entry, entryData)
      end
    end
  end
end)

-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.CategoryEntryButton] = { 
    width = 175,
    height = 20,

    Texture = {
      visible = false,
      atlas = AtlasType("Options_List_Active", true),
      drawLayer = "BACKGROUND",
      location = {
        Anchor("CENTER")
      }
    },
    HighlightTexture = {
      atlas = AtlasType("Options_List_Hover", true),
      alphaMode = "ADD",
    },
    
    Label = {
      fontObject = GameFontNormal,
      drawLayer = "ARTWORK",
      justifyH = "LEFT",
      text = "Test",
      location = {
        Anchor("TOPLEFT", 36, 1),
        Anchor("BOTTOMRIGHT", 0, 1)
      }
    }
  },

  [SUI.CategoryHeader] = {
    width = 175,
    height = 30,
    
    BackgroundTexture = {
      atlas = AtlasType("Options_CategoryHeader_1", true),
      drawLayer = "ARTWORK",
      location = {
        Anchor("TOPLEFT")
      }
    },

    Label = {
      fontObject = GameFontHighlightMedium,
      drawLayer = "OVERLAY",
      justifyH = "LEFT",
      text = "Test",
      location = {
        Anchor("LEFT", 20, -1)
      }
    }
  },

  [SUI.Category] = {
    width = 175,
    height = 30,
    layoutManager = Layout.VerticalLayoutManager(),
    paddingTop = 32,
    paddingBottom = 10,
    paddingLeft = 0,
    paddingRight = 0,
  
    Header = {
      location = {
        Anchor("TOP")
      }
    },

    [SUI.CategoryEntryButton] = {
      marginRight = 0
    }
  },

  [SUI.CategoryList] = {
    width = 200,
    height = 30,
    layoutManager = Layout.VerticalLayoutManager(),
    paddingTop = 32,
    paddingBottom = 10,
    paddingLeft = 0,
    paddingRight = 0,    
  }
})



