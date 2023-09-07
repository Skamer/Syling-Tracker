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
  GetCurrentTarget        = Scorpio.UI.Style.GetCurrentTarget,
  GetNearestFrameForType  = Utils.GetNearestFrameForType
}

__UIElement__()
class "Tracker" (function(_ENV)
  inherit "Frame" extend "IQueueLayout" "IQueueAdjustHeight"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  __Bubbling__ { Resizer = "OnStopResizing" }
  event "OnStopResizing"

  event "OnStopMoving"
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
      Style[self].Mover           = NIL
      Style[self].movable         = false
      Style[self].resizable       = false
    else
      Style[self].movable         = true 
      Style[self].resizable       = true
      Style[self].Mover.visible   = true
    end
  end

  __Async__()
  function StopMovingOrSizing(self)
    super.StopMovingOrSizing(self)

    Next()

    OnStopMoving(self)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String, Boolean/true }
  function AcquireSettingSubject(self, id, createOnNotFound)
    local subjects = self.__settingSubjects

    if not subjects and createOnNotFound then 
      subjects = {}
      self.__settingSubjects = subjects 
    elseif not subjects then
      return nil, false 
    end


    local subject = subjects[id]
    local isNew = false 

    if not subject and createOnNotFound then 
      subject = BehaviorSubject()
      subjects[id] = subject 
      isNew = true 
    end

    return subject, isNew
  end


  __Iterator__()
  function IterateSettingSubjects(self)
    local yield = coroutine.yield
    local subjects = self.__settingSubjects

    if subjects then 
      for settingID, subject in pairs(subjects) do 
        yield(settingID, subject)
      end
    end
  end

  __Arguments__ { IView}
  function AddView(self, view)
    self.Views:Insert(view)
    view:SetParent(self:GetScrollContent())
    view:Show()

    -- Bind the events 
    view.OnSizeChanged = view.OnSizeChanged + self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged + self.OnViewOrderChanged
    -- view.OnShouldBeDisplayedChanged = view.OnShouldBeDisplayedChanged + self.OnShouldBeDisplayedChanged

    self:OnLayout()
    self:OnAdjustHeight()
  end

  __Arguments__ { IView }
  function RemoveView(self, view)
    self.Views:Remove(view)

    -- Unbind the events 
    view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged - self.OnViewOrderChanged
    -- view.OnShouldBeDisplayedChanged = view.OnShouldBeDisplayedChanged - self.OnShouldBeDisplayedChanged

    -- We call an instant layout and adjust height for avoiding a 
    -- flashy behavior when the content has been removed.
    self:OnLayout()
    self:OnAdjustHeight()

    -- NOTE: We don't call the "Release" method of view because it will be done 
    -- by the content type
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
        view:SetPoint("TOP", previousView, "BOTTOM", 0, -10)
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

  function OnAdjustHeight(self)
    -- IMPORTANT: For avoiding the content height might not be computed and 
    -- not displayed, we need to use '1' as minimun height.
    local height = 1
    local count = 0
    local content = self:GetScrollContent()
    for _, view in self:IterateViews() do 
      count = count + 1
      height = height + view:GetHeight()
    end

    height = height + 10 * math.max(0, count - 1)

    content:SetHeight(height)
  end

  __Arguments__ { String }
  function TrackContent(self, contentID)
    Scorpio.FireSystemEvent("SylingTracker_TRACK_CONTENT", self, contentID)
  end

  __Arguments__ { String }
  function UntrackContent(self, contentID)
    Scorpio.FireSystemEvent("SylingTracker_UNTRACK_CONTENT", self, contentID)
  end

  __Arguments__ { String }
  function IsContentTracked(self, contentID)
    if self.ContentsTracked[contentID] then 
      return true 
    end

    return false 
  end
  
  function GetScrollBar(self)
    return self:GetChild("ScrollBar")
  end

  function GetScrollFrame(self)
    return self:GetChild("ScrollFrame")
  end

  function GetScrollContent(self)
    return self:GetScrollFrame():GetChild("Content")
  end

  function SetSetting(self, setting, value, notify)
    return API.SetTrackerSetting(self, setting, value, notify)
  end

  function GetSetting(self, setting)
    return API.GetTrackerSetting(self, setting)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------  
  property "id" {
    type = String
  }

  property "Enabled" {
    type      = Boolean,
    default   = true,
  }

  property "Locked" {
    type      = Boolean,
    default   = true,
    handler   = OnLockedChanged
  }

  property "ShowScrollBar" {
    type = Boolean,
    default = true,
  }

  property "Views" {
    set = false, 
    default = function() return Array[IView]() end 
  }

  property "ContentsTracked" {
    set = false, 
    default = function() return {} end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    ScrollFrame = ScrollFrame,
    ScrollBar = ScrollBar,
    Resizer = Resizer,
    {
      ScrollFrame = {
        Content = Frame
      }
    }
  }    
  function __ctor(self)
    local scrollFrame =self:GetScrollFrame()
    scrollFrame:SetClipsChildren(true)

    scrollFrame.OnScrollRangeChanged = scrollFrame.OnScrollRangeChanged + function(_, xRange, yRange)
      OnScrollRangeChanged(self, xRange, yRange)
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

    -- @TODO: Finish the handlers part
    self.OnViewOrderChanged = function() end 
    self.OnViewSizeChanged = function() self:AdjustHeight() end 
  end
end)
-------------------------------------------------------------------------------
--                                   API                                     --
-------------------------------------------------------------------------------
TRACKERS = System.Toolset.newtable(false, true)

local function OnTrackerStopMoving(tracker)
  local left = tracker:GetLeft()
  local top = tracker:GetTop()


  tracker:SetSetting("position", Position(left, top), false)

  -- tracker:SetSetting("position", Position(left, top), false)
end

local function OnTrackerStopResizing(tracker)
  local width   = Round(tracker:GetWidth())
  local height  = Round(tracker:GetHeight())

  tracker:SetSetting("size", Size(width, height), false)
  -- tracker:SetSetting("size", Size(width, height), false)
end


local function private__NewTracker(id)
  local tracker = Tracker.Acquire()
  tracker.id = id
  tracker:SetParent(UIParent)

  -- We set the base path for avoiding to give it every time. 
  SavedVariables.SetBasePath("trackers", id)

  -- NOTE: As there a delay between the skin process, the subjects may not be 
  -- yet created, so this iteration is not run. This case is covered by 
  -- API.FromTrackerSetting function. 
  --
  -- Call InstantApplyTracker on the tracker before will run this iterator but 
  -- this is not needed, and this iterator is here for cover thise case where 
  -- an instant apply style is called. 
  for settingID, subject in tracker:IterateSettingSubjects() do 
    local value = SavedVariables.Profile().GetValue(settingID)
    subject:OnNext(value, tracker)
  end


  -- Important: Don't forget to reset the base path for avoiding unexpected issues
  -- for next operations. 
  SavedVariables.SetBasePath()

  -- NOTE: The context tracker will be handled later. 

  -- @TODO: Bind handlers
  -- tracker.OnTrackerMoved = tracker.OnTrackerMoved + OnTrackerStopMoving
  -- tracker.OnTrackerResized = tracker.OnTrackerResized + OnTrackerStopResized


  tracker.OnStopResizing  = tracker.OnStopResizing + OnTrackerStopResizing
  tracker.OnStopMoving    = tracker.OnStopMoving + OnTrackerStopMoving

  TRACKERS[id] = tracker

  return tracker
end

--- Create an tracker. 
--- 
--- @param id the tracker id to register (note: the id 'main' is reserved)
__Arguments__ { String }
function API.NewTracker(id)
  -- the 'main' id is reserved for the main tracker. 
  if id == "main" then 
    return 
  end

  local tracker = private__NewTracker(id)

  -- Don't forget to add in the tracker list else it won't be persisted for 
  -- the next time.
  SavedVariables.Path("list", "tracker").SaveValue(id, true)

  -- Load the contents tracker 
  -- @TODO: private__LoadContentsForTracker(tracker)

  -- Trigger a system event for notifying the outside
  Scorpio.FireSystemEvent("SylingTracker_TRACKER_CREATED", tracker)

  return tracker
end

local function private__DeleteTracker(tracker)
  local trackerID = tracker.id 

  Scorpio.FireSystemEvent("SylingTracker_TRACKER_DELETED", tracker)

  -- Remove handlers 
  tracker.OnStopResizing      = tracker.OnStopResizing - OnTrackerStopResizing
  tracker.OnPositionChanged   = tracker.OnPositionChanged - OnTrackerPositionChanged

  -- Remove the tracker from the list 
  SavedVariables.Path("list", "tracker").SetValue(trackerID, nil)

  -- Remove the tracker setting for global and all profiles 
  SavedVariables.Path("trackers").All().SetValue(trackerID, nil)

  TRACKERS[trackerID] = nil 

  tracker:Release()
end

--- Delete a tracker. 
--- note: the main tracker cannot be deleted.
---
--- @param the tracker object or id to delete 
__Arguments__ { Tracker + String  }
__Static__() function API.DeleteTracker(trackerOrID)
  local tracker
  if type(trackerOrID) == "string" then 
    tracker = trackerOrID
  else
    tracker = TRACKERS[trackerOrID]
  end

  if not tracker or tracker.id == "main" then 
    return 
  end

  private__DeleteTracker(tracker)
end

--- Return an iterafor for the trackers 
--- 
--- @param includeMainTracker if the main tracker should be included
--- @param includeDisabledTrackers if the disabled trackers soulld be included
__Iterator__()
__Arguments__ { Boolean/true, Boolean/true }
__Static__() function API.IterateTrackers(includeMainTracker, includeDisabledTrackers)
  local yield = coroutine.yield

  for trackerID, tracker in pairs(TRACKERS) do 
    local isIgnored = false 

    if trackerID == "main" and includeMainTracker == false then 
      isIgnored = true 
    end

    if tracker.Enabled == false and includeDisabledTrackers == false then 
      isIgnored = true 
    end

    if not isIgnored then 
      yield(trackerID, tracker)
    end
  end
end

--- Get the tracker 
---
--- @param id the tracker id to return
__Static__() function API.GetTracker(id)
  return TRACKERS[id]
end

--- Create an observable will read a setting value of tracker. 
--- It can be used by the style system. 
---
--- @param setting the setting where the value will be fetched. 
--- @param default the default value in case the value is not found.
__Arguments__ { String, Any/nil }
__Static__() function API.FromTrackerSetting(setting, default)
  local observable = Observable(function(observer)
    -- The current frame may not be a tracker, so we need to try to get 
    -- the nearest tracker object.
    local tracker = GetNearestFrameForType(GetCurrentTarget(), Tracker)

    if tracker then 
      local subject, isNew = tracker:AcquireSettingSubject(setting)

      if isNew then 
        subject:Subscribe(observer)
      end

      local value
    
      -- The id may be nil, so we need to check it.
      if tracker.id and tracker.id ~= "" then
        value = SavedVariables.Profile().Path("trackers", tracker.id).GetValue(setting)
      end

      subject:OnNext(value, tracker)
    end
  end)

  if default ~= nil then 
    return observable:Map(function(v) return v or default end)
  end

  return observable
end

--- Get the setting value for a tracker given 
---
--- @param trackerOrID the tracker object or the tracker id where fetching the setting. 
--- @param setting the setting to get. 
__Arguments__ { Tracker + String, String }
__Static__() function API.GetTrackerSetting(trackerOrID, setting)
  local id = type(trackerOrID) == "string" and trackerOrID or trackerOrID.id 

  if id and id ~= "" then 
    return SavedVariables.Profile().Path("trackers", id).GetValue(setting)
  end
end

--- Set the setting value for a tracker given 
---
--- @param trackerOrID the tracker object or the tracker id where it will be set. 
--- @param setting the setting to set 
--- @param value setting value to set. 
--- @param notify if the observers should be notified. 
__Arguments__ { Tracker + String, String, Any/nil, Boolean/true }
__Static__() function API.SetTrackerSetting(trackerOrID, setting, value, notify)

  -- local tracker = type(trackerOrID) == "string" and TRACKERS[trackerOrID] or trackerOrID

  local tracker 
  if type(trackerOrID) == "string" then 
    tracker = TRACKERS[trackerOrID]
  else
    tracker = trackerOrID
  end

  if not tracker then
    return 
  end


  if value ~= nil then 
    SavedVariables.Profile().Path("trackers", tracker.id).SaveValue(setting, value)
  else
    -- We prefer to use SetValue for nil value, as this useless to create the path
    -- if we want to clear the value. 
    SavedVariables.Profile().Path("trackers", tracker.id).SetValue(setting, value)
  end

  if notify then 
    -- We don't want to create a subject if the setting don't have one because this 
    -- say none is interested to be notified by this setting.
    local subject = tracker:AcquireSettingSubject(setting, false)
    if subject then 
      subject:OnNext(value, tracker)
    end
  end
end

__UIElement__()
__ChildProperty__(Tracker, "Mover")
class "TrackerMover" (function(_ENV)
  inherit "Mover"
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Text = FontString
  }
  function __ctor() end 
end)


-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TrackerMover] = {
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
    },

    backdropColor = { r = 0, g = 1, b = 0, a = 0.3},
    location = NIL,
    Text = {
      text = "Click here to move the tracker",
      setAllPoints = true,
      mediaFont = FontType("PT Sans Narrow Bold", 13)
    }
  },

  [Tracker] = {
    size = API.FromTrackerSetting("size", Size(300, 325)),
    location = API.FromTrackerSetting("position"):Map(function(pos, tracker)
      if pos then
        return  { Anchor("TOPLEFT", pos.x or 0, pos.y or 0, nil, "BOTTOMLEFT") }
      end
      
      return tracker.id == "main" and { Anchor("RIGHT", -40, 0) } or { Anchor("CENTER") }
    end),
    resizable = true,
    movable  = true,

    ScrollFrame = {
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMRIGHT")
      }
    },

    ScrollBar = {
      -- width = 6,
      -- location = {
      --   Anchor("TOPLEFT", 3, 20, nil, "TOPRIGHT"),
      --   Anchor("BOTTOMLEFT", 3, -20, nil, "BOTTOMRIGHT")
      -- }
      size = Size(6, 244),
      location = {
        Anchor("LEFT", 15, 0, nil, "RIGHT")
      }
    },
    
    -- BackgroundTexture = {
    --   visible = true,
    --   file = "Interface\\Buttons\\WHITE8X8",
    --   drawLayer = "BACKGROUND",
    --   vertexColor = Color.BLACK,
    --   setAllPoints = true,
    -- },


    [TrackerMover] = {
      location = {
        Anchor("BOTTOMLEFT", 0, 0, nil, "TOPLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, nil, "TOPRIGHT")
      },
    }
  }
})
-------------------------------------------------------------------------------
--                                Module                                     --
-------------------------------------------------------------------------------
function OnEnable(self)
  -- Create the main tracker 
  _MainTracker = private__NewTracker("main")
  Style[_MainTracker].Locked = false
end

__SystemEvent__()
__Async__() function PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUI)
  if isInitialLogin or isReloadingUI then 
    local trackerBottom = _MainTracker:GetBottom()
    -- Important ! We have to delay the tracking of content type after an
    -- initial and a reloading ui for they getting a valid "GetBottom" is
    -- important to compute the height of their frame.
    -- So we delay util the tracker "GetBottom" return a no nil value, saying 
    -- GetBottom now return valid value
    while not trackerBottom do 
      trackerBottom = _MainTracker:GetBottom()
      Next()
    end
    
    -- _MainTracker:TrackContent("scenario")
    _MainTracker:TrackContent("dungeon")
    -- _MainTracker:TrackContent("keystone")
    -- _MainTracker:TrackContent("torghast")
    _MainTracker:TrackContent("worldQuests")
    -- _MainTracker:TrackContent("tasks")
    -- _MainTracker:TrackContent("bonusTasks")
    _MainTracker:TrackContent("achievements")
    _MainTracker:TrackContent("activities")
    -- _MainTracker:TrackContent("professionRecipes")
    _MainTracker:TrackContent("dungeonQuests")
    _MainTracker:TrackContent("campaignQuests")
    _MainTracker:TrackContent("quests")
  end
end