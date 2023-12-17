-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.Widgets.ExpandableSection"            ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --

export {
  ResetStyles = SylingTracker.Utils.ResetStyles,
}

__Widget__()
class "ExpandableSection" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnChildChangedHandler(self, child, isAdded)
    if isAdded and child:GetID() > 0 then 
      child:SetShown(self.Expanded)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function UpdateVisibility(self)
    local button = self:GetChild("Button")
    if self.Expanded then 
      Style[button].RightBGTexture.atlas = AtlasType("Options_ListExpand_Right_Expanded", true)
    else 
      Style[button].RightBGTexture.atlas = AtlasType("Options_ListExpand_Right", true)
    end

    for name, frame in self:GetChilds() do
      if Class.IsObjectType(frame, Frame) and frame:GetID() > 0 then 
        frame:SetShown(self.Expanded)
      end
    end
  end

  function SetTitle(self, title)
    Style[self].Button.Text.text = title
  end

  __Arguments__ { Boolean/nil }
  function SetExpanded(self, expanded)
    self.Expanded = expanded
  end

  function IsExpanded(self)
    return self.Expanded
  end

  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    ResetStyles(self, true)

    self.Expanded = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------  
  property "Expanded" {
    type = Boolean,
    default = false,
    handler = UpdateVisibility
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Button = Button,
    {
      Button = {
        Text = FontString
      }
    }
  }
  function __ctor(self)
    local button = self:GetChild("Button")
    button.OnClick = button.OnClick + function()
      self:SetExpanded(not self:IsExpanded())
    end

    self.OnChildChanged = self.OnChildChanged + OnChildChangedHandler

  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ExpandableSection] = {
    height = 25,
    width = 200,
    layoutManager = Layout.VerticalLayoutManager(),
    paddingTop = 32,
    paddingBottom = 10,
    paddingLeft = 20,
    paddingRight = 0,
    marginRight = 0,
    clipChildren = true,

    Button = {
      height = 30,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT", -20, 0)
      },

      LeftBGTexture = {
        atlas = AtlasType("Options_ListExpand_Left", true),
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPLEFT")
        }
      },
      RightBGTexture = {
        atlas = AtlasType("Options_ListExpand_Right", true),
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPRIGHT")
        }
      },
      MiddleBGTexture = {
        atlas = AtlasType("_Options_ListExpand_Middle", true),
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
          Anchor("TOPRIGHT", 0, 0, "RightBGTexture", "TOPLEFT")
        }
      },

      Text = {
        fontObject = GameFontNormal,
        drawLayer = "OVERLAY",
        justifyH = "CENTER",
        maxLines = 1,
        location = {
          Anchor("LEFT", 21, 2)
        }
      }
    },
  }
})