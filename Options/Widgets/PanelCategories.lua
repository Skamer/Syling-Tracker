-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.PanelCategories"          ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --
export {
  newtable = Toolset.newtable,
  ResetStyles = SylingTracker.Utils.ResetStyles
}

__Widget__()
class "PanelCategoryEntryButton" (function(_ENV)
  inherit "Button" extend "IButtonEntry"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { EntryData }
  function SetupFromEntryData(self, data)
    super.SetupFromEntryData(self, data)

    Style[self].Label.text = data.text or ""
  end

  function RefreshState(self)
    local label = self:GetChild("Label")
    local texture = self:GetChild("Texture")
    if self.Selected then 
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

  function OnAcquire(self)
    -- self:InstantApplyStyle()
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
    type      = Boolean,
    default   = false,
    handler   = RefreshState
  }

  __InstantApplyStyle__()
  __Template__ {
    Label     = FontString,
    Texture   = Texture,
  }
  function __ctor(self)
    self.OnEnter = self.OnEnter + function() self:RefreshState() end
    self.OnLeave = self.OnLeave + function() self:RefreshState() end 
    self.OnClick = self.OnClick + function() self.Selected = true end
  end
end)

__Widget__()
class "PanelCategory" (function(_ENV)
  inherit "Frame" extend "IEntryProvider"
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

  __Arguments__ { IEntry }
  function GetEntryIndex(self, entry)
    for index, e in pairs(self.Entries) do 
      if e == entry then 
        return index 
      end
    end
  end

  __Arguments__ { Number, -IEntry }
  function AcquireEntry(self, index, entryClass)
    local entry = entryClass.Acquire()
    entry:Hide()
    entry:SetID(index)
    entry:SetParent(self)

    --- If the Entry is a button, register onClick
    if Class.IsObjectType(entry, IButtonEntry) then 
      entry.OnClick = entry.OnClick + self.OnEntryClick
    end

    self.Entries[index] = entry

    return entry
  end

  function ReleaseEntries(self)
    for index, entry in pairs(self.Entries) do 
      --- If the Entry is a button, remove onClick
      if Class.IsObjectType(entry, Widgets.IButtonEntry) then 
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
    default = function() return newtable(false, true) end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Frame, 
    {
      Header = {
        Label = FontString
      }
    }
  }
  function __ctor(self) 
    self.DefaultEntryClass = PanelCategoryEntryButton

    -- Create the event handlers 
    self.OnEntryClick = function(entry) OnEntryClick(self, entry) end  
  end
end)

__Widget__()
class "PanelCategories" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Handler                                   --
  -----------------------------------------------------------------------------
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
  __Arguments__ { String, String/""}
  function CreateCategory(self, id, text)
    -- A category must have an id different than other categories already added
    if self.Categories[id] then 
      return 
    end

    local category = PanelCategory.Acquire()
    category:InstantApplyStyle()
    category:Hide()
    
    Style[category].Header.Label.text = text 

    category.OnEntrySelected = category.OnEntrySelected + self.OnCategoryEntrySelected
    
    local index = self.CategoriesCount + 1
    category:SetID(index)
    category:SetParent(self:GetChild("ScrollBox"):GetChild("ScrollContent"))

    self.Categories[id] = category
    self.CategoriesCount = index 
  end


  __Arguments__ { EntryData, String}
  function AddCategoryEntry(self, entryData, categoryId)
    local category = self.Categories[categoryId]
    
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

  __Arguments__ { String, EntryData }
  function RemoveEntry(self, categoryId, entryData)
    local category = self.Categories[categoryId]
    
    if category then 
      category:RemoveEntry(entryData)
    end
  end

  __Arguments__ { String/nil }
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
    default = function() return newtable(false, true) end
  }

  property "CategoriesCount" {
    type = Number,
    default = 0,
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    ScrollBox     = ScrollBox,
    {
      ScrollBox = {
        ScrollContent = Frame,
      }
    }
  }
  __InstantApplyStyle__()
  function __ctor(self)

    self.OnCategoryEntrySelected = function(category, entry) OnCategoryEntrySelected(self, category, entry) end

    local scrollBox = self:GetChild("ScrollBox")
    local scrollContent = scrollBox:GetChild("ScrollContent")
    scrollBox:SetScrollTarget(scrollContent)

     -- We move the scroll to begin
    scrollBox:SetVerticalScroll(0)
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [PanelCategoryEntryButton] = {
    width = 175,
    height = 20,

    Texture = {
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
      drawLayer = "ARTWORK",
      justifyH = "LEFT",
      location = {
        Anchor("TOPLEFT", 36, 1),
        Anchor("BOTTOMRIGHT", 0, 1)
      }
    }
  },

  [PanelCategory] = {
    width = 225,
    minResize = { width = 0, height = 30},
    layoutManager = Layout.VerticalLayoutManager(true, true),
    paddingTop = 32,
    paddingBottom = 10,
    clipChildren = true,

    Header = {
      width = 225,
      height = 30,
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      },
    
      backdropColor       = { r = 1, g = 1, b = 1, a = 0.1},

      Label = {
        fontObject = GameFontHighlightMedium,
        drawLayer = "OVERLAY",
        justifyH = "LEFT",
        location = {
          Anchor("LEFT", 20, -1)
        }
      },

      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      }
    }
  },

  [PanelCategories] = {
    width = 225,
    ScrollBox = {
      ScrollContent = {
        width = 225,
        height = 1,
        layoutManager = Layout.VerticalLayoutManager(true, true),
      
      },
      
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      }
    },
  }
})