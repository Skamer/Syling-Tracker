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

  -- Wow API
  UIWidgetVisualizationType           = _G.Enum.UIWidgetVisualizationType,
  GetAllWidgetsBySetID                = C_UIWidgetManager.GetAllWidgetsBySetID
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
class "UIWidgetStatusBar"(function(_ENV)
  inherit "ProgressBar" extend "IUIWidget"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Setup(self, widgetData)
    self.BarMax     = widgetData.barMax 
    self.BarMin     = widgetData.barMin
    self.BarValue   = widgetData.barValue
    self.TextureKit = widgetData.textureKit
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
  property "TextureKit" {
    type = String,
  }


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
    local timerValue = Clamp(widgetInfo.timerValue, widgetInfo.timerMin, widgetInfo.timerMax)

    self.Duration = widgetInfo.timerMax
    self.StartTime = GetTime() - Lerp(widgetInfo.timerMax, 0, timerValue / widgetInfo.timerMax)
    self.ElapsedTime = GetTime()
    self.Started = true
    Style[self].ShowRemainingTime = true
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
  [UIWidgetVisualizationType.WorldLootObject] = nil, -- 26
  [UIWidgetVisualizationType.ItemDisplay] = nil, -- 27
  [UIWidgetVisualizationType.TugOfWar] = nil, -- 28
}

  __UIElement__()
  class "UIWidgets" (function(_ENV)
    inherit "Frame"

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

      local widgetsInfo = GetAllWidgetsBySetID(self.WidgetSetID)
      for index, widgetInfo in ipairs(widgetsInfo) do
        self:ProcessWidget(widgetInfo)
      end

      self:ReleaseUnusedWidgets()
    end

    function ReleaseUnusedWidgets(self)
      for key, widget in pairs(self.Widgets) do 
        if not self.WidgetsKeys[key] then
          widget:Release()
          self.Widgets[key] = nil
        end
      end
    end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
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
    [UIWidgetStatusBar] = {
      marginRight = 10,
      marginLeft = 10,
      minMaxValues                    = FromUIProperty("BarMin", "BarMax"):Map(function(min, max) return MinMax(min, max) end),
      value                           = FromUIProperty("BarValue"),
      statusBarColor                  = FromUIWidgetStatusBarColor()
    },
    [UIWidgetTextWithState] = {
      autoAdjustHeight                = true,
      Text = {
        text                          = FromUIProperty("Text"),
        location                      = { Anchor("TOPLEFT"), Anchor("TOPRIGHT") }
      }
    }
  })