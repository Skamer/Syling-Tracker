-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.SortableList"             ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --
export {
  tinsert = table.insert,
  tremove = table.remove,
  wipe = table.wipe or function(t) for k in pairs(t) do t[k] = nil end end,
  GetCursorPosition = GetCursorPosition
}

-- Sortable list entry that can be dragged and reordered
__Widget__()
class "SortableListEntry" (function(_ENV)
  inherit "Button"
  
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnDragStart(self)
    if not self.DragEnabled then return end
    
    self:StartMoving()
    local currentLevel = self:GetFrameLevel()
    self:SetFrameLevel(math.min(currentLevel + 10, 65535)) -- Bring to front but stay in range
    self:SetAlpha(0.8)
    
    -- Store original position for potential restore
    self.OriginalPoint, self.OriginalRelativeTo, self.OriginalRelativePoint, self.OriginalX, self.OriginalY = self:GetPoint()
    
    if self.OnDragStart then
      self.OnDragStart(self)
    end
  end
  
  local function OnDragStop(self)
    if not self.DragEnabled then return end
    
    self:StopMovingOrSizing()
    local currentLevel = self:GetFrameLevel()
    self:SetFrameLevel(math.max(currentLevel - 10, 0)) -- Return to normal level but stay in range
    self:SetAlpha(1.0)
    
    if self.OnDragStop then
      self.OnDragStop(self)
    end
  end
  
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetEntryData(self, data)
    self.EntryData = data
    
    -- Set text with proper formatting
    local text = data.text or ""
    self:GetChild("Label"):SetText(text)
    
    -- Set icon if available
    if data.icon then
      local icon = self:GetChild("Icon")
      if icon then
        icon:SetTexture(data.icon)
        icon:Show()
      end
    end
  end
  
  function GetEntryData(self)
    return self.EntryData
  end
  
  function RestorePosition(self)
    if self.OriginalPoint then
      self:ClearAllPoints()
      self:SetPoint(self.OriginalPoint, self.OriginalRelativeTo, self.OriginalRelativePoint, self.OriginalX, self.OriginalY)
    end
  end
  
  function OnAcquire(self)
    self.DragEnabled = true
  end
  
  function OnRelease(self)
    self:SetID(0)
    self:SetParent()
    self:ClearAllPoints()
    self:Hide()
    
    self:GetChild("Label"):SetText("")
    
    self.EntryData = nil
    self.DragEnabled = false
    self.OnDragStart = nil
    self.OnDragStop = nil
    
    local icon = self:GetChild("Icon")
    if icon then
      icon:Hide()
    end
    
    local background = self:GetChild("Background")
    if background then
      background:Hide()
    end
  end
  
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "DragEnabled" {
    type = Boolean,
    default = true
  }
  
  property "EntryData" {
    type = Table
  }
  
  -----------------------------------------------------------------------------
  --                              Constructor                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Background = Texture,
    Icon = Texture,
    Label = FontString
  }
  function __ctor(self)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true) -- Enable moving
    self:SetScript("OnDragStart", OnDragStart)
    self:SetScript("OnDragStop", OnDragStop)
    
    -- Configure background to look like tracker header
    local background = self:GetChild("Background")
    if background then
      background:SetAllPoints()
      background:SetColorTexture(0, 0, 0, 0.8) -- Dark semi-transparent
      background:Hide()
    end
    
    -- Configure icon
    local icon = self:GetChild("Icon")
    if icon then
      icon:SetSize(16, 16)
      icon:SetPoint("LEFT", self, "LEFT", 8, 0)
      icon:Hide()
    end
    
    -- Configure label with better styling
    local label = self:GetChild("Label")
    if label then
      label:SetPoint("LEFT", icon, "RIGHT", 6, 0)
      label:SetPoint("RIGHT", self, "RIGHT", -8, 0)
      label:SetFontObject("GameFontNormal")
      label:SetJustifyH("LEFT")
    end
    
    -- Set hover effects to mimic tracker header
    self:SetScript("OnEnter", function() 
      if background then background:Show() end
      if label then label:SetFontObject("GameFontHighlight") end
    end)
    self:SetScript("OnLeave", function() 
      if background then background:Hide() end
      if label then label:SetFontObject("GameFontNormal") end
    end)
  end
end)

-- Sortable list that supports drag-and-drop reordering
__Widget__()
class "SortableList" (function(_ENV)
  inherit "Frame"
  
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function AddEntry(self, data)
    local scrollChild = self:GetChild("ScrollFrame"):GetChild("ScrollChild")
    local entry = SortableListEntry.Acquire(false, scrollChild)
    entry:SetEntryData(data)
    entry.OnDragStart = function() self:OnEntryDragStart(entry) end
    entry.OnDragStop = function() self:OnEntryDragStop(entry) end
    
    tinsert(self.Entries, entry)
    self:RefreshLayout()
    
    return entry
  end
  
  function RemoveEntry(self, entry)
    for i, e in ipairs(self.Entries) do
      if e == entry then
        tremove(self.Entries, i)
        entry:Release()
        break
      end
    end
    self:RefreshLayout()
  end
  
  function ClearEntries(self)
    for _, entry in ipairs(self.Entries) do
      entry:Release()
    end
    wipe(self.Entries)
    self:RefreshLayout()
  end
  
  function SetEntries(self, entryDataList)
    self:ClearEntries()
    for _, data in ipairs(entryDataList) do
      self:AddEntry(data)
    end
  end
  
  function GetEntries(self)
    local result = {}
    for _, entry in ipairs(self.Entries) do
      tinsert(result, entry:GetEntryData())
    end
    return result
  end
  
  function RefreshLayout(self)
    local scrollChild = self:GetChild("ScrollFrame"):GetChild("ScrollChild")
    local yOffset = 0
    for i, entry in ipairs(self.Entries) do
      entry:ClearAllPoints()
      entry:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
      entry:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -yOffset)
      entry:SetHeight(self.EntryHeight)
      entry:Show()
      yOffset = yOffset + self.EntryHeight + self.EntrySpacing
    end
    
    -- Update scroll child height and width
    scrollChild:SetHeight(math.max(yOffset, self:GetHeight()))
    scrollChild:SetWidth(self:GetWidth())
  end
  
  function OnEntryDragStart(self, draggedEntry)
    self.DraggedEntry = draggedEntry
    self.InsertIndicator:Show()
    self:UpdateInsertionIndicator()
  end
  
  function OnEntryDragStop(self, draggedEntry)
    if not self.DraggedEntry then return end
    
    self.InsertIndicator:Hide()
    
    -- Determine where to insert the dragged entry based on mouse position
    local insertIndex = self:GetInsertIndexFromMouse()
    
    -- Find current index
    local currentIndex
    for i, entry in ipairs(self.Entries) do
      if entry == draggedEntry then
        currentIndex = i
        break
      end
    end
    
    if currentIndex and insertIndex and insertIndex ~= currentIndex then
      -- Remove from current position and insert at new position
      tremove(self.Entries, currentIndex)
      if insertIndex > currentIndex then
        insertIndex = insertIndex - 1
      end
      tinsert(self.Entries, insertIndex, draggedEntry)
      
      -- Trigger reorder callback for SettingsSortableList
      if self.OnEntriesReordered then
        self.OnEntriesReordered(self:GetEntries())
      end
    end
    
    self.DraggedEntry = nil
    self:RefreshLayout()
  end
  
  function GetInsertIndexFromMouse(self)
    local mouseX, mouseY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    mouseY = mouseY / scale
    
    local scrollFrame = self:GetChild("ScrollFrame")
    local listTop = scrollFrame:GetTop()
    if not listTop then return 1 end
    
    -- Account for scroll position
    local scrollOffset = scrollFrame:GetVerticalScroll()
    local relativeY = listTop - mouseY + scrollOffset
    
    if relativeY < 0 then return #self.Entries + 1 end
    
    local insertIndex = math.floor(relativeY / (self.EntryHeight + self.EntrySpacing)) + 1
    return math.max(1, math.min(insertIndex, #self.Entries + 1))
  end
  
  function UpdateInsertionIndicator(self)
    if not self.DraggedEntry then return end
    
    local insertIndex = self:GetInsertIndexFromMouse()
    if not insertIndex then return end
    
    local scrollChild = self:GetChild("ScrollFrame"):GetChild("ScrollChild")
    local yPos = -(insertIndex - 1) * (self.EntryHeight + self.EntrySpacing) - 1
    
    self.InsertIndicator:ClearAllPoints()
    self.InsertIndicator:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, yPos)
    self.InsertIndicator:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, yPos)
  end
  
  function OnAcquire(self)
    -- Initialize properties - Entries is already created by default function
    self.EntryHeight = 32
    self.EntrySpacing = 2
  end
  
  function OnRelease(self)
    self:ClearEntries()
    self.OnEntriesReordered = nil
    if self.ScrollBar then
      self.ScrollBar:Release()
      self.ScrollBar = nil
    end
  end
  
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "EntryHeight" {
    type = Number,
    default = 32
  }
  
  property "EntrySpacing" {
    type = Number,
    default = 2
  }
  
  property "Entries" {
    set = false,
    default = function() return {} end
  }
  
  property "OnEntriesReordered" {
    type = Function
  }
  
  -----------------------------------------------------------------------------
  --                              Constructor                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    ScrollFrame = ScrollFrame,
    {
      ScrollFrame = {
        ScrollChild = Frame
      }
    },
    InsertIndicator = Texture
  }
  function __ctor(self)
    -- Set up basic frame properties
    self:SetClipsChildren(true)
    
    -- Configure scroll frame
    local scrollFrame = self:GetChild("ScrollFrame")
    if scrollFrame then
      scrollFrame:SetAllPoints()
      local scrollChild = scrollFrame:GetChild("ScrollChild")
      scrollFrame:SetScrollChild(scrollChild)
      scrollFrame:EnableMouseWheel(true)
      
      -- Create a proper scrollbar using the existing ScrollBar widget
      local scrollBar = Widgets.ScrollBar.Acquire(false, self)
      scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -16)
      scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 16)
      scrollBar:SetWidth(16)
      scrollBar:Show()
      self.ScrollBar = scrollBar
      
      -- Connect scrollbar to scroll frame
      scrollBar.OnScroll = scrollBar.OnScroll + function(self, percentage)
        local maxScroll = scrollFrame:GetVerticalScrollRange()
        local absoluteScroll = percentage * maxScroll
        scrollFrame:SetVerticalScroll(absoluteScroll)
      end
      
      scrollFrame:SetScript("OnScrollRangeChanged", function(frame, xRange, yRange)
        if scrollBar then
          -- Calculate visible percentage (frame height / content height)
          local frameHeight = frame:GetHeight()
          local visiblePercentage = frameHeight / (frameHeight + yRange)
          scrollBar:SetVisibleExtentPercentage(visiblePercentage)
          
          -- Calculate scroll percentage
          local currentScroll = frame:GetVerticalScroll()
          local scrollPercentage = yRange > 0 and (currentScroll / yRange) or 0
          scrollBar:SetScrollPercentage(scrollPercentage)
          
          -- Show/hide scrollbar based on whether scrolling is needed
          if yRange > 0 then
            scrollBar:Show()
          else
            scrollBar:Hide()
          end
        end
      end)
      
      scrollFrame:SetScript("OnMouseWheel", function(frame, delta)
        local current = frame:GetVerticalScroll()
        local maxScroll = frame:GetVerticalScrollRange()
        local newScroll = math.max(0, math.min(maxScroll, current - (delta * 20)))
        frame:SetVerticalScroll(newScroll)
        if scrollBar then
          local scrollPercentage = maxScroll > 0 and (newScroll / maxScroll) or 0
          scrollBar:SetScrollPercentage(scrollPercentage)
        end
      end)
    end
    
    -- Configure insertion indicator
    local insertIndicator = self:GetChild("InsertIndicator")
    if insertIndicator then
      insertIndicator:SetColorTexture(1, 0.8, 0, 0.9) -- Golden highlight
      insertIndicator:SetHeight(2)
      insertIndicator:Hide()
    end
    
    -- Track mouse movement for insertion indicator
    self:SetScript("OnUpdate", function()
      if self.DraggedEntry then
        self:UpdateInsertionIndicator()
      end
    end)
  end
end)

-- Settings widget wrapper for sortable list
__Widget__()
class "SettingsSortableList" (function(_ENV)
  inherit "SortableList"
  
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetValue(self)
    return self:GetEntries()
  end
  
  function SetValue(self, value)
    if value then
      self:SetEntries(value)
    end
  end
  
  function OnAcquire(self)
    -- Call parent OnAcquire but don't call it as super since we inherit directly
    -- Initialize our specific properties
    self.EntryHeight = 32
    self.EntrySpacing = 2
    self.BaseOrder = 10
    
    -- Set up the callback to handle reordering
    self.OnEntriesReordered = function(entries)
      -- Convert entries to values based on position
      for i, entryData in ipairs(entries) do
        local order = (i - 1) * 5 + self.BaseOrder
        if self.OnOrderChanged then
          self.OnOrderChanged(entryData.id, order)
        end
      end
    end
  end
  
  function OnRelease(self)
    -- Clear entries and callbacks
    self:ClearEntries()
    self.OnEntriesReordered = nil
    self.OnOrderChanged = nil
  end
  
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "BaseOrder" {
    type = Number,
    default = 10
  }
  
  property "OnOrderChanged" {
    type = Function
  }
end)