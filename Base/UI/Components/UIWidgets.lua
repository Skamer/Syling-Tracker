-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.UI.UIWidgets"                          ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  Tooltip                             = API.GetTooltip(),

  -- Wow API
  UIWidgetVisualizationType           = _G.Enum.UIWidgetVisualizationType,
  GetAllWidgetsBySetID                = C_UIWidgetManager.GetAllWidgetsBySetID,

  -- Status Bar
  StatusBarValueTextType              = _G.Enum.StatusBarValueTextType,
  StatusBarOverrideBarTextShownType   = _G.Enum.StatusBarOverrideBarTextShownType
}

function GetWidgetTypeInfo(...)
  return UIWidgetManager:GetWidgetTypeInfo(...)
end

interface "IUIWidget"(function(_ENV)
   -----------------------------------------------------------------------------
  --                               Methods                                   --
  ----------------------------------------------------------------------------- 
  __Abstract__()
  function Setup(self, widgetData) end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "WidgetID" {
    type = Number
  }

  property "WidgetType" {
    type = Number
  }

  property "WidgetSetID" {
    type = Number
  }

  property "UnitToken" {
    type = Any
  }
end)

__UIElement__()
class "UIWidgetStatusBarPartition" { Texture }

__UIElement__()
class "UIWidgetStatusBar"(function(_ENV)
  inherit "ProgressBar" extend "IUIWidget"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEnterHandler(self)
    local tooltip = self.Tooltip
    if tooltip then
      Tooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
      Tooltip:SetText(tooltip)
      Tooltip:Show()
    end
  end

  local function OnLeaveHandler(self)
    if self.Tooltip then 
      Tooltip:Hide()
    end
  end

  local function OnSizeChangedHandler(self, width)
    self:UpdateParitionsPosition(width)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Setup(self, widgetData)
    self.BarMax     = widgetData.barMax 
    self.BarMin     = widgetData.barMin
    self.BarValue   = widgetData.barValue
    self.TextureKit = widgetData.textureKit
    self.OverrideBarTextShownType = widgetData.overrideBarTextShownType
    self.OverrideBarText = widgetData.overrideBarText
    self.Tooltip  = widgetData.tooltip

    -- Bar Text
    local barValueTextType = widgetData.barValueTextType
    local maxTimeCount

    if barValueTextType == StatusBarValueTextType.Time then 
      maxTimeCount = 2
    elseif barValueTextType == StatusBarValueTextType.TimeShowOneLevelOnly then 
      maxTimeCount = 1
    end

    if maxTimeCount then
      self.BarText = SecondsToTime(self.BarValue, false, true, maxTimeCount, true)
    elseif barValueTextType == StatusBarValueTextType.Value then
      self.BarText = tostring(self.BarValue)
    elseif barValueTextType == StatusBarValueTextType.ValueOverMax then 
      self.BarText = FormatFraction(self.BarValue, self.BarMax)
    elseif barValueTextType == StatusBarValueTextType.ValueOverMaxNormalized then 
      self.BarText = FormatFraction(self.BarValue - self.BarMin, self.BarMax - self.BarMin)
    elseif barValueTextType == StatusBarValueTextType.Percentage then 
      local barPercent = PercentageBetween(self.BarValue, self.BarMin, self.BarMax)
      self.BarText = FormatPercentage(barPercent, true)
    else 
      self.BarText = ""
    end

    -- Partitions
    self:InitPartitions(widgetData.partitionValues)
    self:ReleaseUnusedPartitions()
  end

  function AcquirePartition(self, index)
    local partition = self.Partitions[index]
    if not partition then 
      partition = UIWidgetStatusBarPartition.Acquire()
      partition:SetParent(self)
      partition:SetHeight(self:GetHeight())

      self.Partitions[index] = partition
    end

    return partition
  end

  function InitPartitions(self, partitionValues)
    wipe(self.PartitionsKeys)
    if not partitionValues or (#partitionValues == 0) then 
      return 
    end

    -- Can be 0, fallback with OnSizeChanged
    local barWidth = self:GetWidth()

    for index, partitionValue in ipairs(partitionValues) do 
      local partition = self:AcquirePartition(index)
      self:UpdatePartitionPosition(partition, partitionValue, barWidth)
      partition:Show()

      self.PartitionsKeys[index] = partitionValue
    end
  end

  function UpdatePartitionPosition(self, partition, partitionValue, barWidth)
    local partitionPercent = ClampedPercentageBetween(partitionValue, self.BarMin, self.BarMax)
    local xOffset = barWidth * partitionPercent
    partition:SetPoint("CENTER", self:GetStatusBarTexture(), "LEFT", xOffset, 0)
  end

  function UpdateParitionsPosition(self, barWidth)
    for index, partition in ipairs(self.Partitions) do
      local partitionValue = self.PartitionsKeys[index]
      self:UpdatePartitionPosition(partition, partitionValue, barWidth)
      partition:Show()
    end
  end

  function ReleaseUnusedPartitions(self)
    for key, partition in pairs(self.Partitions) do 
      if not self.PartitionsKeys[key] then
        partition:Release()
        self.Partitions[key] = nil
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "BarMax" {
    type = Number,
    default = 100
  }

  __Observable__()
  property "BarMin" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "BarValue" {
    type = Number,
    default = 0
  }
  
  __Observable__()
  property "BarText" {
    type = String,
    default = ""
  }

  __Observable__()
  property "TextureKit" {
    type = String,
  }

  property "Tooltip" {
    type = String
  }

  __Observable__()
  property "OverrideBarText" {
    type = String,
    default = ""
  }

  __Observable__()
  property "OverrideBarTextShownType" {
    type = Number,
    default = StatusBarOverrideBarTextShownType.Never
  }

  property "Partitions" {
    set = false,
    default = function() return Toolset.newtable(false, true) end 
  }

  property "PartitionsKeys" {
    set = false,
    default = function() return {} end
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {}
  function __ctor(self)
    self.OnEnter = self.OnEnter + OnEnterHandler 
    self.OnLeave = self.OnLeave + OnLeaveHandler
    self.OnSizeChanged = self.OnSizeChanged + OnSizeChangedHandler
  end
end)

__UIElement__()
class "UIWidgetTextWithState"(function(_ENV)
  inherit "Frame" extend "IUIWidget"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Setup(self, widgetData)
    self.Text = widgetData.text
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "Text" {
    type = String,
    default = ""
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Text = FontString
  }
  function __ctor(self) end
end)

__UIElement__()
class "UIWidgetScenarioHeaderTimer" (function(_ENV)
  inherit "Timer" extend "IUIWidget"

  function Setup(self, widgetInfo)
    local timerMax = widgetInfo.timerMax
    local timerMin = widgetInfo.timerMin
    local timerValue = Clamp(widgetInfo.timerValue, timerMin, timerMax)

    local hasTimer = widgetInfo.hasTimer
    -- When 'hasTimer' is true, this says the timer needs to update of its own.
    -- No more events wlll trigger this function.
    if hasTimer then 
      self.Duration = widgetInfo.timerMax
      self.StartTime = GetTime() - Lerp(timerMax, 0, timerValue / timerMax)
      self.ElapsedTime = GetTime()
      self.Started = true
    else
      -- If we are there, we don't need the timer update of its own because this function
      -- will be triggered every second, so we disable the timer and update manually 
      -- the Elapsed Time.
      self.Started = false
      self.StartTime = nil
      self.Duration = timerMax

      -- We have slight gap of '1' sec with the blizzard timer, so we will offset it.
      self.ElapsedTime = timerMax - timerValue + 1
    end
  end
end)

-- The widgets with 'nil' means they are not yet supported, and remain to be implemented.
UI_WIDGETS_CLASSES = {
  [UIWidgetVisualizationType.IconAndText] = nil, -- 0,
  [UIWidgetVisualizationType.CaptureBar] = nil, -- 1
  [UIWidgetVisualizationType.StatusBar] = UIWidgetStatusBar, -- 2
  [UIWidgetVisualizationType.DoubleStatusBar] = nil, -- 3
  [UIWidgetVisualizationType.IconTextAndBackground] = nil, -- 4
  [UIWidgetVisualizationType.DoubleIconAndText] = nil, -- 5
  [UIWidgetVisualizationType.StackedResourceTracker] = nil, -- 6
  [UIWidgetVisualizationType.IconTextAndCurrencies] = nil, -- 7
  [UIWidgetVisualizationType.TextWithState] = UIWidgetTextWithState, -- 8
  [UIWidgetVisualizationType.HorizontalCurrencies] = nil, -- 9
  [UIWidgetVisualizationType.BulletTextList] = nil, -- 10
  [UIWidgetVisualizationType.ScenarioHeaderCurrenciesAndBackground] = nil, -- 11
  [UIWidgetVisualizationType.TextureAndText] = nil, -- 12
  [UIWidgetVisualizationType.SpellDisplay] = nil, -- 13
  [UIWidgetVisualizationType.DoubleStateIconRow] = nil, -- 14
  [UIWidgetVisualizationType.TextureAndTextRow] = nil, -- 15
  [UIWidgetVisualizationType.ZoneControl] = nil, -- 16
  [UIWidgetVisualizationType.CaptureZone] = nil, -- 17
  [UIWidgetVisualizationType.TextureWithAnimation] = nil, -- 18
  [UIWidgetVisualizationType.DiscreteProgressSteps] = nil, -- 19
  [UIWidgetVisualizationType.ScenarioHeaderTimer] = UIWidgetScenarioHeaderTimer, -- 20
  [UIWidgetVisualizationType.TextColumnRow] = nil, -- 21
  [UIWidgetVisualizationType.Spacer] = nil, -- 22
  [UIWidgetVisualizationType.UnitPowerBar] = nil, -- 23
  [UIWidgetVisualizationType.FillUpFrames] = nil, -- 24
  [UIWidgetVisualizationType.TextWithSubtext] = nil, -- 25
  [UIWidgetVisualizationType.MapPinAnimation] = nil, -- 26
  [UIWidgetVisualizationType.ItemDisplay] = nil, -- 27
  [UIWidgetVisualizationType.TugOfWar] = nil, -- 28
}

__UIElement__()
class "UIWidgets" (function(_ENV)
  inherit "Frame"
  ---------------------------------------------------------------------------
    --                               Methods                                --
  ---------------------------------------------------------------------------
  function ProcessWidget(self, widgetInfo)
    local widgetID    = widgetInfo.widgetID
    local widgetType  = widgetInfo.widgetType
    local widgetClass = widgetType and UI_WIDGETS_CLASSES[widgetType]
  
    -- If no class, this is the addon not support yet, so we stop there for 
    -- this widget
    if not widgetClass then
      return 
    end

    local widgetTypeInfo = GetWidgetTypeInfo(widgetType)

    -- In case where we are unable to get the data function, stop there
    if not widgetTypeInfo then
      return 
    end

    local widgetData = widgetTypeInfo.visInfoDataFunction(widgetID)

    if not widgetData then
      return 
    end

    -- Acquire the widget 
    local widget = self.Widgets[widgetID]
    if not widget then 
      widget = widgetClass.Acquire()
      widget:SetParent(self)

      widget.WidgetID     = widgetID
      widget.WidgetType   = widgetType
      widget.WidgetSetID  = widgetInfo.widgetSetID
      widget.UnitToken    = widgetInfo.unitToken
      self.Widgets[widgetID] = widget
    end

    widget:Setup(widgetData)

    widget:SetID(widgetData.orderIndex + 1)

    Style[widget].marginBottom = 5

    self.WidgetsKeys[widgetID] = true

    return widget
  end

  function ProcessAllWidgets(self)
    wipe(self.WidgetsKeys)

    if self.WidgetSetID then 
      local widgetsInfo = GetAllWidgetsBySetID(self.WidgetSetID)
      for index, widgetInfo in ipairs(widgetsInfo) do
        self:ProcessWidget(widgetInfo)
      end
    end
    self:ReleaseUnusedWidgets()
  end

  function OnSystemEvent(self, event, ...)
    local widgetSetID = self.WidgetSetID
    if widgetSetID then 
      if event == "UPDATE_ALL_UI_WIDGETS" then 
        self:ProcessAllWidgets()
      elseif event == "UPDATE_UI_WIDGET" then 
        local widgetInfo = ...
        if widgetInfo and widgetInfo.widgetSetID == widgetSetID then
          local widgetID = widgetInfo.widgetID
          self.WidgetsKeys[widgetID] = nil -- TRY 

          self:ProcessWidget(widgetInfo)

          if not self.WidgetsKeys[widgetID] then 
            local widget = self.Widgets[widgetID]
            if widget then 
              widget:Release()
              self.Widgets[widgetID] = nil 
            end
          end
        end
      end
    end
  end

  function ReleaseUnusedWidgets(self)
    for key, widget in pairs(self.Widgets) do 
      if not self.WidgetsKeys[key] then
        widget:Release()
        self.Widgets[key] = nil
      end
    end
  end

  function OnAcquire(self)
    self:RegisterSystemEvents("UPDATE_ALL_UI_WIDGETS", "UPDATE_UI_WIDGET")
  end

  function OnRelease(self)
    self:UnregisterSystemEvents("UPDATE_ALL_UI_WIDGETS", "UPDATE_UI_WIDGET")

    wipe(self.WidgetsKeys)
    self:ReleaseUnusedWidgets()
  end
  ---------------------------------------------------------------------------
  --                               Properties                              --
  ---------------------------------------------------------------------------
  property "WidgetSetID" {
    type = Number,
    handler = function(self, new)
      if new ~= nil then 
        self:ProcessAllWidgets()
      end
    end
  }

  property "Widgets" {
    set = false,
    default = function() return Toolset.newtable(false, true) end 
  }

  property "WidgetsKeys" {
    set = false,
    default = function() return {} end

  }
end)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromUIWidgetStatusBarText()
  return FromUIProperty("Mouseover", "BarText", "OverrideBarText", "OverrideBarTextShownType")
    :Map(function(mouseover, barText, overrideBarText, overrideBarTextShownType)
      local showOverrideBarText = overrideBarTextShownType == StatusBarOverrideBarTextShownType.Always

      if not showOverrideBarText then
        if mouseover then 
          showOverrideBarText =  (overrideBarTextShownType == StatusBarOverrideBarTextShownType.OnlyOnMouseover)
        else 
          showOverrideBarText = (overrideBarTextShownType == StatusBarOverrideBarTextShownType.OnlyNotOnMouseover)
        end
      end

      return showOverrideBarText and overrideBarText or barText
    end)
end

function FromUIWidgetStatusBarColor()
  return FromUIProperty("TextureKit"):Map(function(textureKit)
    if textureKit == "Green" then 
      return { r = 0, g = 182/255, b = 21/255, a = 0.9}
    end
  
    return { r = 0, g = 148/255, b = 1, a = 0.9 }
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
  Style.UpdateSkin("Default", {
    [UIWidgets] = {
      width                             = 175,
      height                            = 1,
      backdrop                          = Frame.FromBackdrop(),
      showBackground                    = true,
      showBorder                        = true,
      backdropColor                     =  Color(35/255, 40/255, 46/255, 0.73),
      backdropBorderColor               = Color(0, 0, 0, 0.4),
      borderSize                        = 1,
      paddingTop                        = 5,
      paddingBottom                     = 5,
      layoutManager                     = Layout.VerticalLayoutManager(),
    },

    [UIWidgetScenarioHeaderTimer] = {
      showRemainingTime = true
    },

    [UIWidgetStatusBarPartition] = {
      color = Color.BLACK,
      width = 1,
    },
    [UIWidgetStatusBar] = {
      marginRight = 10,
      marginLeft = 10,
      minMaxValues                    = FromUIProperty("BarMin", "BarMax"):Map(function(min, max) return MinMax(min, max) end),
      value                           = FromUIProperty("BarValue"),
      statusBarColor                  = FromUIWidgetStatusBarColor(),

      Text = {
        text                          = FromUIWidgetStatusBarText()
      }
    },
    [UIWidgetTextWithState] = {
      autoAdjustHeight                = true,
      Text = {
        text                          = FromUIProperty("Text"),
        location                      = { Anchor("TOPLEFT"), Anchor("TOPRIGHT") }
      }
    }
  })