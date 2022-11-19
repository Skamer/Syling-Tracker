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
  __Arguments__ { Number, Number, (Number + Frame)/0, Number/nil, Number/nil, Number/0, Number/0 }
  function SetCellControl(self, rowIndex, columnIndex, control, controlWidth, controlHeight, offsetX, offsetY)
    local row = self.CellControls[rowIndex]
    if not row then 
      row = {}
      self.CellControls[rowIndex] = row
    end
    row[columnIndex] = {
      control = control,
      width = controlWidth,
      height = controlHeight,
      offsetX = offsetX,
      offsetY = offsetY
    }
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
        local controlInfo = rowControls and rowControls[columnIndex]
        local columnMargin = self.ColumnMargins[columnIndex] or self.DefaultColumnMargin
        local columnWidth = self.ColumnWidths[columnIndex]
        if controlInfo then 
          local control = controlInfo.control
          local controlHeight = controlInfo.height
          local controlWidth = controlInfo.width
          local controlOffsetX = controlInfo.offsetX
          local controlOffsetY = controlInfo.offsetY
          if control and type(control) ~= "number" then
            control:ClearAllPoints()

            if controlHeight then 
              if controlHeight > 0 and controlHeight <= 1 then 
                Style[control].height = rowHeight * controlHeight
              else
                Style[control].height = controlHeight
              end
            end
            
            if controlWidth then 
              if controlWidth > 0 and controlWidth <= 1 then 
                Style[control].width = columnWidth * controlWidth
              else
                Style[control].width = controlWidth
              end
            end
            
            control:SetPoint("TOPLEFT", currentWidth + columnMargin + controlOffsetX, -currentHeight + rowMargin + controlOffsetY)
          end
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

  function OnAcquire(self)
    self:SetHeight(1)
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)
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