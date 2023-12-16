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

local BLZ_EXPANDABLE_SECTION_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_OptionsExpandListButton]]

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
      --- Options_ListExpand_Right_Expanded, true
      Style[button].RightBGTexture.texCoords = { left = 0.03125, right = 0.90625, top = 0.4453125, bottom = 0.6484375}

    else 
      --- Options_ListExpand_Right, true
      Style[button].RightBGTexture.texCoords = { left = 0.03125, right = 0.90625, top = 0.2265625, bottom = 0.4296875}
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
        --- Options_ListExpand_Left, true
        file = BLZ_EXPANDABLE_SECTION_FILE,
        width = 12,
        height = 26,
        texCoords = { left = 0.03125, right = 0.40625, top = 0.6640625, bottom = 0.8671875},
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPLEFT")
        }
      },
      RightBGTexture = {
        --- Options_ListExpand_Right, true
        file = BLZ_EXPANDABLE_SECTION_FILE,
        width = 28,
        height = 26,
        texCoords = { left = 0.03125, right = 0.90625, top = 0.2265625, bottom = 0.4296875},
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPRIGHT")
        }
      },
      MiddleBGTexture = {
        --- _Options_ListExpand_Middle, true
        file = BLZ_EXPANDABLE_SECTION_FILE,
        height = 26,
        texCoords = { left = 0, right = 0.03125, top = 0.0078125, bottom = 0.2109375},
        horizTile = true,
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