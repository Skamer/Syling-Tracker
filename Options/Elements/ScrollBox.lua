-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Elements.ScrollBox"               ""
-- ========================================================================= --
__Widget__()
class "SUI.ScrollFrame" (function(_ENV)
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
    ScrollBar = SUI.ScrollBar
  }
  function __ctor(self) end 
end)

__Widget__()
class "SUI.ScrollBox" (function(_ENV)
  inherit "SUI.ScrollFrame"
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
class "SUI.FauxScrollFrame" (function(_ENV)
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
    ScrollBar = SUI.ScrollBar,
    ScrollContent = Frame
  }
  function __ctor(self) end 
end)


__Widget__()
class "SUI.FauxScrollBox" (function(_ENV)
  inherit "SUI.FauxScrollFrame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnMouseWheel(self, direction)
    local scrollBar = self:GetScrollBar()
    scrollBar:OnMouseWheel(direction)
  end

  local function OnScroll(self, value)
    local offset = max(0, (self.RowCount - self.DisplayedRowCount) * value)
    self.Offset = offset
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
  [SUI.ScrollFrame] = {
    ScrollBar = {
      location = {
        Anchor("TOPLEFT", 8, -16, nil, "TOPRIGHT"),
        Anchor("BOTTOMLEFT", 8, 16, nil, "BOTTOMRIGHT")
      }      
    }
  },
  [SUI.FauxScrollFrame] = {
    ScrollBar = {
      location = {
        Anchor("TOPLEFT", 8, -16, nil, "TOPRIGHT"),
        Anchor("BOTTOMLEFT", 8, 16, nil, "BOTTOMRIGHT")
      }      
    }
  }
})