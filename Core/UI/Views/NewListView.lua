-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.UI.NewListView"                        ""
-- ========================================================================= --
export {
  newtable                            = System.Toolset.newtable,
  IsObjectType                        = Class.IsObjectType
}

__UIElement__()
class "NewListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    wipe(self.ViewKeys)
    wipe(self.ArrayViews)

    self.CurrentRowCount = 0

    if data and self.ViewClass then
      local previousView
      local index = 0
      local paddingLeft = Style[self].PaddingLeft or 0
      local paddingTop = Style[self].PaddingTop or 0
      local paddingRight = Style[self].paddingRight or 0

      for key, itemData, itemMetadata in self:IterateData(data, metadata) do
        local classType = self:GetViewClass(itemData, metadata)
        if classType then
          index = index + 1

          if self.MaxDisplayedRow > 0 and index > self.Rows then
            break 
          end

          local view = self:AcquireView(key, classType)
          view:ClearAllPoints() 

          self:AdjustElement(view, index, previousView, paddingTop, paddingLeft, paddingRight)
          
          view:UpdateView(itemData, itemMetadata)

          previousView = view 

          tinsert(self.ArrayViews, view)
          self.CurrentRowCount = self.CurrentRowCount + 1

          self.ViewKeys[key] = true
        end
      end 
    end

    self:ReleaseUnusedViews()
  end

  function AdjustElement(self, element, index, previousElement, topOffset, leftOffset, rightOffset)
    local columns = self.Columns

    if self.Columns > 1 then
      local column = ((index - 1) % columns) + 1
      local row = math.floor((index - 1) / columns) + 1
      local rowSpacing, columnSpacing = self.RowSpacing, self.ColumnSpacing

      local elementWidth = (self:GetWidth() - leftOffset - rightOffset - columnSpacing * (columns - 1)) / columns
      local rowHeight = self.RowHeight

      local posX = (column - 1) * elementWidth + columnSpacing * (column - 1 ) + leftOffset
      local posY = (row - 1) * rowHeight + rowSpacing * (row - 1 ) + topOffset

      element:SetWidth(elementWidth)
      element:SetHeight(rowHeight)

      element:SetPoint("TOPLEFT", self, "TOPLEFT", posX, -posY)
    else 
      element:SetPoint("LEFT", leftOffset, 0)
      element:SetPoint("RIGHT", -rightOffset, 0)

      if previousElement then 
        element:SetPoint("TOP", previousElement, "BOTTOM", 0, -self.RowSpacing) 
      else 
        element:SetPoint("TOP", 0, topOffset)
      end
    end
  end

  __Iterator__()
  function IterateData(self, data, metadata)
    local yield = coroutine.yield 
    local iterator = self.Indexed and ipairs or pairs
    local index  = 0

    for k, v in iterator(data) do 
      if not self:IsFilteredEntry(k, v, metadata) then 
        yield(k, v, metadata)

        index = index + 1
      end
    end

    self.EntriesCount = index
  end

  function IsFilteredEntry(self, key, itemData, metadata)
    return false
  end

  function AcquireView(self, key, classType)
    local view = self.Views[key]
    local new = false 

    if view and not IsObjectType(view, classType) then 
      view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged

      view:Release()
      self.Views[key] = nil 

      new = true
    end

    if not view or new then 
      view = classType.Acquire()
      view:SetParent(self)
      view:Show()

      view.OnSizeChanged = view.OnSizeChanged + self.OnViewSizeChanged

      self.Views[key] = view 

      new = true 
    end

    return view, new
  end

  function OnAdjustHeight(self)
    local height = 0
    
    if self.Columns > 1 then
      local row = math.floor((#self.ArrayViews - 1) / self.Columns) + 1

      height = row * self.RowHeight + (row - 1) * self.RowSpacing
    else
      local index = 0
      for _, child in pairs(self.Views) do
        index = index + 1

        height = height + child:GetHeight()
      end

      height = height + (index - 1) * self.RowSpacing
    end 
    
    local paddingTop = Style[self].PaddingTop or 0
    local paddingBottom = Style[self].PaddingBottom or 0
    
    height = height + paddingTop + paddingBottom

    self:SetHeight(height)
  end

  function GetViewClass(self, data, ...)
    if type(self.ViewClass) == "function" then 
      return self.ViewClass(data, ...)
    end 
    
    return self.ViewClass
  end

  function ReleaseUnusedViews(self)
    for key, view in pairs(self.Views) do
      if not self.ViewKeys[key] then 
        view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged
        view:Release()

        self.Views[key] = nil 
      end
    end
  end
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {}
  function __ctor(self)
    self:InstantApplyStyle()
    self:SetHeight(1)
    self.OnViewSizeChanged = function()
      if self.Columns > 1 then 
        self:RefreshView() 
      end

      self:AdjustHeight() 
    end

    self.OnSizeChanged = self.OnSizeChanged + function()
      if self.Columns > 1 then 
        self:RefreshView()
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "MaxDisplayedRow" { type = Number, default = 0, handler = function(self) self:RefreshView() end }

  property "Columns" { type = Number, default = 2, handler = function(self) self:RefreshView() end }

  property "RowHeight" { type = Number, default = 28, handler = function(self) self:RefreshView() end }

  property "RowSpacing" { type = Number, default = 5, handler = function(self) self:RefreshView() end }

  property "ColumnSpacing" { type = Number, default = 5, handler = function(self) self:RefreshView() end }

  property "MaxDisplayedRow" { type = Number, default = 0, handler = function(self) self:RefreshView() end }

  property "CurrentRowCount" { type = Number, default = 0}

  property "EntriesCount" { type = Number, default = 0 }

  property "ViewClass" { type = ClassType + Function, handler = function(self) self:RefreshView() end }
  
  property "Indexed" { type = Boolean, default = false }

  property "ViewKeys" {
    set = false,
    default = function() return {} end
  }

  property "Views" {
    set = false,
    default = function() return newtable(false, true) end 
  }

  property "ArrayViews" {
    set = false, 
    default = function() return newtable(false, true) end
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [NewListView] = {
    autoAdjustHeight = true,
    paddingLeft = 5,
    paddingBottom = 5,
    paddingTop = 5,
    paddingRight = 5,    
  }
})