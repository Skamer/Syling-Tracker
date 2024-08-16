-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.FramePointPicker"         ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --
export {
    FromUIProperty = Wow.FromUIProperty
}

__Widget__()
class "FramePointButton"(function(_ENV)
    inherit "PushButton"
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
    __Observable__()
    property "Selected" {
        type = Boolean,
        default = false
    }

    property "Value" {
        type = Any
    }

    __Observable__()
    property "Enabled" {
        type = Boolean,
        default = true
    }
end)

__Widget__()
class "FramePointPicker"(function(_ENV)
    inherit "Frame"

    FRAME_NAME_BY_POINTS = {
        ["TOP"] = "TopPoint",
        ["TOPLEFT"] = "TopLeftPoint",
        ['TOPRIGHT'] = "TopRightPoint",
        ["CENTER"] = "CenterPoint",
        ["LEFT"] = "LeftPoint",
        ["RIGHT"] = "RightPoint",
        ["BOTTOMLEFT"] = "BottomLeftPoint",
        ["BOTTOMRIGHT"] = "BottomRightPoint",
        ["BOTTOM"] = "BottomPoint"
    }
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
    event "OnValueChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
    local function OnFramePointClick(self)
        local point = self.Value
        self:GetParent():SetValue(point, true)
    end

    local function OnValueChangedHandler(self, new, old)
        if old then 
            self:GetChild(FRAME_NAME_BY_POINTS[old]).Selected = false
        end

        if new then 
            self:GetChild(FRAME_NAME_BY_POINTS[new]).Selected = true
        end

        
        self:OnValueChanged(new, old, self.TreatAsMouseEvent)
    end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
    __Arguments__ { FramePoint/nil, Boolean/false}
    function SetValue(self, value, treatAsMouseEvent)
        self.TreatAsMouseEvent  = treatAsMouseEvent
        self.Value              = value
        self.TreatAsMouseEvent  = nil
    end

    __Abstract__ { FramePoint }
    function DisablePoint(self, point)
        local pointButton = self:GetChild(FRAME_NAME_BY_POINTS[point])
        pointButton.Enabled = false
    end

    __Arguments__ { FramePoint }
    function EnablePoint(self, point)
        local pointButton = self:GetChild(FRAME_NAME_BY_POINTS[point])
        pointButton.Enabled = true
    end

    __Arguments__ { FramePoint * 0}
    function DisablePoints(self, ...)
        local count = select("#", ...)

        if count == 0 then 
            for point in pairs(FRAME_NAME_BY_POINTS) do 
                self:DisablePoint(point)
            end
        else 
            for i = 1, count do 
                local point = select(i, ...)
                self:DisablePoint(point)
            end
        end
    end

    __Arguments__ { FramePoint * 0}
    function EnablePoints(self, ...)
        local count = select("#", ...)

        if count == 0 then 
            for point in pairs(FRAME_NAME_BY_POINTS) do 
                self:EnablePoint(point)
            end
        else 
            for i = 1, count do 
                local point = select(i, ...)
                self:EnablePoint(point)
            end
        end
    end

    __Arguments__ { String/"" }
    function SetText(self, text)
        self.Text = text
    end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
    property "Value" {
        type    = FramePoint,
        handler =  OnValueChangedHandler
    }

    __Observable__()
    property "Text" {
        type    = String,
        default = ""
    }

    property "TreatAsMouseEvent" {
        type    = Boolean,
        default = false
    } 
    -----------------------------------------------------------------------------
    --                            Constructors                                 --
    -----------------------------------------------------------------------------
    __Template__ {
        Text              = FontString,
        Screen            = Frame,
        TopPoint          = FramePointButton,
        TopLeftPoint      = FramePointButton,
        TopRightPoint     = FramePointButton,
        CenterPoint       = FramePointButton,
        BottomLeftPoint   = FramePointButton,
        BottomRightPoint  = FramePointButton,
        BottomPoint       = FramePointButton,
        LeftPoint         = FramePointButton,
        RightPoint        = FramePointButton,
    }
    function __ctor(self) 
        for point, pointButtonName in pairs(FRAME_NAME_BY_POINTS) do
            local pointButton = self:GetChild(pointButtonName)
            pointButton.OnClick = pointButton.OnClick + OnFramePointClick
            pointButton.Value = point
        end
    end
end)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromFramePointButtonBackdropColor()
    local selectedColor = Color(240/255, 181/255, 0, 0.75)
    local normalColor = Color(0.1, 0.1, 0.1, 0.75)

    return FromUIProperty("Selected"):Map(function(selected)
        return selected and selectedColor or normalColor
    end)
end

function FromFramePointButtonBorderColor()
    local normalColor = Color(0.45, 0.45, 0.45, 0.75)

    return PushButton.FromBorderColor(normalColor)
        :CombineLatest(FromUIProperty("Selected"))
        :Map(function(unselectedColor, selected)
            return selected and normalColor or unselectedColor
        end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
    [FramePointButton] = {
        size                          = Size(12, 12),
        visible                       = FromUIProperty("Enabled"),
        backdrop                      = {
                                        bgFile    = [[Interface\Buttons\WHITE8X8]],
                                        edgeFile  = [[Interface\Buttons\WHITE8X8]],
                                        edgeSize  = 1   
                                      },
        backdropColor                 = FromFramePointButtonBackdropColor(),
        backdropBorderColor           = FromFramePointButtonBorderColor(),
        frameStrata                   = "HIGH",
        frameLevel                    = 10,
        hitRectInsets                 = { top = -8, left = -8, bottom = -8, right = -8 }
    },

    [FramePointPicker] = {
        size                          = Size(120, 95),

        Text = {
            text                      = FromUIProperty("Text"),
            fontObject                = GameFontNormal,
            height                    = 26,
            location                  = { Anchor("TOP"), Anchor("LEFT"), Anchor("RIGHT") },
        },

        Screen = {
            backdrop                  = {
                                        edgeFile = [[Interface\Buttons\WHITE8X8]],
                                        edgeSize = 2
                                      },
    
            backdropBorderColor       = { r = 0.45, g = 0.45, b = 0.45, a = 0.75},
            location                  = {
                                        Anchor("TOP", 0, -6, "Text", "BOTTOM"),
                                        Anchor("BOTTOM", 0, 6),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
        },

        TopLeftPoint = {
            location                  = { Anchor("CENTER", 0, 0, "Screen", "TOPLEFT") }
        },
        LeftPoint = {
            location                  = { Anchor("CENTER", 0, 0, "Screen", "LEFT") }
        },
        BottomLeftPoint = {
            location                  = { Anchor("CENTER", 0, 0, "Screen", "BOTTOMLEFT") }
        },
        BottomPoint = {
            location                  = { Anchor("CENTER", 0, 0, "Screen", "BOTTOM")}
        },
        BottomRightPoint = {
            location                  = { Anchor("CENTER", 0, 0, "Screen", "BOTTOMRIGHT") }
        },
        RightPoint = {
            location = { Anchor("CENTER", 0, 0, "Screen", "RIGHT") }
        },
        TopRightPoint = {
            location = { Anchor("CENTER", 0, 0, "Screen", "TOPRIGHT") }
        },
        TopPoint = {
            location = { Anchor("CENTER", 0, 0, "Screen", "TOP") }
        },
        CenterPoint = {
            location = { Anchor("CENTER", 0, 0, "Screen", "CENTER") }
        }
    }
})
