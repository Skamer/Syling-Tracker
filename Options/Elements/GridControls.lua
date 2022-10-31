-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling           "SylingTracker.Options.Elements.GridControls"               ""
-- ========================================================================= --
__Widget__()
class "SUI.GridControls" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Number, Number, (Number + Frame)/0 }
  function SetCellControl(self, rowIndex, columnIndex, control)
    local row = self.CellControls[rowIndex]
    if not row then 
      row = Toolset.newtable(false, true)
      self.CellControls[rowIndex] = row
    end

    row[columnIndex] = control
  end

  __Arguments__ { Number, Number/nil}
  function SetRowHeight(self, rowIndex, height)
    self.RowHeights[rowIndex] = height
  end

  __Arguments__ { Number, Number }
  function SetColumnWidth(self, columnIndex, width)
    self.ColumnWidths[columnIndex] = width
  end

  __Abstract__ { Number * 0}
  function SetColumnWidths(self, ...)
    for i = 1, select("#", ...) do 
      local value = select(i, ...)
      self:SetColumnWidth(i, value)
    end 
  end

  __Arguments__ { Number }
  function SetDefaultRowHeight(self, height)
    self.DefaultRowHeight = height
  end

  __Arguments__ { Number/nil}
  function SetRowCount(self, row)
    self.RowCount = row
  end

  __Arguments__ { Number/nil }
  function SetColumnCount(self, column)
    self.ColumnCount = column
  end

  __Arguments__ { Number, Number/nil}
  function SetColumnMargin(self, columnIndex, margin)
    self.ColumnMargins[columnIndex] = margin
  end

  __Arguments__ { Number/nil}
  function SetDefaultColumnMargin(self, margin)
    self.DefaultColumnMargin = margin
  end

  __Arguments__ { Number, Number/nil}
  function SetRowMargin(self, rowIndex, margin)
    sefl.RowMargins(self, rowIndex, margin)
  end

  __Arguments__ { Number/nil }
  function SetDefaultRowMargin(self, margin)
    self.DefaultColumnMargin = margin
  end

  function Refresh(self)
    local currentHeight = 0
    local totalWidth = 0
    for rowIndex = 1, self.RowCount do
      local rowControls = self.CellControls[rowIndex]
      local rowHeight = self.RowHeights[rowIndex] or self.DefaultRowHeight
      local rowMargin = self.RowMargins[rowIndex] or self.DefaultRowMargin
      local currentWidth = 0
      for columnIndex = 1, self.ColumnCount do 
        local control = rowControls and rowControls[columnIndex]
        local columnMargin = self.ColumnMargins[columnIndex] or self.DefaultColumnMargin
        local columnWidth = self.ColumnWidths[columnIndex]
        if control and type(control) ~= "number" then
          control:ClearAllPoints()
          Style[control].height = rowHeight
          Style[control].width = columnWidth

          control:SetPoint("TOPLEFT", currentWidth + columnMargin, -currentHeight + rowMargin)
        end
        currentWidth = currentWidth + columnWidth + columnMargin

        if columnIndex == self.ColumnCount then 
          totalWidth = currentWidth
        end
      end 
      
      currentHeight = currentHeight + rowHeight + rowMargin
    end

    self:SetWidth(totalWidth)
    self:SetHeight(currentHeight)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "ColumnCount" {
    type = Number, 
    default = 0
  }

  property "RowCount" {
    type = Number,
    default = 0
  }

  property "DefaultRowMargin" {
    type = Number,
    default = 5
  }

  property "RowMargins" {
    set = false, 
    default = {}
  }

  property "DefaultColumnMargin" {
    type = Number,
    default = 5
  }

  property "ColumnMargins" {
    set = false,
    default = {}
  }

  property "ColumnWidths" {
    set = false,
    default = {}
  }

  property "RowHeights" {
    set = false,
    default = {}
  }

  property "DefaultRowHeight" {
    type = Number,
    default = 30
  }

  property "CellControls" {
    set = false,
    default = {}
  }
end)