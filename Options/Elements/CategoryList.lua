-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.CategoryList"            ""
-- ========================================================================= --
export {
  ResetStyles = SLT.Utils.ResetStyles
}

local BLZ_OPTIONS_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_Options]]

__Widget__()
class "SUI.CategoryEntryButton" (function(_ENV)
  inherit "Button" extend "SUI.IButtonEntry"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------  
  __Arguments__ { SUI.EntryData }
  function SetupFromEntryData(self, data)
    super.SetupFromEntryData(self, data)

    Style[self].Label.text = data.text or ""
  end

  function RefreshState(self)
    local label = self:GetChild("Label")
    local texture = self:GetChild("Texture")
    if self.Selected then 
      label:SetFontObject("GameFontHighlight")
      --- Options_List_Active, true
      texture:SetTexture(BLZ_OPTIONS_FILE)
      texture:SetTexCoord(0.58984375, 0.7724609375, 0.0009765625, 0.021484375)
      texture:SetWidth(187)
      texture:SetHeight(21)
      texture:Show()

    else
       label:SetFontObject("GameFontNormal")
       if self:IsMouseOver() then 
          --- Options_List_Hover, true 
          texture:SetTexture(BLZ_OPTIONS_FILE)
          texture:SetTexCoord(0.7744140625, 0.95703125, 0.0009765625, 0.021484375)
          texture:SetWidth(187)
          texture:SetHeight(21)
          texture:Show()
       else 
          texture:Hide()
       end
    end
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:SetParent()
    self:ClearAllPoints()
    self:Hide()

    ResetStyles(self, true)

    self.Selected = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Selected" {
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
    self.OnClick = self.OnClick + function() self.Selected = true end
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
  inherit "Frame" extend "SUI.IEntryProvider"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEntryClick(self, entry)
    local index = self:GetEntryIndex(entry)
    self:SelectEntry(index)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Number/0, Boolean/true }
  function SelectEntry(self, index, triggerEvent)
    if index == self.SelectedIndex then 
      return 
    end

    local previousSelectedEntry = self.Entries[self.SelectedIndex]
    local selectedEntry = self.Entries[index]

    if previousSelectedEntry then
      previousSelectedEntry.Selected = false 
    end 

    if selectedEntry then 
      selectedEntry.Selected = true 

      if triggerEvent then 
        self:OnEntrySelected(selectedEntry)
      end
    else 
      if triggerEvent then 
        self.__pendingTriggerEvent = true 
      end
    end

    self.SelectedIndex = index
  end

  __Arguments__ { String, Boolean/nil}
  function SelectEntryById(self, id, triggerEvent)
    for index, entryData in self:GetEntries():GetIterator() do 
      if entryData.id == id then 
        self:SelectEntry(index, triggerEvent)
        return
      end
    end
  end

  __Arguments__ { SUI.IEntry }
  function GetEntryIndex(self, entry)
    for index, e in pairs(self.Entries) do 
      if e == entry then 
        return index 
      end
    end
  end

  __Arguments__ { Number, -SUI.IEntry }
  function AcquireEntry(self, index, entryClass)
    local entry = entryClass.Acquire()
    entry:SetParent(self)
    entry:SetID(index)
    
    --- If the Entry is a button, register onClick
    if Class.IsObjectType(entry, SUI.IButtonEntry) then 
      entry.OnClick = entry.OnClick + self.OnEntryClick
    end

    self.Entries[index] = entry

    return entry
  end

  function ReleaseEntries(self)
    for index, entry in pairs(self.Entries) do 
      --- If the Entry is a button, remove onClick
      if Class.IsObjectType(entry, SUI.IButtonEntry) then 
        entry.OnClick = entry.OnClick - self.OnEntryClick
      end

      entry:Release()

      self.Entries[index] = nil
    end
  end

  function Refresh(self)
    self:ReleaseEntries()

    for index, entryData in self.EntriesData:GetIterator() do 
      local entryClass = entryData.widgetClass or self.DefaultEntryClass
      local entry = self:AcquireEntry(index, entryClass)
      entry:SetupFromEntryData(entryData)

      --- As sometimes the entry can be selected before its frame is acquired 
      --- we need to check it 
      if self.SelectedIndex == index then
        entry.Selected = true
        
        if self.__pendingTriggerEvent then 
          self:OnEntrySelected(entry)
          self.__pendingTriggerEvent = nil
        end
      end
    end
  end


  function Release(self)
    self:ReleaseEntries()
    self.EntriesData:Clear()
    self.SelectedIndex = nil
    self.__pendingTriggerEvent = nil
  end

  function ClearEntries(self)
    super.ClearEntries(self)

    self.SelectedIndex = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  ----------------------------------------------------------------------------- 
  property "SelectedIndex" {
    type = Number,
    default = 0
  }

  property "Entries" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = SUI.CategoryHeader
  }
  function __ctor(self)
    self.DefaultEntryClass = SUI.CategoryEntryButton

    -- Create the event handlers 
    self.OnEntryClick = function(entry) OnEntryClick(self, entry) end
  end

end)


__Widget__()
class "SUI.CategoryList" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnEntrySelected"

  local function OnCategoryEntrySelected(self, category, entry)
    for id, c in pairs(self.Categories) do 
      if c ~= category then 
        -- SelectEntry will unselected the entry if no valid index is given
        c:SelectEntry()
      else
        self:OnEntrySelected(entry)
      end
    end
  end
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

    category.OnEntrySelected = category.OnEntrySelected + self.OnCategoryEntrySelected

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

  __Arguments__ { String, Number }
  function SelectEntry(self, categoryId, index)
    local category = self.Categories[categoryId]
    if category then 
      category:SelectEntry(index)
    end
  end
  

  __Arguments__ { String, SUI.EntryData }
  function RemoveEntry(self, categoryId, entryData)
    local category = self.Categories[categoryId]
    if category then 
      category:RemoveEntry(entryData)
    end
  end

  __Arguments__ { String/nil}
  function Refresh(self, categoryId)
    for cId, category in pairs(self.Categories) do
      if categoryId == nil or (categoryId and categoryId == cId) then 
        category:Refresh()
      end
    end 
  end

  __Arguments__ { String/nil}
  function ClearEntries(self, categoryId)
    for cId, category in pairs(self.Categories) do
      if categoryId == nil or (categoryId and categoryId == cId) then 
        category:ClearEntries()
      end
    end 
  end

  __Arguments__ { String, String}
  function SelectEntryById(self, categoryId, entryId)
    for cId, category in pairs(self.Categories) do
      if categoryId == nil or (categoryId and categoryId == cId) then 
        category:SelectEntryById(entryId)
      end
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
    self.OnCategoryEntrySelected = function(category, entry) OnCategoryEntrySelected(self, category, entry) end
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
      drawLayer = "BACKGROUND",
      location = {
        Anchor("CENTER")
      }
    },
    HighlightTexture = {
      --- Options_List_Hover, true
      file = BLZ_OPTIONS_FILE,
      width = 187,
      height = 21,
      texCoords = { left = 0.7744140625, right = 0.95703125, top = 0.0009765625, bottom = 0.021484375},
      alphaMode = "ADD",
    },
    
    Label = {
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
      --- Options_CategoryHeader_1, true
      file = BLZ_OPTIONS_FILE,
      width = 199,
      height = 144,
      texCoords = { left = 0.0009765625, right = 0.1953125, top = 0.0009765625, bottom = 0.1416015625},
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



