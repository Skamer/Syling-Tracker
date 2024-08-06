-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.UI.POIButton"                   ""
-- ========================================================================= --

__UIElement__()
class "POIButton" (function(_ENV)
    inherit "Scorpio.UI.Frame"
    -----------------------------------------------------------------------------
    --                               Methods                                   --
    -----------------------------------------------------------------------------
    function SetQuestID(self, questID)
        self.Button:SetQuestID(questID)
    end

    function SetStyle(self, style)
        self.Button:SetStyle(style)
    end

    function SetEnabled(self, enabled)
        self.Button:SetEnabled(enabled)
    end

    function SetSelected(self, selected)
        self.Button:SetSelected(selected)
    end

    function Update(self)
        local button = self.Button
        button:UpdateButtonStyle()
        button:EvaluateManagedHighlight()
    end
    -----------------------------------------------------------------------------
    --                               Properties                                --
    -----------------------------------------------------------------------------
    property "Button" { Type = Any }
    -----------------------------------------------------------------------------
    --                              Constructors                               --
    -----------------------------------------------------------------------------
    function __ctor(self)
        local poiButton = CreateFrame("Button", nil, self, "POIButtonTemplate")
        self.Button = poiButton
        self:SetSize(26, 26)
        
        poiButton.shouldShowGlow = false
        poiButton:SetAllPoints()
        poiButton:Show()
    
        self:SetScale(0.9)
    end
end)