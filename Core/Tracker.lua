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
  GetNearestFrameForType  = Utils.GetNearestFrameForType,
  FromUIProperty          = Wow.FromUIProperty,

  IsInInstance          = IsInInstance,
  GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo,
  SecureCmdOptionParse  = SecureCmdOptionParse
}

__UIElement__()
class "TrackerMinimizeButton" (function(_ENV)
  inherit "Button"

  __Observable__()
  property "Minimized" {
    type = Boolean,
    default = false
  }

  __Observable__()
  property "Enabled" {
    type = Boolean,
    default = true
  }
end)

struct "VisibilityRulesType" {
  { name = "defaultVisibility",               type = String,  default = "show"},
  { name = "hideWhenEmpty",                   type = Boolean, default = true },
  { name = "enableAdvancedRules",             type = Boolean, default = false},
  { name = "inDungeonVisibility",             type = String,  default = "show"},
  { name = "inKeystoneVisibility",            type = String,  default = "show"},
  { name = "inRaidVisibility",                type = String,  default = "show"},
  { name = "inScenarioVisibility",            type = String,  default = "show"},
  { name = "inArenaVisibility",               type = String,  default = "show"},
  { name = "inBattlegroundVisibility",        type = String,  default = "show"},
  { name = "inPartyVisibility",               type = String,  default = "show"},
  { name = "inRaidGroupVisibility",           type = String,  default = "show"},
  { name = "macroVisibility",                 type = String;  default = "" },
  { name = "evaluateMacroVisibilityAtFirst",  type = Boolean, default = false}
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
    self:AdjustHeight()

    self.Empty = self.Views.Count == 0
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
    self:AdjustHeight()

    -- NOTE: We don't call the "Release" method of view because it will be done 
    -- by the content type

    self.Empty = self.Views.Count == 0
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

    self.ContentsTracked[contentID] = true
  end

  __Arguments__ { String }
  function UntrackContent(self, contentID)
    Scorpio.FireSystemEvent("SylingTracker_UNTRACK_CONTENT", self, contentID)

    self.ContentsTracked[contentID] = false
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
  
  function GetMinimizeButton(self)
    return self.__minimizeButton or self:GetChild("MinimizeButton")
  end

  function OnRelease(self)
    for contentID, tracked in pairs(self.ContentsTracked) do 
      if tracked then
        self:UntrackContent(contentID)
      end
    end

    wipe(self.ContentsTracked)

    self.id = nil 
    self.Enabled = nil 
    self.Locked = nil 
    self.Minimized = nil 
    self.ShowScrollBar = nil

    self:GetMinimizeButton().Enabled = false

    self:GetScrollFrame():SetVerticalScroll(0)
    self:GetScrollBar():SetScrollPercentage(0)
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

  property "Empty" {
    type = Boolean,
    default = true
  }

  __Observable__()
  property "Minimized" {
    type      = Boolean,
    default   = false
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

  property "VisibilityRules" {
    set = false,
    type = VisibilityRulesType,
    default = function() return VisibilityRulesType() end
  }

  __Observable__()
  property "VisibilityRulesShown" {
    type = Boolean,
    default = true
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    ScrollFrame = ScrollFrame,
    ScrollBar = ScrollBar,
    Resizer = Resizer,
    MinimizeButton = TrackerMinimizeButton,
    {
      ScrollFrame = {
        Content = Frame
      },
    }
  }    
  function __ctor(self)
    local scrollFrame =self:GetScrollFrame()
    -- scrollFrame:SetClipsChildren(true)

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

    local minimizeButton = self:GetMinimizeButton()
    minimizeButton.OnClick = minimizeButton.OnClick + function()
      local minimized = not self.Minimized
      if minimized then 
        minimizeButton:SetParent(UIParent)
        self.__minimizeButton = minimizeButton
      else
        minimizeButton:SetParent(self)
        self.__minimizeButton = nil
      end

      minimizeButton.Minimized = minimized

      self.Minimized = minimized
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
TRACKER_SETTINGS  = {}

local function OnTrackerStopMoving(tracker)
  local left = tracker:GetLeft()
  local top = tracker:GetTop()


  SetTrackerSetting(tracker.id, "position", Position(left, top), false)
end

local function OnTrackerStopResizing(tracker)
  local width   = Round(tracker:GetWidth())
  local height  = Round(tracker:GetHeight())

  SetTrackerSetting(tracker.id, "size", Size(width, height), false)
end

__Arguments__ { String }
function private__NewTracker(id)
  local tracker = Tracker.Acquire()
  tracker.id = id
  tracker:SetParent(UIParent)
  tracker:Show()

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

  DebugTools.TrackData(tracker, tracker.id)

  return tracker
end

--- Create an tracker. 
--- 
--- @param id the tracker id to register (note: the id 'main' is reserved)
__Arguments__ { String }
function NewTracker(id)
  -- the 'main' id is reserved for the main tracker. 
  if id == "main" then 
    return 
  end

  local tracker = private__NewTracker(id)

  -- Don't forget to add in the tracker list else it won't be persisted for 
  -- the next time.
  SavedVariables.Path("list", "trackers").SaveValue(id, true)
  
  -- Trigger a system event for notifying the outside
  Scorpio.FireSystemEvent("SylingTracker_TRACKER_CREATED", id)

  return tracker
end

__Arguments__ { String }
function private__DeleteTracker(trackerID)
  local tracker = TRACKERS[trackerID]
  if not tracker then 
    return 
  end

  -- Remove handlers 
  tracker.OnStopResizing      = tracker.OnStopResizing - OnTrackerStopResizing
  tracker.OnStopMoving        = tracker.OnStopMoving - OnTrackerStopMoving

  TRACKERS[trackerID] = nil 

  tracker:Release()
end

--- Delete a tracker
--- note: the main tracker cannot be deleted.
---
--- @param trackerID the id of tracker to delete
__Arguments__ { String }
function DeleteTracker(trackerID)
  if trackerID == "main" then 
    return 
  end
  
  private__DeleteTracker(trackerID)
  
  -- Remove the tracker from the list 
  SavedVariables.Path("list", "trackers").SetValue(trackerID, nil)

  -- Remove the tracker setting for global and all profiles 
  SavedVariables.Path("trackers").All().SetValue(trackerID, nil)

  Scorpio.FireSystemEvent("SylingTracker_TRACKER_DELETED", trackerID)
end

--- Return an iterafor for the trackers 
--- 
--- @param includeMainTracker if the main tracker should be included
--- @param includeDisabledTrackers if the disabled trackers soulld be included
__Iterator__()
__Arguments__ { Boolean/true, Boolean/true }
function IterateTrackers(includeMainTracker, includeDisabledTrackers)
  local yield = coroutine.yield
  local trackersList =  SavedVariables.Profile().Path("list").GetValue("trackers")
  local trackersSettings = SavedVariables.Profile().GetValue("trackers")
  
  if includeMainTracker then
    local settings = trackersSettings["main"] 
    local enabled = settings and setting.enabled 
    local ignored = false 

    if not includeDisabledTrackers and enabled ~= nil and enabled == false then 
      ignored = true 
    end

    if not ignored then 
      yield("main")
    end
  end

  if trackersList then 
    for trackerID in pairs(trackersList) do 
      local settings = trackersSettings[trackerID]
      local enabled = settings and settings.enabled
      local ignored = false
      if not includeDisabledTrackers and enabled ~= nil and enabled == false then 
        ignored = true 
      end

      if not ignored then 
        yield(trackerID)
      end
    end
  end
end

--- Get the tracker 
---
--- @param id the tracker id to return
__Arguments__ { String }
function GetTracker(id)
  return TRACKERS[id]
end

struct "TrackerSettingInfoType" {
 { name = "id", type = String, require = true },
 { name = "default", type = Any},
 { name = "handler", type = Function },
 { name = "saveHandler", type = Function},
 { name = "ignoreDefault", type = Boolean, default = false},
 { name = "getHandler", type = Function},
 { name = "defaultHandler", type = Function},
 { name = "structType", type = StructType },
}

--- Register a setting for a tracker
---
--- @param settingInfo the setting info to register.
__Arguments__ { TrackerSettingInfoType}
function RegisterTrackerSetting(settingInfo)
  if TRACKER_SETTINGS[settingInfo.id] then 
    return 
  end

  TRACKER_SETTINGS[settingInfo.id] = settingInfo
end

--- Create an obsersable will read a setting value of tracker.
--- it can be used by the style system.
---
--- @param setting the setting where the value will be fetched.
--- @param ... extra args will be pushed to get handler.
__AutoCache__()
__Arguments__ { String, Any * 0 }
function FromTrackerSetting(setting, ...)
  local extraArgs = { ... }
  return Observable(function(observer)
    -- The current frame may not be a tracker, so we need to try to get 
    -- the nearest tracker object.
    local tracker = GetNearestFrameForType(GetCurrentTarget(), Tracker)    
    if tracker then 
      local trackerID       = tracker.id
      local subject, isNew  = tracker:AcquireSettingSubject(setting)
      
      -- if isNew then
      --   subject:Subscribe(observer)
      -- end

      if isNew then 
        local value
        
        -- The id may be nil, so we need to check it.
        if trackerID and trackerID ~= "" then 
          value = GetTrackerSettingWithDefault(trackerID, setting, unpack(extraArgs))
        else
          value = TRACKER_SETTINGS[setting] and TRACKER_SETTINGS[setting].default
        end

        subject:OnNext(value, tracker)
      end
      
      subject:Subscribe(observer)
    end
  end)
end

--- Get the setting value for a tracker 
---
--- @param the tracker id where fetching the setting.
--- @param setting the setting to get.
--- @param ... extra args will be passed to get handler.
__Arguments__ { String, String, Any * 0 }
function GetTrackerSetting(trackerID, setting, ...)
  local hasDefaultValue = false 
  local defaultValue 
  local dbValue 
  local getHandler

  local settingInfo = TRACKER_SETTINGS[setting]
  if settingInfo then 
    defaultHandler  = settingInfo.defaultHandler
    structType      = settingInfo.structType
    getHandler      = settingInfo.getHandler
    hasDefaultValue = not settingInfo.ignoreDefault

    if defaultHandler then 
      defaultValue = defaultHandler(trackerID, ...)
    elseif structType then
      local subSetting = ...
      local structMember = Struct.GetMember(structType, subSetting)
      defaultValue = structMember and structMember:GetDefault()
    else
      defaultValue = settingInfo.default
    end
  end 

  if trackerID and trackerID ~= "" then 
    if getHandler then
      dbValue = getHandler(trackerID, ...)
    elseif structType then 
      local subSetting = ...
      if subSetting then
        dbValue = SavedVariables.Profile().Path("trackers", trackerID, setting).GetValue(subSetting)
      else 
        dbValue = SavedVariables.Profile().Path("trackers", trackerID).GetValue(setting)
      end
    else
      dbValue = SavedVariables.Profile().Path("trackers", trackerID).GetValue(setting)
    end

    return dbValue, hasDefaultValue, defaultValue
  end
end

--- This is a helper function around GetTrackerSetting
--- Get the setting value for a tracker, and replace by the default value if there is one.
---
--- @param the tracker id where fetching the setting.
--- @param setting the setting to get.
--- @param ... extra args will be passed to get handler.
__Arguments__ { String, String, Any * 0 }
function GetTrackerSettingWithDefault(trackerOrID, setting, ...)
  local dbValue, hasDefaultValue, defaultValue = GetTrackerSetting(trackerOrID, setting, ...)

  if dbValue == nil and hasDefaultValue then 
    return defaultValue
  end

  return dbValue 
end

--- Set the setting value for a tracker
---
--- @param trackerID the tracker id where the setting will be set
--- @param setting the setting to set 
--- @param value the setting value to set 
--- @param notify if the observers and setting handler should be notified.
--- @param ... extra arguments will be passed to different handlers.
__Arguments__ { String, String, Any/nil, Boolean/true, Any * 0 }
function SetTrackerSetting(trackerID, setting, value, notify, ...)
  local default = nil 
  local ignoreDefault = false 
  local handler = nil 
  local saveHandler = nil
  local structType = nil 

  local settingInfo = TRACKER_SETTINGS[setting]
  if settingInfo then 
    ignoreDefault   = settingInfo.ignoreDefault
    defaultHandler  = settingInfo.defaultHandler
    handler         = settingInfo.handler
    saveHandler     = settingInfo.saveHandler
    structType      = settingInfo.structType
  
    
    if defaultHandler then 
      default = defaultHandler(trackerID, ...)
    elseif structType then
      local subSetting = ...
      local structMember = Struct.GetMember(structType, subSetting)
      default = structMember and structMember:GetDefault()
    else
      default = settingInfo.default
    end
  end

  if value == nil or value == default then
    if saveHandler then 
      saveHandler(trackerID, nil, ...)
    elseif structType then 
      local subSetting = ...
      if subSetting then 
        SavedVariables.Profile().Path("trackers", trackerID, setting).SetValue(subSetting, nil)
      end
    else
      SavedVariables.Profile().Path("trackers", trackerID).SetValue(setting, nil)
    end
  else
    if saveHandler then 
      saveHandler(trackerID, value, ...)
    elseif structType then
      local subSetting = ...
      if subSetting then 
        SavedVariables.Profile().Path("trackers", trackerID, setting).SaveValue(subSetting, value)
      end
    else
      SavedVariables.Profile().Path("trackers", trackerID).SaveValue(setting, value)
    end
  end
  
  if value == nil and not ignoreDefault then 
    value = default
  end
  
  if notify then
    if handler then 
      handler(trackerID, value, ...)
    end
    
    local tracker = TRACKERS[trackerID]
    if tracker then 
      -- We don't want to create a subject if the setting don't have one because this 
      -- say none is interested to be notified by this setting.
      local subject = tracker:AcquireSettingSubject(setting, false)
      if subject then
        subject:OnNext(value, tracker, ...)
      end
    end
  end
end

__Arguments__ { String , Boolean/nil }
function private__IsContentShouldTracked(trackerID, contentTracked)
  local tracked, isDefault
  if trackerID == "main" then 
    if contentTracked or contentTracked == nil then
      tracked = true 
      isDefault = true 
    else
      tracked = false 
      isDefault = false 
    end
  else
    if contentTracked then
      tracked = true 
      isDefault = false 
    else
      tracked = false 
      isDefault = true 
    end
  end

  return tracked, isDefault
end

__Arguments__ { Tracker }
__Async__() function LoadTracker(tracker)
  local trackerBottom = tracker:GetBottom()
  -- Important ! We have to delay a little until the tracker returning a valid 
  -- "GetBottom". This indicate all is ready for elements are able to compute
  -- their height.
  while not trackerBottom do
    trackerBottom = tracker:GetBottom()
    Next()
  end

  tracker:GetMinimizeButton().Enabled = true

  private__LoadContentsForTracker(tracker)
  LoadVisibilityRulesForTracker(tracker)
end

__Arguments__ { String/nil, String/nil }
function private__GetContentTracked(trackerID, contentID)
    local tracked = SavedVariables.Profile()
      .Path("trackers", trackerID, "contents", contentID)
      .GetValue("tracked")

    return private__IsContentShouldTracked(trackerID, tracked)
end

--- Reserved only during the loading when the trackers are created.
__Arguments__ { Tracker }
function private__LoadContentsForTracker(tracker)
  for _, content in API.IterateContents() do
    local contentID = content.id 
    local tracked = private__GetContentTracked(tracker.id, contentID)
    if tracked then 
      tracker:TrackContent(contentID)
    end
  end
end

__Arguments__ { String, Boolean/true }
function private__SetEnabledTracker(trackerID, enabled)
  if enabled and TRACKERS[trackerID] then 
    return 
  end

  if enabled then
    local tracker = private__NewTracker(trackerID)
    LoadTracker(tracker)
  else
    private__DeleteTracker(trackerID)
  end
end

TRACKERS_AUTO_VISIBILITY_REGISTERED       = List()
AUTO_VISIBILITY_EVENTS_HANDLER_REGISTERED = false
AUTO_VISIBILITY_EVENTS                    = {
  "MODIFIER_STATE_CHANGED", "ACTIONBAR_PAGE_CHANGED", "UPDATE_BONUS_ACTIONBAR",
  "PLAYER_ENTERING_WORLD", "UPDATE_SHAPESHIFT_FORM", "UPDATE_STEALTH", "PLAYER_TARGET_CHANGED",
  "PLAYER_FOCUS_CHANGED", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_PET", 
  "GROUP_ROSTER_UPDATE", "CHALLENGE_MODE_START"
}
TRACKERS_MACRO_TICKER_REGISTERED          = List() 
MACRO_TICKER_ENABLED                      = false


__Async__() function VISIBILITY_MACRO_TICKER()
  if not MACRO_TICKER_ENABLED then 
    return 
  end

  while MACRO_TICKER_ENABLED do 
    for _, tracker in TRACKERS_MACRO_TICKER_REGISTERED:GetIterator() do
      tracker.VisibilityRulesShown = GetRulesVisibilityShownForTracker(tracker)
    end

    Delay(0.2)
  end
end

__Arguments__ { Tracker }
function RegisterTrackerForMacroTicker(tracker)
  if TRACKERS_MACRO_TICKER_REGISTERED:Contains(tracker) then 
    return 
  end

  TRACKERS_MACRO_TICKER_REGISTERED:Insert(tracker)
  
  if TRACKERS_MACRO_TICKER_REGISTERED.Count > 0 and not MACRO_TICKER_ENABLED then 
    MACRO_TICKER_ENABLED = true 
    VISIBILITY_MACRO_TICKER()
  end
end

__Arguments__ { Tracker }
function UnregisterTrackerForMacroTicker(tracker)
  if not TRACKERS_MACRO_TICKER_REGISTERED:Contains(tracker) then 
    return 
  end
  
  TRACKERS_MACRO_TICKER_REGISTERED:Remove(tracker)
  
  if TRACKERS_MACRO_TICKER_REGISTERED.Count == 0 and MACRO_TICKER_ENABLED then 
    MACRO_TICKER_ENABLED = false 
  end
end

function UPDATE_VISIBILITY_ON_EVENTS()
  for _, tracker in TRACKERS_AUTO_VISIBILITY_REGISTERED:GetIterator() do
    tracker.VisibilityRulesShown = GetRulesVisibilityShownForTracker(tracker)
  end
end

__Arguments__ { Tracker}
function RegisterTrackerForAutoVisibility(tracker)
  if TRACKERS_AUTO_VISIBILITY_REGISTERED:Contains(tracker) then 
    return 
  end

  TRACKERS_AUTO_VISIBILITY_REGISTERED:Insert(tracker)

  if not AUTO_VISIBILITY_EVENTS_HANDLER_REGISTERED then 
    for _, event in ipairs(AUTO_VISIBILITY_EVENTS) do
      _M:RegisterEvent(event, UPDATE_VISIBILITY_ON_EVENTS)
    end

    AUTO_VISIBILITY_EVENTS_HANDLER_REGISTERED = true
  end

  if tracker.VisibilityRules.macroVisibility ~= "" then 
    RegisterTrackerForMacroTicker(tracker)
  end
end

__Arguments__ { Tracker }
function UnregisterTrackerForAutoVisibility(tracker)
  if not TRACKERS_AUTO_VISIBILITY_REGISTERED:Contains(tracker) then 
    return 
  end
  
  TRACKERS_AUTO_VISIBILITY_REGISTERED:Remove(tracker)

  if TRACKERS_AUTO_VISIBILITY_REGISTERED.Count == 0 then 
    for _, event in ipairs(AUTO_VISIBILITY_EVENTS) do
      _M:UnregisterEvent(event)
    end

    AUTO_VISIBILITY_EVENTS_HANDLER_REGISTERED = false
  end

  if tracker.VisibilityRules.macroVisibility ~= "" then 
    UnregisterTrackerForMacroTicker(tracker)
  end
end

__Arguments__ { Tracker }
function LoadVisibilityRulesForTracker(tracker)
  local rules = GetTrackerSetting(tracker.id, "visibilityRules")
  local trackerVisibilityRules = tracker.VisibilityRules

  for _, prop in Struct.GetMembers(VisibilityRulesType) do
    local propName = prop:GetName()
    trackerVisibilityRules[propName] = rules and rules[propName] or prop:GetDefault()
  end

  tracker.HideWhenEmpty = trackerVisibilityRules.hideWhenEmpty
  tracker.DefaultVisibility = trackerVisibilityRules.defaultVisibility
  
  if trackerVisibilityRules.enableAdvancedRules then
    RegisterTrackerForAutoVisibility(tracker)
  end

  tracker.VisibilityRulesShown = GetRulesVisibilityShownForTracker(tracker)
end

function UpdateTrackersVisibility()
  for _, tracker in TRACKERS_AUTO_VISIBILITY_REGISTERED:GetIterator() do
    tracker.VisibilityRulesShown = GetRulesVisibilityShownForTracker(tracker)
  end
end

__Arguments__ { Tracker }
function GetRulesVisibilityShownForTracker(tracker)
  local rules = tracker.VisibilityRules

  if tracker.Empty and rules.hideWhenEmpty then
    return false 
  end

  if rules.enableAdvancedRules then 
    local result = EvaluateVisibilityAdvancedRules(rules)
    if result == "show" then 
      return true 
    elseif result == "hide" then 
      return false 
    end
  end

  if rules.defaultVisibility == "hide" then 
    return false 
  end

  return true
end

__Arguments__ { VisibilityRulesType }
function EvaluateVisibilityAdvancedRules(rules)
  local trackerVisibility

  if not rules then 
    return trackerVisibility
  end

  local macroText = rules.macroVisibility
  
  if rules.evaluateMacroVisibilityAtFirst and macroText and macroText ~= "" then
    trackerVisibility = SecureCmdOptionParse(macroText)
  end

  if trackerVisibility and trackerVisibility ~= "ignore" then
    return trackerVisibility
  end

  local inInstance, instanceType = IsInInstance() 
  local isInKeystone = GetActiveKeystoneInfo() > 0

  if isInKeystone then 
    trackerVisibility = rules.inKeystoneVisibility
  elseif instanceType == "party" then
    trackerVisibility = rules.inDungeonVisibility
  elseif instanceType == "raid" then 
    trackerVisibility = rules.inRaidVisibility
  elseif instanceType == "scenario" then 
    trackerVisibility = rules.inScenarioVisibility  
  elseif instanceType == "arena" then 
    trackerVisibility = rules.inArenaVisibility
  elseif instanceType == "pvp" then 
    trackerVisibility = rules.inBattlegroundVisibility
  else
    trackerVisibility = "ignore"
  end

  if trackerVisibility and trackerVisibility ~= "ignore" then 
    return trackerVisibility
  end

  if IsInRaid()  then 
    trackerVisibility = tracker.inRaidGroupVisibility
  elseif IsInGroup() then 
    trackerVisibility = tracker.inPartyVisibility
  else 
    trackerVisibility = "ignore"
  end

  if not trackerVisibility or trackerVisibility ~= "ignore" then 
    return trackerVisibility
  end

  if not rules.evaluateMacroAtFirstCheckBox and macroText and macroText ~= "" then 
    trackerVisibility = SecureCmdOptionParse(macroText)
  end

  return trackerVisibility
end

-- Export the functions in the API
API.NewTracker = NewTracker
API.DeleteTracker = DeleteTracker
API.IterateTrackers = IterateTrackers
API.GetTracker = GetTracker
API.RegisterTrackerSetting = RegisterTrackerSetting
API.GetTrackerSetting = GetTrackerSetting
API.GetTrackerSettingWithDefault = GetTrackerSettingWithDefault 
API.SetTrackerSetting = SetTrackerSetting
API.FromTrackerSetting = FromTrackerSetting

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
  function __ctor(self) 
   end 
end)
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterTrackerSetting({ id = "enabled", default = true, handler = private__SetEnabledTracker })
RegisterTrackerSetting({ id = "locked", default = false })
RegisterTrackerSetting({ id = "position"})
RegisterTrackerSetting({ id = "size", default = Size(300, 325) })

RegisterTrackerSetting({
  id = "contentsTracked",
  ignoreDefault = true, 
  handler = function(trackerID, contentTracked, contentID)
    if not contentID then 
      return 
    end

    local tracker = TRACKERS[trackerID]
    if not tracker then 
      return 
    end

    local shouldBeTracked = private__IsContentShouldTracked(trackerID, contentTracked)
    if shouldBeTracked then 
      tracker:TrackContent(contentID)
    else
      tracker:UntrackContent(contentID)
    end

    tracker.VisibilityRulesShown = GetRulesVisibilityShownForTracker(tracker)
  end, 
  saveHandler = function(trackerID, contentTracked, contentID)
    if not contentID then 
      return 
    end

    local _, isDefault = private__IsContentShouldTracked(trackerID, contentTracked)

    SavedVariables.Profile().Path("trackers", trackerID, "contents", contentID)
    if isDefault then
      SavedVariables.SetValue("tracked", nil)
    else
      SavedVariables.SaveValue("tracked", contentTracked)
    end
  end,
  getHandler = private__GetContentTracked
})

RegisterTrackerSetting({
  id = "visibilityRules",
  structType = VisibilityRulesType,
  handler = function(trackerID, value, subSetting)
    local tracker = TRACKERS[trackerID]
    if not tracker and not subSetting then 
      return 
    end

    tracker.VisibilityRules[subSetting] = value

    if subSetting == "enableAdvancedRules" then
      if value then  
        RegisterTrackerForAutoVisibility(tracker)
      else
        UnregisterTrackerForAutoVisibility(tracker)
      end
    elseif subSetting == "macroVisibility" then
      if value ~= "" then 
        RegisterTrackerForMacroTicker(tracker)
      else 
        UnregisterTrackerForMacroTicker(tracker)
      end
    end

    tracker.VisibilityRulesShown = GetRulesVisibilityShownForTracker(tracker)
  end
})
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromVisible()
  return FromUIProperty("Minimized", "VisibilityRulesShown"):Map(function(minimized, visibilityRulesShown)
    if minimized then 
      return false 
    end
    
    return visibilityRulesShown
  end)
end

function FromLocation()
  return FromTrackerSetting("position"):Map(function(pos, tracker)
    if pos then
      return  { Anchor("TOPLEFT", pos.x or 0, pos.y or 0, nil, "BOTTOMLEFT") }
    end
    
    return tracker.id == "main" and { Anchor("RIGHT", -40, 0) } or { Anchor("CENTER") }
  end)
end

__Arguments__ { Boolean/true}
function FromMinizeButtonAtlas(normal)
  return FromUIProperty("Minimized"):Map(function(minimized)
    if minimized then 
      return normal and AtlasType("common-button-dropdown-closed", false) or AtlasType("common-button-dropdown-closedpressed", false)

    else
      return normal and AtlasType("common-button-dropdown-open", false) or AtlasType("common-button-dropdown-closedpressed", false)
    end
  end)
end
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
    },
  },

  [TrackerMinimizeButton] = {
    size = { width = 24, height = 24 },
    registerForClicks = { "AnyUp"},
    visible = FromUIProperty("Enabled"),

    NormalTexture = {
      setAllPoints = true,
      atlas = FromMinizeButtonAtlas()
    },
    PushedTexture = {
      setAllPoints = true,
      atlas = FromMinizeButtonAtlas(false)
    },

    HighlightTexture        = {
      atlas = AtlasType("common-iconmask", false),
      setAllPoints = true,
      vertexColor = { r = 1, g = 1, b = 1, a = 0.05}
    }
  },

  [Tracker] = {
    visible                           = FromVisible(),
    locked                            = FromTrackerSetting("locked"),
    clipChildren                      = false,
    minResize                         = { width = 100, height = 100},
    size                              = FromTrackerSetting("size"),
    location                          = FromLocation(),
    resizable                         = true,
    movable                           = true,

    ScrollFrame = {
      location  = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMRIGHT")
      },
    },

    MinimizeButton = {
      location = {
        Anchor("BOTTOMLEFT", 5, 0, nil, "TOPRIGHT")
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
__SystemEvent__()
__Async__() function PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUI)
  if isInitialLogin or isReloadingUI then 
    local trackers = SavedVariables.Path("list").GetValue("trackers")
    local trackersSettings = SavedVariables.Profile().GetValue("trackers")

    if trackersSettings then 
      -- Create the main tracker if enabled
      local settings = trackersSettings["main"]
      local enabled = settings and settings.enabled

      if enabled == nil or enabled then 
        local tracker = private__NewTracker("main")
        LoadTracker(tracker)
      end

      -- Create the custtom trackers if enabled
      if trackers then 
        for trackerID in pairs(trackers) do 
          settings = trackersSettings[trackerID]
          enabled = settings and settings.enabled or true 
          if enabled then 
            local tracker = private__NewTracker(trackerID)
            LoadTracker(tracker)
          end         
        end
      end
    end
  end
end