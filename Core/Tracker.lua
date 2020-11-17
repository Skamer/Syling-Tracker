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
namespace                          "SLT"
-- ========================================================================= --
local DEFAULT_SCROLL_STEP = 15

local function OnMinMaxValueSet(self)
    local height    = self:GetHeight()

    if not height then return end
 
    local min, max  = self:GetMinMaxValues()
    local value     = self:GetValue()
 
    local width     = self:GetPropertyChild("ThumbTexture"):GetWidth()
 
    Style[self].thumbTexture.size = Size(width, math.max(24, height - (max - min)))
end
-- ========================================================================= --
UI.Property         {
    name            = "ThumbAutoHeight",
    type            = Boolean,
    require         = { Slider },
    default         = false,
    set             = function(self, auto)
        if auto then
            if not _M:GetSecureHookHandler(self, "SetMinMaxValues") then
                _M:SecureHook(self, "SetMinMaxValues", OnMinMaxValueSet)
            end
        else
            if _M:GetSecureHookHandler(self, "SetMinMaxValues") then
                _M:SecureUnHook(self, "SetMinMaxValues")
            end
        end
    end,
}
-- ========================================================================= --
class "Tracker"(function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnScrollRangeChanged(self, xrange, yrange)
    --if self.NoAutoAdjustScrollRange then return end
    local scrollFrame = self:GetChild("ScrollFrame")
    local scrollBar   = self:GetChild("ScrollBar")

    yrange                  = math.floor(yrange or scrollFrame:GetVerticalScrollRange())

    scrollBar:InstantApplyStyle()
    scrollBar:SetMinMaxValues(0, yrange)
    scrollBar:SetValue(math.min(scrollBar:GetValue(), yrange))
  end

  local function OnVerticalScroll(self, offset)
    self:GetChild("ScrollBar"):SetValue(offset)
  end
  
  local function OnMouseWheel(self, value)
    self:GetChild("ScrollBar"):OnMouseWheel(value)
  end 

  -- NOTE: Required
  function SetVerticalScroll(self, value)
    self:GetChild("ScrollFrame"):UpdateScrollChildRect()
    self:GetChild("ScrollFrame"):SetVerticalScroll(value)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String + Number }
  function TrackContentType(self, contentID)
    Scorpio.FireSystemEvent("SLT_TRACKER_TRACK_CONTENT_TYPE", self, contentID)
  end
  
  __Arguments__ { String + Number }
  function UntrackContentType(self, contentID)
    Scorpio.FireSystemEvent("SLT_TRACKER_UNTRACK_CONTENT_TYPE", self, contentID)
  end

  __Arguments__ { IView }
  function AddView(self, view)
    self.Views:Insert(view)
    view:SetParent(self:GetChild("ScrollFrame"):GetChild("Content"))

    -- Register the events
    view.OnSizeChanged = view.OnSizeChanged + self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged + self.OnViewOrderChanged
    view.OnShouldBeDisplayedChanged = view.OnShouldBeDisplayedChanged + self.OnViewShouldBeDisplayedChanged

    self:OnLayout()
    self:OnAdjustHeight()
  end

  __Arguments__ { IView }
  function RemoveView(self, view)
    self.Views:Remove(view)

    -- Unregister the events
    view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged - self.OnViewOrderChanged
    view.OnShouldBeDisplayedChanged = view.OnShouldBeDisplayedChanged - self.OnViewShouldBeDisplayedChanged

    -- We call an instant layout and adjust height for avoiding a
    -- flashy behavior when the content has been removed. 
    self:OnLayout()
    self:OnAdjustHeight()

    -- NOTE: We don't call the "Release" method of view because it will be done by
    -- the content type.
  end


  __Arguments__ { IView }
  function DisplayView(self, view)
    view:OnAcquire()
    view:SetParent(self:GetChild("ScrollFrame"):GetChild("Content"))
    
    self:OnLayout()
    self:OnAdjustHeight()
  end

  __Arguments__ { IView }
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
    local content = self:GetChild("ScrollFrame"):GetChild("Content")
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
    local content = self:GetChild("ScrollFrame"):GetChild("Content")
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
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Views" {
    default = function() return Array[IView]() end
  }

  property "Spacing" {
    type = Number,
    default = 10
  }

  property "ID" {
    type = Number + String
  }

  property "ContentHeight" {
    type = Number,
    default = 1,
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    ScrollFrame = ScrollFrame,
    ScrollBar = UIPanelScrollBar,
    Resizer = Resizer,
    {
      ScrollFrame = {
        Content = Frame,
        FixBottom = Frame
      }
    }
  }
  function __ctor(self)

    local scrollFrame = self:GetChild("ScrollFrame")
    scrollFrame:SetClipsChildren(true)
    
    scrollFrame.OnScrollRangeChanged = scrollFrame.OnScrollRangeChanged + function(_, xrange, yrange)
      OnScrollRangeChanged(self, xrange, yrange)
    end

    scrollFrame.OnVerticalScroll = scrollFrame.OnVerticalScroll + function(_, offset)
      OnVerticalScroll(self, offset)
    end
    
    scrollFrame.OnMouseWheel = scrollFrame.OnMouseWheel + function(_, value)
      OnMouseWheel(self, value)
    end

    scrollFrame:InstantApplyStyle()

    local content = scrollFrame:GetChild("Content")
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
  end 
end)

class "TrackerMover" (function(_ENV)
  inherit "Mover"

  __Template__{
    Text = SLTFontString
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

  [Tracker] = {
    size = Size(300, 325), -- 300 325
    resizable = true,
    movable = true,

    -- [ScrollFrame] child properties 
    ScrollFrame = {
      -- SetAllPoints = true,
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      },

      backdrop = {
            bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
            -- edgeFile = [[Interface\Buttons\WHITE8X8]],
            -- edgeSize = 1
        },
        backdropColor = { r = 0, g = 0, b = 1, a = 0},

      Content = {
        backdrop = {
            bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
            -- edgeFile = [[Interface\Buttons\WHITE8X8]],
            -- edgeSize = 1
        },
        backdropColor = { r = 1, g = 0, b = 0, a = 0}
      },

      FixBottom = {
        height = 1,
        location = {
          Anchor("BOTTOM"),
          Anchor("BOTTOMLEFT"),
          Anchor("BOTTOMRIGHT")
        }
      }
    },

    -- [ScrollBar] child properties
    ScrollBar = {
      thumbAutoHeight = true,
      scrollStep = DEFAULT_SCROLL_STEP,
      autoHide = true,
      backdropColor = ColorType(0, 0, 0, 0.3),
      width = 6,
      height = 244,
      backdrop = { bgFile = [[Interface\Buttons\WHITE8X8]] },
      location = { Anchor("LEFT", 15, 0, nil, "RIGHT") },
      thumbTexture = {
        file = [[Interface\Buttons\WHITE8X8]],
        vertexColor = ColorType(1, 199/255, 0, 0.75),
        size = Size(4, 198)
        --size = Size(4, 214),
      },

      -- ScrollBar.ScrollUpButton
      ScrollUpButton = {
        visible = false 
      },

      -- ScrollBar.ScrollDownButton
      ScrollDownButton = {
        visible = false
      }
    }
  }
})


function OnEnable(self)
  _DB_READ_ONLY = true

  _Tracker = Tracker("SylingTracker_MainTracker", UIParent)
  _Tracker.ID = "main"

  _TrackerMover = TrackerMover("MainTracker_Mover", _Tracker)
  _TrackerMover.MoveTarget = _Tracker

  Profiles.PrepareDatabase()
  local width, height, xPos, yPos, locked, hidden, scrollStep
  if Database.SelectTable(false, "trackers", _Tracker.ID) then 
    xPos        = Database.GetValue("xPos")
    yPos        = Database.GetValue("yPos")
    width       = Database.GetValue("width")  or 300
    height      = Database.GetValue("height") or 325
    locked      = Database.GetValue("locked")
    hidden      = Database.GetValue("hidden")
    scrollStep  = Database.GetValue("scrollStep")
  end

  if not xPos and not yPos then 
    _Tracker:SetPoint("RIGHT", -40, 0)
  else 
    _Tracker:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPos or 0, yPos or 0)
  end
  
  Style[_Tracker].width   = width
  Style[_Tracker].height  = height

  if scrollStep then 
    SetScrollStepMainTracker(scrollStep)
  end 

  if locked then 
    LockMainTracker()
  else
    UnlockMainTracker()
  end

  if hidden then 
    HideMainTracker()
  end
  
  _Tracker.OnSizeChanged = function(tracker, width, height)
    if _DB_READ_ONLY then 
      return 
    end

    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "trackers", tracker.ID) then 
      Database.SetValue("width", Round(width))
      Database.SetValue("height", Round(height))
    end 
  end

  _TrackerMover.OnStopMoving = function(mover, ...)
    if _DB_READ_ONLY then 
      return
    end

    local tracker = mover.MoveTarget
    local top     = tracker:GetTop()
    local left    = tracker:GetLeft()

    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "trackers", tracker.ID) then 
      Database.SetValue("xPos", left)
      Database.SetValue("yPos", top)
    end
  end


  _DB_READ_ONLY = false
end

__SystemEvent__ "SLT_LOCK_COMMAND"
function LockMainTracker()
  _TrackerMover:Hide()

  Style[_Tracker].resizable = false
  Style[_Tracker].movable = false 

  if not _DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "trackers", _Tracker.ID) then 
      Database.SetValue("locked", true)
    end
  end 
end

__SystemEvent__ "SLT_UNLOCK_COMMAND"
function UnlockMainTracker()
  _TrackerMover:Show()

  Style[_Tracker].resizable = true 
  Style[_Tracker].movable = true

  if not _DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "trackers", _Tracker.ID) then 
      Database.SetValue("locked", false)
    end
  end
end

__SystemEvent__ "SLT_SHOW_COMMAND"
function ShowMainTracker()
  _Tracker:Show()

  if not _DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "trackers", _Tracker.ID) then 
      Database.SetValue("hidden", false)
    end
  end
end

__SystemEvent__ "SLT_HIDE_COMMAND"
function HideMainTracker()
  _Tracker:Hide()

  if not _DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "trackers", _Tracker.ID) then 
      Database.SetValue("hidden", true)
    end
  end
end

__SystemEvent__ "SLT_TOGGLE_COMMAND"
function ToggleMainTracker()
  if _Tracker:IsShown() then
    HideMainTracker()
  else
    ShowMainTracker()
  end
end

__SystemEvent__ "SLT_SCROLL_STEP_COMMAND"
function SetScrollStepMainTracker(scrollStep)
  Style[_Tracker].ScrollBar.scrollStep = scrollStep

  if not _DB_READ_ONLY then
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "trackers", _Tracker.ID) then
      -- remove from db if it's the value by default
      if scrollStep == DEFAULT_SCROLL_STEP then 
        scrollStep = nil 
      end
      Database.SetValue("scrollStep", scrollStep)
    end
  end
end

__SystemEvent__()
__Async__()
function PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
  if isInitialLogin or isReloadingUi then
    local trackerBottom = _Tracker:GetBottom()
    -- Important ! We have to delay the tracking of content type after an 
    -- initial and a reloading ui for they getting a valid "GetBottom" is important
    -- to compute the height of their frame. 
    -- So we delay until the tracker "GetBottom" returns a no nil value, saying GetBottom
    -- now return valid value. 
    while not trackerBottom do 
      trackerBottom = _Tracker:GetBottom()
      Next()
    end 

    _Tracker:TrackContentType("scenario")
    _Tracker:TrackContentType("dungeon")
    _Tracker:TrackContentType("achievements")
    _Tracker:TrackContentType("bonus-tasks")
    _Tracker:TrackContentType("tasks")
    _Tracker:TrackContentType("quests")
    _Tracker:TrackContentType("campaign")
    _Tracker:TrackContentType("auto-quests")
    _Tracker:TrackContentType("world-quests")
    _Tracker:TrackContentType("keystone")
    _Tracker:TrackContentType("torghast")
  end 
end

__SystemEvent__()
function SLT_TRACK_CONTENT_TYPE(contentID)
  _Tracker:TrackContentType(contentID)
end

__SystemEvent__() 
function SLT_UNTRACK_CONTENT_TYPE(contentID)
  _Tracker:UntrackContentType(contentID)
end

