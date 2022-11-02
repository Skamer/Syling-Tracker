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
  __UIElement__ = SLT.__UIElement__,
  Profiles      = SLT.Profiles,
  Database      = SLT.Database
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
    if scrollBar:HasScrollableExtent() then 
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

    --- We save the changed to the DB only if the tracker is marked as persistent
    --- at this time.
    if self:IsPersistent() then 
      Profiles.PrepareDatabase()

      if Database.SelectTable(true, "trackers", self.ID) then
        Database.SetValue("locked", value)
      end
    end
  end

  local function OnSizeChanged(self, width, height)
    --- We save the changed to the DB only if the tracker is marked as persistent
    --- at this time.
    if self:IsPersistent() then 
      Profiles.PrepareDatabase()

      if Database.SelectTable(true, "trackers", self.ID) then 
        Database.SetValue("width", Round(width))
        Database.SetValue("height", Round(height))
      end
    end
  end

  local function OnTrackerStopMoving(self, mover)
    --- We save the changed to the DB only if the tracker is marked as persistent
    --- at this time.
    if self:IsPersistent() then
      local top   = self:GetTop()
      local left  = self:GetLeft()

      Profiles.PrepareDatabase()

      if Database.SelectTable(true, "trackers", self.ID) then 
        Database.SetValue("xPos", left)
        Database.SetValue("yPos", top)
      end
    end
  end

  local function OnShowScrollBarChanged(self, value)
    Style[self].ScrollBar.visible = value

    --- We save the changed to the DB only if the tracker is marked as persistent
    --- at this time.
    if self:IsPersistent() then 
      Profiles.PrepareDatabase()

      if Database.SelectTable(true, "trackers", self.ID, "scrollBar") then
        Database.SetValue("show", value)
      end
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

    --- We save the changed to the DB only if the tracker is marked as persistent
    --- at this time.
    if self:IsPersistent() then 
      Profiles.PrepareDatabase()

      if Database.SelectTable(true, "trackers", self.ID, "scrollBar") then
        Database.SetValue("position", value)
      end
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

    if self:IsPersistent() then 
      Profiles.PrepareDatabase()
      if self.ID == "main" then 
        if Database.SelectTable(false, "trackers", self.ID, "contents", contentID) then 
          Database.SetValue("tracked", nil)
        end
      else 
        if Database.SelectTable(true, "trackers", self.ID, "contents", contentID) then 
          Database.SetValue("tracked", true)
        end
      end
    end
  end
  
  __Arguments__ { String + Number }
  function UntrackContentType(self, contentID)
    Scorpio.FireSystemEvent("SLT_TRACKER_UNTRACK_CONTENT_TYPE", self, contentID)
    self.Contents[contentID] = false

    if self:IsPersistent() then 
      Profiles.PrepareDatabase()
      if self.ID == "main" then 
        if Database.SelectTable(true, "trackers", self.ID, "contents", contentID) then 
          Database.SetValue("tracked", false)
        end
      else
        if Database.SelectTable(false, "trackers", self.ID, "contents", contentID) then
          Database.SetValue("tracked", nil)
        end
      end
    end
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


  function LoadContentSettings(self, settings)
    self:SetPersistent(false)

    --- The settings can be given as argument to gain time
    if not settings then 
      Profiles.PrepareDatabase()
      if Database.SelectTable(false, "trackers", self.ID) then 
        settings = Database.GetValue("contents")
      end
    end
    
    
    --- The "main" tracker always try to track all contents type unless it's 
    --- explicitely says not to do it. 
    --- In contrary of "custom" tracker which needs to explicitely set to true 
    --- for tracking the contents.
    for  _, content in SLT.API.IterateContentTypes() do 
      local isTracked = false 
      local contentSettings = settings and settings[content.ID]
      local contentTrackedSetting = contentSettings and contentSettings.tracked

      if self.ID == "main" then 
        if contentTrackedSetting == nil or contentTrackedSetting == true then 
          isTracked = true 
        end 
      else
        if contentTrackedSetting then 
          isTracked = true 
        end 
      end

      if isTracked then 
        self:TrackContentType(content.ID)
      end
    end

    self:SetPersistent(true)
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
    self.OnSizeChanged = self.OnSizeChanged + OnSizeChanged
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


--- Private function for create a tracker
local function __NewTracker(id)
  local tracker = SLT.Tracker.Acquire()
  tracker.ID = id 

  --- We mark temporaly the tracker as non persistent as we load the settings 
  --- from the db 
  tracker:SetPersistent(false)

  Profiles.PrepareDatabase()
  local width, height, xPos, yPos, locked, hidden, scrollBar 
  if Database.SelectTable(false, "trackers", id) then 
    xPos = Database.GetValue("xPos")
    yPos = Database.GetValue("yPos")
    width = Database.GetValue("width") or 300
    height = Database.GetValue("height") or 325
    hidden = Database.GetValue("hidden")
    scrollBar = Database.GetValue("scrollBar")
  end

  if not xPos and not yPos then 
    tracker:SetPoint("RIGHT", -40, 0)
  else
    tracker:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPos or 0, yPos or 0)
  end

  --- The "main" tracker always try to track all contents type unless it's 
  --- explicitely says not to do it. 
  --- In contrary of "custom" tracker which needs to explicitely set to true 
  --- for tracking the contents.

  --- As the "main" tracked is created before all others trackers, we want to 
  --- delay the content tracking, so we manually call it for later.
  if id ~= "main" then 
    local contentsTracked = Database.GetValue("contents")
    tracker:LoadContentSettings(contentsTracked)
  end

  Style[tracker].width = width
  Style[tracker].height = height
  Style[tracker].locked = locked

  if hidden then 
    tracker:Hide()
  end

  if scrollBar then 
    if scrollBar.show then 
      Style[tracker].showScrollBar = scrollBar.show
    end

    if scrollBar.position then 
      Style[tracker].scrollBarPosition = scrollBar.position
    end
  end

  _Trackers[id] = tracker

  tracker.OnShow = tracker.OnShow + OnTrackerShowHandler
  tracker.OnHide = tracker.OnHide + OnTrackerHideHandler

  --- Reset the tracker as persistent
  tracker:SetPersistent(true)

  return tracker

end

--- Private function for deleting a tracker
local function __DeleteTracker(tracker)
  local trackerId = tracker.ID
  
  Scorpio.FireSystemEvent("SLT_TRACKER_DELETED", tracker)
  
  tracker.OnShow = tracker.OnShow - OnTrackerShowHandler
  tracker.OnHide = tracker.OnHide - OnTrackerHideHandler

  Database.SelectRoot()
  if Database.SelectTable(false, "list", "tracker") then 
    Database.SetValue(trackerId, nil)
  end

  Profiles.RemoveValueForAllProfiles(trackerId, "trackers")

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

    local tracker = __NewTracker(id)

    Database.SelectRoot()
    if Database.SelectTable(true, "list", "tracker") then 
      Database.SetValue(id, true)
    end

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

    __DeleteTracker(tracker)
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
    }
  }
})

function OnEnable(self)
  --- Create the main tracker 
  _MainTracker = __NewTracker("main")
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

    --- Load the contents tracked for the main tracker
    _MainTracker:LoadContentSettings()


    --- Create the custom tracker, and load the contents tracked by them
    Database.SelectRoot()
    if Database.SelectTable(false, "list") then 
      local trackers = Database.GetValue("tracker")
      if trackers then 
        for trackerId, _ in pairs(trackers) do
          __NewTracker(trackerId)
        end
      end
    end

    _MainTracker.Locked = false
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

__SystemEvent__()
function SLT_HIDE_TRACKERS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker:Hide()
  end  
end

__SystemEvent__()
function SLT_SHOW_TRACKERS()
  for _, tracker in SLT.API.IterateTrackers() do 
    tracker:Show()
  end  
end