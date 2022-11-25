-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.Entry"                   ""
-- ========================================================================= --
local BLZ_CHARACTERCREATE_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_CharacterCreate]]

struct "SUI.EntryData" {
    { name = "text",          type = String },
    { name = "value",         type = Any },
    { name = "id",            type = String},
    { name = "order",         type = Number, default = 0 },
    { name = "widgetClass",   type = IEntry },
    { name = "properties",    type = Table},
    { name = "styles",        type = Table}
}

interface "SUI.IEntry" (function(_ENV)
  require "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { SUI.EntryData}
  function SetupFromEntryData(self, data) 
    self:SetEntryData(data)
    self:InitProperties(data)
    self:InitStyles(data)
  end

  function GetEntryData(self) 
    return self.EntryData 
  end
  
  __Arguments__{  SUI.EntryData/nil}
  function SetEntryData(self, data) 
    self.EntryData = data 
  end 

  __Arguments__ { SUI.EntryData}
  function InitProperties(self, data)
    if data.properties then 
      for property, value in pairs(data.properties) do 
        self[property] = value
      end
    end 
  end

  function InitStyles(self, data)
    if data.styles then 
      Style[self] = data.styles
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "EntryData" {
    type = SUI.EntryData
  }
end)


interface "SUI.IButtonEntry" (function(_ENV)
  require "Button" extend "SUI.IEntry"
end)

__Widget__()
class "SUI.SeparatorEntry" (function(_ENV)
  inherit "Frame" extend "SUI.IEntry"
end)


__Widget__()
class "SUI.EntryButton" (function(_ENV)
  inherit "Button" extend "SUI.IButtonEntry"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__{ SUI.EntryData }
  function SetupFromEntryData(self, data)
    super.SetupFromEntryData(self, data)

    Style[self].SelectionDetails.SelectionName.text = data.text or ""
  end

  function RefreshState(self)
    local highlightBackground = self:GetChild("HighlightBackground")
    local selectionName = self:GetChild("SelectionDetails"):GetChild("SelectionName")
    local fontColor = nil 

    if self.Selected then 
      highlightBackground:SetAlpha(0)
      fontColor = NORMAL_FONT_COLOR
    else
      if self.Mouseover then 
        highlightBackground:SetAlpha(0.15)
      else 
         highlightBackground:SetAlpha(0)
      end

      -- TODO: Implement disabled stuff (GRAY_FONT_COLOR)

      fontColor = HIGHLIGHT_FONT_COLOR
    end
    
    selectionName:SetTextColor(fontColor:GetRGB())
  end

  function OnRelease(self)
    self:SetID(0)
    self:SetParent()
    self:ClearAllPoints()
    self:Hide()

    self.Selected = nil 
    self.Mouseover = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Selected" {
    type = Boolean,
    default = false,
    handler = function(self, new) self:RefreshState() end 
  }

  property "Mouseover" {
    type = Boolean,
    default = false,
    handler = function(self, new) self:RefreshState() end 
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    HighlightBackground = Frame,
    SelectionDetails    = Frame,
    {
      SelectionDetails = {
        SelectionName = FontString
      }
    }
  }
  function __ctor(self)
    self.OnEnter = self.OnEnter + function() self.Mouseover = true end 
    self.OnLeave = self.OnLeave + function() self.Mouseover = false end

    self:RefreshState()
  end
end)

--- The interface adds the properties for holding the entries data
interface "SUI.IEntryProvider" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { SUI.EntryData }
  function AddEntry(self, entry)
    self.EntriesData:Insert(entry)
  end

  __Arguments__ { SUI.EntryData }
  function RemoveEntry(self, entry)
    self.EntriesData:Remove(entry)
  end

  function GetEntries(self)
    return self.EntriesData
  end


  __Arguments__ { Array[SUI.EntryData] }
  function SetEntries(self, entries)
    self.EntriesData:Clear()

    for index, entry in entries:GetIterator() do 
      self:AddEntry(entry)
    end
  end

  function ClearEntries(self)
    self.EntriesData:Clear()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "EntriesData" {
    set = false,
    default = function() return Array[SUI.EntryData]() end 
  }

  property "DefaultEntryClass" {
    type = -SUI.IEntry,
    default = SUI.EntryButton
  }
end)

--- Similar to EntryProvider excepted it doesn't hold entries data, only keep 
--- a weak reference to them
interface "SUI.IProxyEntryProvider" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Array[SUI.EntryData]/nil }
  function LinkEntries(self, entriesData)
    self.EntriesData = entriesData
  end

  function GetEntries(self)
    return self.EntriesData
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  --- Important: In case where this value is unexpected become nil, you Should
  --- check if the data source is still avalaible.
  __Set__(PropertySet.Weak)
  property "EntriesData" {
    type    = Array[SUI.EntryData]
  }

  property "DefaultEntryClass" {
    type    = -SUI.IEntry,
    default = SUI.EntryButton
  }
end)


__Widget__()
class "SUI.GridEntriesFauxScrollBox" (function(_ENV)
  inherit "SUI.FauxScrollBox" extend "SUI.IProxyEntryProvider"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEntryClick(self, entry)
    if self.SelectedEntry and self.SelectedEntry == entry:GetEntryData() then
      return 
    end

    self:OnEntrySelected(entry)
  end

  local function OnOffsetChanged(self, newOffset, previousOffset)
    self:Refresh()
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Number, -SUI.IEntry}
  function AcquireEntry(self, index, entryClass)
    local entry = entryClass.Acquire()
    entry:SetParent(self:GetScrollContent())

    -- If the Entry is a button, register onClick
    if Class.IsObjectType(entry, SUI.IButtonEntry) then 
      entry.OnClick = entry.OnClick + self.OnEntryClick
    end

    self.EntryFrames[index] = entry

    return entry
  end

  function ReleaseEntries(self)
    for index, entry in pairs(self.EntryFrames) do 
      -- if the entry is a button, remove onClick handler 
      if Class.IsObjectType(entry, SUI.IButtonEntry) then 
        entry.OnClick = entry.OnClick - self.OnEntryClick
      end

      entry:Release()
      self.EntryFrames[index] = nil
    end
  end

  function GetEntryIndex(self, row, column)
    return (row - 1) * self.ColumnCount + column
  end

  function SelectEntry(self, entry)
    self.SelectedEntry = entry
  end

  function Refresh(self)
    --- It's important to check if there are data as this can become nil if 
    --- the data source are no longer avalaible.
    if not self.EntriesData then 
      return 
    end

    self:ReleaseEntries()

    local scrollBar = self:GetScrollBar()

    self.RowCount = ceil(self.EntriesData.Count / self.ColumnCount)

    local step = 1 / (self.RowCount - self.DisplayedRowCount)
    local visibleExtentPercent = Clamp(self.DisplayedRowCount /self.RowCount, 0, 1)
    scrollBar:SetScrollStepPercentage(step)
    scrollBar:SetVisibleExtentPercentage(visibleExtentPercent)

    local rowTotalHeight = 0
    for rowIndex = 1, min(self.DisplayedRowCount, self.RowCount) do
      for columnIndex = 1, self.ColumnCount do 
        local entryFrameIndex = self:GetEntryIndex(rowIndex, columnIndex)
        local entryIndex = self:GetEntryIndex(rowIndex + self:GetOffset(), columnIndex)
        local entryData = self.EntriesData[entryIndex]

        if entryData then 
          local entryClass = entryData.widgetClass or self.DefaultEntryClass
          local entry = self:AcquireEntry(entryFrameIndex, entryClass)
          entry:SetupFromEntryData(entryData)

          if self.SelectedEntry and self.SelectedEntry == entryData then
            entry.Selected = true 
          else
            entry.Selected = false 
          end

          Style[entry].height = self.RowHeight


          if self.EntryExtendWidth and self.ColumnCount == 1 then 
            entry:SetPoint("RIGHT")
          else 
            Style[entry].width  = self.ColumnWidth
          end

          entry:SetPoint("TOPLEFT", (columnIndex - 1) * self.ColumnWidth, -((rowIndex - 1) * self.RowHeight))
        end
      end
      rowTotalHeight = rowTotalHeight + self.RowHeight
    end

    if self.AutoHeight then
      -- IMPORTANT: If the height is set in the "Style", this will prevent the AutoHeight to work
      self:SetHeight(rowTotalHeight + self.AutoHeightOffsetExtent)
    end
  end

  function OnSystemEvent(self, event, ...)
    if not self:IsMouseOver() then
      self:Hide()
    end
  end

  function OnAcquire(self)
    self:RegisterSystemEvent("GLOBAL_MOUSE_DOWN")
  end

  function OnRelease(self)
    self:UnegisterSystemEvent("GLOBAL_MOUSE_DOWN")
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SelectedEntry" {
    type = SUI.EntryData,
    default = nil
  }

  property "EntryFrames" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }

  property "ColumnCount" {
    type = Number,
    default = 1
  }

  property "ColumnWidth" {
    type = Number,
    default = 75
  }

  --- Say if the entry will take the width of it's parent
  --- this mode is only avalaible if ColumnCount is '1'
  property "EntryExtendWidth" {
    type = Boolean,
    default = true
  }

  --- AutoHeight the frame depending on the number of entry displayed
  property "AutoHeight" {
    type = Boolean,
    default = true
  }

  --- In case where you need to add or remove height when using the AutoHeight 
  property "AutoHeightOffsetExtent" {
    type = Number,
    default = 0
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  --- We put "__InstantApplyStyle__" to be sure the Padding value is set 
  __InstantApplyStyle__()
  __Template__{}
  function __ctor(self)
    self.OnEntryClick = function(entry, ...)
      OnEntryClick(self, entry)
    end

    self.OnOffsetChanged = self.OnOffsetChanged + OnOffsetChanged
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.SeparatorEntry] = {
    size = Size(250, 20)
  },

  [SUI.EntryButton] = {
    size = Size(250, 20),
    SelectionDetails = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 14, 0),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      },

      SelectionName = {
        setAllPoints = true, 
        fontObject = GameFontNormal,
        text = "Entry 1",
        justifyH = "LEFT",
        maxLines = 1,
        drawLayer = "OVERLAY",
        subLevel = 1
      }
    },

    HighlightBackground = {
      setAllPoints = true, 
      alpha = 0,
      
      LeftBGTexture = {
        --- charactercreate-customize-dropdown-linemouseover-side, true
        file = BLZ_CHARACTERCREATE_FILE,
        width = 6,
        height = 20,
        texCoords = { left = 0.99072265625, right = 0.99658203125, top = 0.00048828125, bottom = 0.02001953125},
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPLEFT")
        }
      },
      RightBGTexture = {
         --- charactercreate-customize-dropdown-linemouseover-side, true
        file = BLZ_CHARACTERCREATE_FILE,
        width = 6,
        height = 20,
        --- left and right reversed
        texCoords = { left = 0.99658203125, right = 0.99072265625, top = 0.00048828125, bottom = 0.02001953125},
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPRIGHT")
        }
      },
      MiddleBGTexture = {
        --- charactercreate-customize-dropdown-linemouseover-middle, true
        file = BLZ_CHARACTERCREATE_FILE,
        texCoords = { left = 0.99755859375, right = 0.998046875, top = 0.00048828125, bottom = 0.02001953125},
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
          Anchor("BOTTOMRIGHT", 0, 0, "RightBGTexture", "BOTTOMLEFT")
        }
      }
    }
  },
  [SUI.GridEntriesFauxScrollBox] = {
    size = Size(200, 200),
    ScrollBar = {
      location = {
        Anchor("TOPRIGHT"),
        Anchor("BOTTOMRIGHT")
      }
    },
    ScrollContent = {
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMRIGHT", -5, 0, "ScrollBar", "BOTTOMLEFT")
      }
    }
  }
})