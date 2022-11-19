-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Core.Tracker"                     ""
-- ========================================================================= --
export {
  __UIElement__   = SLT.__UIElement__,
  Profiles        = SLT.Profiles,
  Database        = SLT.Database,
  SavedVariables  = SLT.SavedVariables
}

_Trackers       = System.Toolset.newtable(false, true)

__UIElement__()
class "SLT.TrackerMover" (function(_ENV)
  inherit "Mover"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Text = SLT.FontString
  }
  function __ctor() end 
end)

__UIElement__()
class "SLT.Tracker" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnPositionChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnMouseWheel(self, direction)
    local scrollBar = self:GetScrollBar()
    scrollBar:OnMouseWheel(direction)
  end

  local function OnScrollRangeChanged(self, xRange, yRange)
    local scrollBar = self:GetScrollBar()
    local scrollFrame = self:GetScrollFrame()
    
    local visibleHeight = scrollFrame:GetHeight()
    local contentHeight = visibleHeight + yRange
    scrollBar:SetVisibleExtentPercentage(visibleHeight / contentHeight)

    -- REVIEW: Should translate this feature directly in the ScrollBar class ?
    if self.ShowScrollBar and scrollBar:HasScrollableExtent() then 
      scrollBar:Show()
    else 
      scrollBar:Hide()
    end
  end

  local function OnScroll(self, value)
    local scrollFrame = self:GetScrollFrame()

    scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange() * value)
  end

  local function OnLockedChanged(self, value)
    if value then 
      self:ReleaseMover()
      Style[self].resizable = false
    else 
      self:ShowMover()
      Style[self].resizable = true
    end
  end

  local function OnTrackerStopMoving(self, mover)
    local left  = self:GetLeft()
    local top   = self:GetTop()

    self:OnPositionChanged(left, top)
  end

  local function OnShowScrollBarChanged(self, value)
    --- We show the scroll bar only if there is a scrollable content
    local scrollBar = self:GetScrollBar()

    if value and scrollBar:HasScrollableExtent() then 
      Style[scrollBar].visible = true
    else 
      Style[scrollBar].visible = false
    end
  end

  local function OnScrollBarPositionChanged(self, value, old)
    if value == "LEFT" then
      Style[self].ScrollBar.location = {
        Anchor("RIGHT", -15, 0, nil, "LEFT")
      }
    elseif value == "RIGHT" then 
      Style[self].ScrollBar.location = {
        Anchor("LEFT", 15, 0, nil, "RIGHT")
      }
    end
  end

  local function OnShowBorderChanged(self, new, old, prop)
    if prop == "ShowTopBorder" then 
      Style[self].TopBGTexture.visible = new 
    elseif prop == "ShowBottomBorder" then 
      Style[self].BottomBGTexture.visible = new 
    elseif prop == "ShowLeftBorder" then 
      Style[self].LeftBGTexture.visible = new 
    elseif prop == "ShowRightBorder" then 
      Style[self].RightBGTexture.visible = new 
    elseif prop == "ShowTopLeftBorder" then 
      Style[self].TopLeftBGTexture.visible = new 
    elseif prop == "ShowTopRightBorder" then 
      Style[self].TopRightBGTexture.visible = new 
    elseif prop == "ShowBottomLeftBorder" then 
      Style[self].BottomLeftBGTexture.visible = new 
    elseif prop == "ShowBottomRightBorder" then 
      Style[self].BottomRightBGTexture.visible = new 
    end
  end

  local function OnBorderColorChanged(self, new, old, prop)
    if prop == "TopBorderColor" then 
      Style[self].TopBGTexture.vertexColor = new 
    elseif prop == "BottomBorderColor" then 
      Style[self].BottomBGTexture.vertexColor = new 
    elseif prop == "LeftBorderColor" then 
      Style[self].LeftBGTexture.vertexColor = new 
    elseif prop == "RightBorderColor" then 
      Style[self].RightBGTexture.vertexColor = new 
    elseif prop == "TopLeftBorderColor" then 
      Style[self].TopLeftBGTexture.vertexColor = new 
    elseif prop == "TopRightBorderColor" then 
      Style[self].TopRightBGTexture.vertexColor = new 
    elseif prop == "BottomLeftBorderColor" then 
      Style[self].BottomLeftBGTexture.vertexColor = new 
    elseif prop == "BottomRightBorderColor" then 
      Style[self].BottomRightBGTexture.vertexColor = new 
    end
  end

  local function OnBorderSizeChanged(self, new, old, prop)
    if prop == "TopBorderSize" then 
      Style[self].TopBGTexture.height = new
      Style[self].TopLeftBGTexture.height = new
      Style[self].TopRightBGTexture.height = new
    elseif prop == "BottomBorderSize" then 
      Style[self].BottomBGTexture.height = new
      Style[self].BottomLeftBGTexture.height = new
      Style[self].BottomRightBGTexture.height = new
    elseif prop == "LeftBorderSize" then 
      Style[self].LeftBGTexture.width = new
      Style[self].TopLeftBGTexture.width = new
      Style[self].BottomLeftBGTexture.width = new 
    elseif prop == "RightBorderSize" then 
      Style[self].RightBGTexture.width = new 
      Style[self].TopRightBGTexture.width = new
      Style[self].BottomRightBGTexture.width = new
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetScrollBar(self)
    return self:GetChild("ScrollBar")
  end

  function GetScrollFrame(self)
    return self:GetChild("ScrollFrame")
  end

  function GetScrollContent(self)
    return self:GetScrollFrame():GetChild("Content")
  end

  function AcquireMover(self)
    local mover = self:GetChild("Mover")
    if not mover then 
      mover = SLT.TrackerMover.Acquire()
      mover:SetParent(self)
      mover:SetName("Mover")
      mover:InstantApplyStyle()
      mover.MoveTarget = self 
      mover.OnStopMoving = mover.OnStopMoving + self.OnTrackerStopMoving
    end 

    return mover
  end

  function ShowMover(self)
    local mover = self:AcquireMover()
    mover:Show() 
  end

  function ReleaseMover(self)
    local mover = self:GetChild("Mover")
    if mover then 
      mover.OnStopMoving = mover.OnStopMoving - self.OnTrackerStopMoving
      mover:Release()
    end
  end

  __Arguments__ { String + Number }
  function TrackContentType(self, contentID)
    Scorpio.FireSystemEvent("SLT_TRACKER_TRACK_CONTENT_TYPE", self, contentID)

    self.Contents[contentID] = true
  end
  
  __Arguments__ { String + Number }
  function UntrackContentType(self, contentID)
    Scorpio.FireSystemEvent("SLT_TRACKER_UNTRACK_CONTENT_TYPE", self, contentID)
    self.Contents[contentID] = false
  end

  __Arguments__ { String }
  function IsContentTracked(self, contentID)

    if self.Contents[contentID] then 
      return true 
    end
    return false
  end

  __Arguments__ { SLT.IView }
  function AddView(self, view)
    self.Views:Insert(view)
    view:SetParent(self:GetScrollContent())

    --- Register the events 
    view.OnSizeChanged = view.OnSizeChanged + self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged + self.OnViewOrderChanged
    view.OnShouldBeDisplayedChanged = view.OnShouldBeDisplayedChanged + self.OnViewShouldBeDisplayedChanged

    self:OnLayout()
    self:OnAdjustHeight()
  end

  __Arguments__ { SLT.IView }
  function RemoveView(self, view)
    self.Views:Remove(view)

    --- Unregister the events 
    view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged - self.OnViewOrderChanged
    view.OnShouldBeDisplayedChanged = view.OnShouldBeDisplayedChanged - self.OnViewShouldBeDisplayedChanged

    --- We call an instant layout and adjust height for avoiding a
    --- flashy behavior when the content has been removed.
    self:OnLayout()
    self:OnAdjustHeight()

    --- NOTE: We don't call the "Release" method of view because it will be done
    --- by the content type.
  end

  __Arguments__ { SLT.IView }
  function DisplayView(self, view)
    view:OnAcquire()
    view:SetParent(self:GetScrollContent())
    
    self:OnLayout()
    self:OnAdjustHeight()
  end

  __Arguments__ { SLT.IView }
  function HideView(self, view)
    view:OnRelease()

    self:OnLayout()
    self:OnAdjustHeight()
  end

  __Iterator__()
  function IterateViews(self)
    local yield = coroutine.yield
    local index = 0

    for _, view in self.Views:Sort("x,y=>x.Order<y.Order"):GetIterator() do 
      if view.ShouldBeDisplayed then
        index = index + 1
        yield(index, view)
      end
    end 
  end

  function OnLayout(self)
    local content = self:GetScrollContent()
    local previousView

    for index, view in self:IterateViews() do
      if index > 1 then 
        view:SetPoint("TOP", previousView, "BOTTOM", 0, -self.Spacing)
        view:SetPoint("LEFT")
        view:SetPoint("RIGHT")
      else
        view:SetPoint("TOP")
        view:SetPoint("LEFT")
        view:SetPoint("RIGHT")
      end

      previousView = view
    end
  end

  function Layout(self)
    if not self._pendingLayout then 
      self._pendingLayout = true 

      Scorpio.Delay(0.1, function() 
        local aborted = false
        if self._cancelLayout then 
          aborted = self._cancelLayout 
        end

        if not aborted then 
          self:OnLayout()
        end

        self._pendingLayout = nil
        self._cancelLayout = nil
      end)
    end 
  end

  function CancelLayout(self)
    if self._pendingLayout then 
      self._cancelLayout = true
    end
  end

  function OnAdjustHeight(self)
    local height = 0
    local count = 0
    local content = self:GetScrollContent()
    for _, view in self:IterateViews() do 
      count = count + 1
      height  = height + view:GetHeight()
    end
    
    height = height + 0 * math.max(0, count-1)

    content:SetHeight(height)
  end

  --- This is helper function will call "OnAdjustHeight".
  --- This is safe to call it multiple time in short time, resulting only a one 
  --- call of "OnAdjustHeight"
  function AdjustHeight(self)
    if not self._pendingAdjustHeight then 
      self._pendingAdjustHeight = true 

      Scorpio.Delay(0.1, function() 
        local aborted = false
        if self._cancelAdjustHeight then 
          aborted = self._cancelAdjustHeight 
        end

        if not aborted then 
          self:OnAdjustHeight()
        end

        self._pendingAdjustHeight = nil
      end)
    end 
  end
  
  --- Cancel the "OnAdjustHeight" call if there is one in queue.
  --- You probably do when the obj is releasing.
  function CancelAdjustHeight(self)
    if self._pendingAdjustHeight then 
      self._cancelAdjustHeight = true
    end
  end

  function OnAcquire(self)
    self:SetPersistent(true)
  end

  function OnRelease(self)
    self:SetPersistent(false)

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()

    self:CancelAdjustHeight()

    --- Untrack all contents tracked 
    for contentID in pairs(self.Contents) do 
      self:UntrackContentType(contentID)
      self.Contents[contentID] = nil
    end

    self.ID = nil
    self.Spacing = nil 
    self.Locked = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Views" {
    set     = false,
    default = function() return Array[SLT.IView]() end 
  }

  property "Contents" {
    set     = false,
    default = function() return {} end
  }

  property "Spacing" {
    type    = Number,
    default = 10
  }

  property "ID" {
    type = Number + String
  }

  property "ContentHeight" {
    type = Number,
    default = 1
  }

  property "Locked" {
    type = Boolean,
    default = true,
    handler = OnLockedChanged
  }

  property "ShowScrollBar" {
    type = Boolean,
    default = true,
    handler = OnShowScrollBarChanged
  }

  property "ScrollBarPosition" {
    type = String,
    default = "RIGHT",
    handler = OnScrollBarPositionChanged
  }

  property "ShowTopBorder" {
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged
  }

  property "ShowBottomBorder"{
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged
  }

  property "ShowLeftBorder" {
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged
  }

  property "ShowRightBorder" {
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged 
  }

  property "ShowTopLeftBorder" {
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged 
  }

  property "ShowTopRightBorder" {
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged
  }

  property "ShowBottomLeftBorder" {
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged 
  }

  property "ShowBottomRightBorder" {
    type = Boolean,
    default = false,
    handler = OnShowBorderChanged
  }

  property "TopBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "BottomBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "LeftBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "RightBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "TopLeftBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "TopRightBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "BottomLeftBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "BottomRightBorderColor" {
    type = ColorType,
    default = Color.BLACK,
    handler = OnBorderColorChanged
  }

  property "TopBorderSize" {
    type = Number,
    default = 1,
    handler = OnBorderSizeChanged
  }

  property "BottomBorderSize" {
    type = Number,
    default = 1,
    handler = OnBorderSizeChanged
  }

  property "LeftBorderSize" {
    type = Number,
    default = 1,
    handler = OnBorderSizeChanged
  }

  property "RightBorderSize" {
    type = Number,
    default = 1,
    handler = OnBorderSizeChanged
  }
  -----------------------------------------------------------------------------
  --                        Configuration Methods                            --
  -----------------------------------------------------------------------------
  enum "TrackerSettingType" {
    "position",
    "width",
    "height",
    "hidden",
    "locked",
    "scale",
    "showBackground",
    "backgroundColor",
    "showScrollBar",
    "scrollBarPosition",
    "scrollBarThumbColor",
    "contentTracked",
    "contentOrder",
    "showTopBorder",
    "showBottomBorder",
    "showLeftBorder",
    "showRightBorder",
    "showTopLeftBorder",
    "showTopRightBorder",
    "showBottomLeftBorder",
    "showBottomRightBorder",
    "topBorderColor",
    "bottomBorderColor",
    "leftBorderColor",
    "rightBorderColor",
    "topLeftBorderColor",
    "topRightBorderColor",
    "bottomLeftBorderColor",
    "bottomRightBorderColor",
    "topBorderSize",
    "bottomBorderSize",
    "leftBorderSize",
    "rightBorderSize"
  }

  __Arguments__ { Tracker, TrackerSettingType, Any * 0}
  __Static__() function private__ApplySetting(tracker, setting, ...)
    local isMainTracker = tracker.ID == "main"
    if setting == "position" then 
      local xPos, yPos = ...
      if not xPos and not yPos then 
        --- By default, the custom tracker are positioned to center andd the main tracker 
        --- to right 
        if isMainTracker then 
          tracker:SetPoint("RIGHT", -40, 0)
        else
          tracker:SetPoint("CENTER")
        end
      else 
        tracker:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPos or 0, yPos or 0)
      end
    elseif setting == "width" then 
      local width = ...
      Style[tracker].width = width
    elseif setting == "height" then
      local height = ... 
      Style[tracker].height = height
    elseif setting == "hidden" then 
      local hidden = ...
      if hidden then 
        tracker:Hide()
      else 
        tracker:Show()
      end
    elseif setting == "locked" then 
      local locked = ...
      --- By default,  the custom tracker are unlocked 
      if locked == nil and not isMainTracker then 
        tracker.Locked = false 
      else
        tracker.Locked = locked
      end
    elseif setting == "scale" then
      local scale = ...
      Style[tracker].scale = scale
    elseif setting == "showBackground" then
      local show = ... 
      Style[tracker].BackgroundTexture.visible = show
    elseif setting == "backgroundColor" then 
      local r, g, b, a = ...
      Style[tracker].BackgroundTexture.vertexColor = ColorType(r, g, b, a)
    elseif setting == "showScrollBar" then
      local show = ...
      Style[tracker].showScrollBar = show
    elseif setting == "scrollBarPosition" then 
      local position = ...
      Style[tracker].scrollBarPosition = position
    elseif setting == "scrollBarThumbColor" then
      local r, g, b, a = ...
      tracker:GetScrollBar():GetThumb():SetNormalColor(ColorType(r, g, b, a))
    elseif setting == "contentTracked" then 
      local contentId, tracked = ...
      if tracked == nil then 
        --- The main tracker still track the content unless this has been said 
        --- explicitely to no do it
        if isMainTracker then 
          tracker:TrackContentType(contentId)
        else
          tracker:UntrackContentType(contentId)
        end
      else
        if tracked then 
          tracker:TrackContentType(contentId)
        else
          tracker:UntrackContentType(contentId)
        end
      end
    elseif setting == "contentOrder" then 
      --- TODO
    elseif setting:match("show[%a]+Border") then 
      local show = ...
      Style[tracker][setting] = show
    elseif setting:match("[%a]+BorderColor") then 
      local r, g, b, a = ...
      Style[tracker][setting] = ColorType(r, g, b, a)
    elseif setting:match("[%a]+BorderSize") then 
      local size = ...
      Style[tracker][setting] = size
    end
  end

  function ApplySetting(trackerOrId, setting, ...)
    local tracker
    if trackerOrId == "string" then
      tracker = _Trackers[trackerOrId]
    elseif Class.IsObjectType(trackerOrId, Tracker) then 
      tracker = trackerOrId
    end

    if tracker then 
      private__ApplySetting(tracker, setting, ...)
    end
  end

  __Arguments__ { String, TrackerSettingType, Any * 0}
  __Static__() function private__SaveSetting(trackerId, setting, ...)
    local isMainTracker = trackerId == "main"

    --- We set the base path for avoiding to have to give it every time 
    SavedVariables.SetBasePath("trackers", trackerId)

    --- Tracker position
    if setting == "position" then
      local xPos, yPos = ...
      SavedVariables.Profile().SaveValue("xPos", xPos)
      SavedVariables.Profile().SaveValue("yPos", yPos)
    --- Tracker width 
    elseif setting == "width" then 
      local width = ...
      SavedVariables.Profile().SaveValue("width", width)
    --- Tracker height
    elseif setting == "height" then 
      local height = ...
      SavedVariables.Profile().SaveValue("height", height)
    --- Tracker visibility 
    elseif setting == "hidden" then
      local hidden = ...
      SavedVariables.Profile().SaveValue("hidden", hidden)
    --- Tracker locked 
    elseif setting == "locked" then
      local locked = ...
      SavedVariables.Profile().SaveValue("locked", locked)
    --- Tracker scale
    elseif setting == "scale" then 
      local scale = ...
      SavedVariables.Profile().SaveValue("scale", scale)
    --- Tracker -> Background -> Show
    elseif setting == "showBackground" then
      local show = ...
      SavedVariables.Profile().SaveValue("showBackground", show)
    --- Tracker -> Background -> Color
    elseif setting == "backgroundColor" then 
      local r, g, b, a = ...
      SavedVariables.Profile().SaveValue("backgroundColor", { r = r, g = g, b = b, a = a })
    --- Tracker -> Show ScrollBar
    elseif setting == "showScrollBar" then 
      local showScrollBar = ...
      SavedVariables.Profile().Path("scrollBar").SaveValue("show", showScrollBar)
    --- Tracker ->  Scroll Bar Position
    elseif setting == "scrollBarPosition" then 
      local scrollBarPosition = ...
      SavedVariables.Profile().Path("scrollBar").SaveValue("position", scrollBarPosition)
    --- ScrollBar -> Thumb ColorType
    elseif setting == "scrollBarThumbColor" then
      local r, g, b, a = ...
      SavedVariables.Profile().Path("scrollBar").SaveValue("thumbColor", { r = r, g = g, b = b, a = a})
    --- Tracker -> Content Tracked
    elseif setting == "contentTracked" then 
      local contentId, tracked = ...
      --- Will saved for the next operation
      SavedVariables.Profile().Path("contents", contentId)
      --- The main still track all contents unless this 
      if isMainTracker then 
        --- The main tracker still track the content unless this has been said 
        --- explicitely to no do it
        if tracked ~= nil and tracked == false then  
          SavedVariables.SaveValue("tracked", false)
        else
          SavedVariables.SaveValue("tracked", nil)
        end
      else
        if tracked then 
          SavedVariables.SaveValue("tracked", true)
        else
          SavedVariables.SaveValue("tracked", nil)
        end
      end
    elseif setting == "contentOrder" then 
      -- TODO
    elseif setting:match("show[%a]+Border") then 
      local show = ...
      SavedVariables.Profile().Path("borders").SaveValue(setting, show)
    elseif setting:match("[%a]+BorderColor") then 
      local r, g, b, a = ...
      SavedVariables.Profile().Path("borders").SaveValue(setting, { r = r, g = g, b = b, a = a })
    elseif setting:match("[%a]+BorderSize") then 
      local size = ...
      SavedVariables.Profile().Path("borders").SaveValue(setting, size)
    end

    --- We reset the base path
    SavedVariables.SetBasePath()
  end

  function SaveSetting(trackerOrId, setting, ...)
    if type(trackerOrId) == "string" then 
      private__SaveSetting(trackerOrId, setting, ...)
    else
      private__SaveSetting(trackerOrId.ID, setting, ...)
    end
  end

  function ApplyAndSaveSetting(trackerOrId, setting, ...)
    ApplySetting(trackerOrId, setting, ...)
    SaveSetting(trackerOrId, setting, ...)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    ScrollFrame = ScrollFrame,
    ScrollBar   = SLT.ScrollBar,
    Resizer     = Resizer,
    {
      ScrollFrame = {
        Content = Frame
      }
    }
  }
  function __ctor(self)
    local scrollFrame = self:GetScrollFrame()
    scrollFrame:SetClipsChildren(true)

    scrollFrame.OnScrollRangeChanged = scrollFrame.OnScrollRangeChanged + function(_, xrange, yrange)
      OnScrollRangeChanged(self, xrange, yrange)
    end

    scrollFrame.OnMouseWheel = scrollFrame.OnMouseWheel + function(_, value)
      OnMouseWheel(self, value)
    end

    local scrollBar = self:GetScrollBar()
    scrollBar:Hide()
    scrollBar.OnScroll = scrollBar.OnScroll + function(_, value)
      OnScroll(self, value)
    end


    local content = self:GetScrollContent()
    content:SetHeight(1)
    content:SetWidth(scrollFrame:GetWidth())
    scrollFrame:SetScrollChild(content)

    scrollFrame.OnSizeChanged = scrollFrame.OnSizeChanged + function(_, width)
      content:SetWidth(width)
    end

    self.OnViewOrderChanged = function() self:Layout() end 
    self.OnViewSizeChanged = function() self:AdjustHeight() end 

    self.OnViewShouldBeDisplayedChanged = function(view, new)
      if new then 
        self:DisplayView(view)
      else 
        self:HideView(view)
      end
    end

    self.OnTrackerStopMoving = function(mover, ...) OnTrackerStopMoving(self, mover, ...) end
  end
end)

local function OnTrackerHideHandler(self)
  --- We save the changed to the DB only if the tracker is marked as persistent
   --- at this time.
  if self:IsPersistent() then
    Profiles.PrepareDatabase()
      
    if Database.SelectTable(true, "trackers", self.ID) then 
      Database.SetValue("hidden", true)
    end
  end
end

local function OnTrackerShowHandler(self)
  --- We save the changed to the DB only if the tracker is marked as persistent
   --- at this time.
  if self:IsPersistent() then
    Profiles.PrepareDatabase()
      
    if Database.SelectTable(true, "trackers", self.ID) then 
      Database.SetValue("hidden", nil)
    end
  end
end

local function OnTrackerSizeChanged(self, width, height)
  self:SaveSetting("width", Round(width))
  self:SaveSetting("height", Round(height))
end

local function OnTrackerPositionChanged(self, xPos, yPos)
  local top   = self:GetTop()
  local left  = self:GetLeft()

  self:SaveSetting("position", left, top)
end

local function private__LoadContentsForTracker(tracker)
  for _, content in SLT.API.IterateContentTypes() do 
    local tracked = SavedVariables.Profile()
      .Path("trackers", tracker.ID, "contents", content.ID) 
      .GetValue("tracked")

    tracker:ApplySetting("contentTracked", content.ID, tracked)
  end
end

local function private__NewTracker(id)
  local tracker = SLT.Tracker.Acquire()
  tracker:SetParent(UIParent)
  tracker.ID = id 

  --- We set the base path for avoiding to give it every time 
  SavedVariables.SetBasePath("trackers", id)

  --- Trackers global saved variables
  local xPos    = SavedVariables.Profile().GetValue("xPos")
  local yPos    = SavedVariables.Profile().GetValue("yPos")
  local width   = SavedVariables.Profile().GetValue("width") or 300
  local height  = SavedVariables.Profile().GetValue("height") or 325
  local hidden  = SavedVariables.Profile().GetValue("hidden") 
  local locked  = SavedVariables.Profile().GetValue("locked")
  local scale   = SavedVariables.Profile().GetValue("scale")
  local showBg  = SavedVariables.Profile().GetValue("showBackground") or false
  local bgColor = SavedVariables.Profile().GetValue("backgroundColor")

  --- Trackers scrollbar saved variables
  local showScrollBar     = SavedVariables.Profile().Path("scrollBar").GetValue("show")
  local scrollBarPosition = SavedVariables.Profile().Path("scrollBar").GetValue("position")
  local thumbColor        = SavedVariables.Profile().Path("scrollBar").GetValue("thumbColor")
  local borderSettings    = SavedVariables.Profile().GetValue("borders")

  --- Apply Settings 
  tracker:ApplySetting("position", xPos, yPos)
  tracker:ApplySetting("width", width)
  tracker:ApplySetting("height", height)
  tracker:ApplySetting("hidden", hidden)
  tracker:ApplySetting("locked", locked)
  tracker:ApplySetting("scale", scale)
  tracker:ApplySetting("showScrollBar", showScrollBar)
  tracker:ApplySetting("scrollBarPosition", scrollBarPosition)
  tracker:ApplySetting("showBackground", showBg)
  
  if bgColor then 
    tracker:ApplySetting("backgroundColor", bgColor.r, bgColor.g, bgColor.b, bgColor.a)
  end

  if borderSettings then 
    for setting, value in pairs(borderSettings) do
      if setting:match("[%a]+BorderColor") then 
        tracker:ApplySetting(setting, value.r, value.g, value.b, value.a)
      else 
        tracker:ApplySetting(setting, value)
      end
    end
  end



  if thumbColor then 
    tracker:ApplySetting("scrollBarThumbColor", thumbColor.r, thumbColor.g, thumbColor.b, thumbColor.a)
  end

  --- NOTE: THe contents tracked will be handled later

  --- Add some handlers
  tracker.OnSizeChanged = tracker.OnSizeChanged + OnTrackerSizeChanged
  tracker.OnPositionChanged = tracker.OnPositionChanged + OnTrackerPositionChanged

  --- Important: Don't forget to reset the bath path for avoiding unexpected issued 
  --- for next operations
  SavedVariables.SetBasePath()

  _Trackers[id] = tracker

  return tracker
end

local function private__DeleteTracker(tracker)
  local trackerId = tracker.ID

  Scorpio.FireSystemEvent("SLT_TRACKER_DELETED", tracker)

  --- Remove handlers
  tracker.OnSizeChanged = tracker.OnSizeChanged - OnTrackerSizeChanged
  tracker.OnPositionChanged = tracker.OnPositionChanged - OnTrackerPositionChanged

  --- Remove the tracker from the list
  SavedVariables.Path("list", "tracker").SetValue(trackerId, nil)
  
  --- Remove the tracker settings for global and all profiles 
  SavedVariables.Path("trackers").All().SetValue(trackerId, nil)

  _Trackers[trackerId] = nil 

  tracker:Release()
end

-------------------------------------------------------------------------------
-- Enhancing the API                                                         --
-------------------------------------------------------------------------------
class "SLT.API" (function(_ENV)

  --- This is the public API for creating a tracker, it will prevent a tracker 
  --- to be created if the id is "main"
  __Arguments__ { String }
  __Static__() function NewTracker(id)
    if id == "main" then 
      return 
    end

    local tracker = private__NewTracker(id)
    --- Don't forget to add in the tracker list else it won't be created the 
    --- next time
    SavedVariables.Path("list", "tracker").SaveValue(id, true)

    --- Load the contents tracked
    private__LoadContentsForTracker(tracker)

    Scorpio.FireSystemEvent("SLT_TRACKER_CREATED", tracker)

    return tracker
  end

  --- This is the public API for deleting a tracker, the main tracker cannot be 
  --- deleted
  __Arguments__ { SLT.Tracker + String}
  __Static__() function DeleteTracker(trackerOrId)
    local tracker
    if type(trackerOrId) == "string" then 
      if trackerOrId == "main" then 
        return 
      end
      tracker = _Trackers[trackerOrId]
    else
      tracker = trackerOrId
    end

    if tracker == _MainTracker then 
      return 
    end

    private__DeleteTracker(tracker)
  end


  __Arguments__ { String }
  __Static__() function GetTracker(id)
    return _Trackers[id]
  end

  __Iterator__()
  __Arguments__ { Boolean/true}
  function IterateTrackers(includeMainTracker)
    local yield = coroutine.yield
    for trackerId, tracker in pairs(_Trackers) do
      local isIgnored = false

      if trackerId == "main" and includeMainTracker == false then 
        isIgnored = true
      end
      
      if not isIgnored then 
        yield(trackerId, tracker)
      end
    end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SLT.TrackerMover] = {
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
    },
    backdropColor = { r = 0, g = 1, b = 0, a = 0.3},
    location = {
      Anchor("BOTTOMLEFT", 0, 0, nil, "TOPLEFT"),
      Anchor("BOTTOMRIGHT", 0, 0, nil, "TOPRIGHT")
    },
    Text = {
      text = "Click here to move the tracker",
      setAllPoints = true,
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13)
    }
  },

  [SLT.Tracker] = {
    size = Size(300, 325),
    resizable = true,
    movable = true,

    ScrollFrame = {
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMRIGHT")
      }
    },

    ScrollBar = {
      size = Size(6, 244),
      location = {
        Anchor("LEFT", 15, 0, nil, "RIGHT")
      }
    },

    BackgroundTexture = {
      visible = false,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BACKGROUND",
      vertexColor = Color.BLACK,
      setAllPoints = true,
    },

    --- Corner Border 
    TopLeftBGTexture = {
      visible = false,
      width = 1,
      height = 1,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("BOTTOMRIGHT", 0, 0, nil, "TOPLEFT")
      }
    },

    TopRightBGTexture = {
      visible = false,
      width = 1,
      height = 1,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("BOTTOMLEFT", 0, 0, nil , "TOPRIGHT")
      }
    },

    BottomLeftBGTexture = {
      visible = false,
      width = 1,
      height = 1,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("TOPRIGHT", 0, 0, nil, "BOTTOMLEFT")
      }
    },

    BottomRightBGTexture = {
      visible = false,
      width = 1,
      height = 1,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("TOPLEFT", 0, 0, nil, "BOTTOMRIGHT")
      }
    },

    --- Edge Borders 
    TopBGTexture =  {
      visible = false,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "TopRightBGTexture", "BOTTOMLEFT")
      }
    },
    BottomBGTexture =  {
      visible = false,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("TOPLEFT", 0, 0, "BottomLeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "BOTTOMLEFT")
      }
    },
    LeftBGTexture =  {
      visible = false,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "BOTTOMLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomLeftBGTexture", "TOPRIGHT")
      }
    },
    RightBGTexture =  {
      visible = false,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLACK,
      location = {
        Anchor("TOPLEFT", 0, 0, "TopRightBGTexture", "BOTTOMLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "TOPRIGHT")
      }
    }
  }
})

function OnEnable(self)
  --- Create the main tracker 
  _MainTracker = private__NewTracker("main")
end


__SystemEvent__()
__Async__()
function PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
  if isInitialLogin or isReloadingUi then
    local trackerBottom = _MainTracker:GetBottom()
    --- Important ! We have to delay the tracking of content type after an 
    --- initial and a reloading ui for they getting a valid "GetBottom" is important
    --- to compute the height of their frame. 
    --- So we delay until the tracker "GetBottom" returns a no nil value, saying GetBottom
    --- now return valid value. 
    while not trackerBottom do 
      trackerBottom = _MainTracker:GetBottom()
      Next()
    end

    --- Load the contents tracker for the main tracker 
    private__LoadContentsForTracker(_MainTracker)

    --- Create the custom trackers, and load the contents tracked by them 
    local trackers = SavedVariables.Path("list").GetValue("tracker")
    if trackers then 
      for trackerId in pairs(trackers) do
        local tracker = private__NewTracker(trackerId)
        private__LoadContentsForTracker(tracker)
      end
    end
  end
end

__SystemEvent__()
function SLT_HIDE_TRACKERS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker:ApplyAndSaveSetting("hidden", true)
  end  
end

__SystemEvent__()
function SLT_SHOW_TRACKERS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker:ApplyAndSaveSetting("hidden", false)
  end  
end

__SystemEvent__()
function SLT_LOCK_TRACKERS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker:ApplyAndSaveSetting("locked", true)
  end
end

__SystemEvent__()
function SLT_UNLOCK_TRACKERS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker:ApplyAndSaveSetting("locked", false)
  end
end

__SystemEvent__()
function SLT_SHOW_TRACKER(trackerId)
  if not trackerId then 
    return 
  end

  local tracker = SLT.API.GetTracker(trackerId)
  if tracker then 
    tracker:ApplyAndSaveSetting("hidden", false)
  end
end

__SystemEvent__()
function SLT_HIDE_TRACKER(trackerId)
  if not trackerId then 
    return 
  end

  local tracker = SLT.API.GetTracker(trackerId)
  if tracker then 
    tracker:ApplyAndSaveSetting("hidden", true)
  end
end

__SystemEvent__()
function SLT_LOCK_TRACKER(trackerId)
  if not trackerId then 
    return 
  end

  local tracker = SLT.API.GetTracker(trackerId)
  if tracker then 
    tracker:ApplyAndSaveSetting("locked", true)
  end
end

__SystemEvent__()
function SLT_UNLOCK_TRACKER(trackerId)
  if not trackerId then 
    return 
  end

  local tracker = SLT.API.GetTracker(trackerId)
  if tracker then 
    tracker:ApplyAndSaveSetting("locked", false)
  end
end

__SystemEvent__()
function SLT_TOGGLE_TRACKER(trackerId) 
  if not trackerId then 
    return 
  end

  local tracker = SLT.API.GetTracker(trackerId)
  if tracker then 
    tracker:ApplyAndSaveSetting("hidden", tracker:IsShown())
  end
end

__SystemEvent__()
function SLT_TOGGLE_LOCK_TRACKER(trackerId) 
  if not trackerId then 
    return 
  end

  local tracker = SLT.API.GetTracker(trackerId)
  if tracker then 
    tracker:ApplyAndSaveSetting("locked", not tracker.Locked)
  end
end


__SystemEvent__()
function SLT_SHOW_ANCHORS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker.Locked = false 
  end
end

__SystemEvent__()
function SLT_HIDE_ANCHORS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker.Locked = true 
  end
end
