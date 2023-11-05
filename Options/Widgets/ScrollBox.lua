-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.ScrollBox"                ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --

__Widget__()
class "ScrollFrame" (function(_ENV)
  -- We use "Scorpio.UI" namespace for avoiding conflict as there are the same
  -- name "ScrollFrame"
  inherit "Scorpio.UI.ScrollFrame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetScrollBar(self)
    return self:GetChild("ScrollBar")
  end

  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    ScrollBar = ScrollBar
  }
  function __ctor(self) end 
end)

__Widget__()
class "ScrollBox" (function(_ENV)
  inherit "ScrollFrame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnMouseWheel(self, direction)
    local scrollBar = self:GetScrollBar()
    scrollBar:OnMouseWheel(direction)
  end

  local function OnScrollRangeChanged(self, xRange, yRange)
    local scrollBar = self:GetScrollBar()
    local visibleHeight = self:GetHeight()
    local contentHeight = visibleHeight + yRange
    scrollBar:SetVisibleExtentPercentage(visibleHeight / contentHeight)

    --- We ajusted the percentage with the new range
    scrollBar:SetScrollPercentage(self:GetVerticalScroll() / yRange)

    -- REVIEW: Should translate this feature directly in the ScrollBar class ?
    if scrollBar:HasScrollableExtent() then 
      scrollBar:Show()
    else 
      scrollBar:Hide()
    end
  end

  local function OnScroll(self, value)
    self:SetVerticalScroll(self:GetVerticalScrollRange() * value)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Frame }
  function SetScrollTarget(self, scrollTarget)
    self:SetScrollChild(scrollTarget)
    scrollTarget:SetWidth(self:GetWidth())
  end

  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{}
  function __ctor(self)
    local scrollBar = self:GetScrollBar()
    scrollBar:Hide()

    self.OnMouseWheel = self.OnMouseWheel + OnMouseWheel
    self.OnScrollRangeChanged = self.OnScrollRangeChanged + OnScrollRangeChanged

    scrollBar.OnScroll = scrollBar.OnScroll + function(_, value)
      OnScroll(self, value)
    end
  end
end)

__Widget__()
class "FauxScrollFrame" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetScrollBar(self)
    return self:GetChild("ScrollBar")
  end

  function GetScrollContent(self)
    return self:GetChild("ScrollContent")
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    ScrollBar = ScrollBar,
    ScrollContent = Frame
  }
  function __ctor(self) end 
end)


__Widget__()
class "FauxScrollBox" (function(_ENV)
  inherit "FauxScrollFrame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnMouseWheel(self, direction)
    local scrollBar = self:GetScrollBar()
    scrollBar:OnMouseWheel(direction)
  end

  local function OnScroll(self, value)
    local offset = max(0, (self.RowCount - self.DisplayedRowCount) * value)

    --- IMPORTANT: For avoiding issues, we need to be certain the offset is not decimal
    self.Offset = ceil(offset)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetOffset(self)
    return self.Offset
  end

  __Arguments__ { Number/nil }
  function SetDisplayedRowCount(self, displayedRowCount)
    self.DisplayedRowCount = displayedRowCount
  end

  function GetDisplayedRowCount(self)
    return self.DisplayedRowCount
  end

  __Arguments__ { Number/nil }
  function SetRowCount(self, rowCount)
    self.RowCount = rowCount
  end

  function GetRowCount(self)
    return self.RowCount
  end  
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Offset" {
    type      = Number,
    default   = 0,
    event     = "OnOffsetChanged"
  }

  property "DisplayedRowCount" {
    type      = Number,
    default   = 10
  }

  property "RowCount" {
    type      = Number,
    default   = 0
  }

  property "RowHeight" {
    type      = Number,
    default   = 20
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{}
  function __ctor(self)
    self.OnMouseWheel = self.OnMouseWheel + OnMouseWheel

    local scrollBar = self:GetScrollBar()
    scrollBar.OnScroll = scrollBar.OnScroll + function(_, value)
      OnScroll(self, value)
    end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ScrollFrame] = {
    ScrollBar = {
      location = {
        Anchor("TOPLEFT", 8, -16, nil, "TOPRIGHT"),
        Anchor("BOTTOMLEFT", 8, 16, nil, "BOTTOMRIGHT")
      }      
    }
  },
  [FauxScrollFrame] = {
    ScrollBar = {
      location = {
        Anchor("TOPLEFT", 8, -16, nil, "TOPRIGHT"),
        Anchor("BOTTOMLEFT", 8, 16, nil, "BOTTOMRIGHT")
      }      
    }
  }
})