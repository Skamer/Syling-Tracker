-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker.Options.Elements.ExpandableSection"           ""
-- ========================================================================= --
__Widget__()
class "SUI.ExpandableSection" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function UpdateVisibility(self)
    for name, frame in self:GetChilds() do
      if Class.IsObjectType(frame, Frame) and frame:GetID() > 0 then 
        frame:SetShown(self.Expanded)
      end
    end
  end

  function SetTitle(self, title)
    Style[self].Button.Text.text = title
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------  
  property "Expanded" {
    type = Boolean,
    default = false,
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
      local expanded = not self.Expanded
      if expanded then 
        Style[button].RightBGTexture.atlas = AtlasType("Options_ListExpand_Right_Expanded", true)
      else 
        Style[button].RightBGTexture.atlas = AtlasType("Options_ListExpand_Right", true)
      end

      self.Expanded = expanded
      self:UpdateVisibility()
    end

  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.ExpandableSection] = {
    height = 25,
    width = 200,
    layoutManager = Layout.VerticalLayoutManager(),
    paddingTop = 32,
    paddingBottom = 10,
    paddingLeft = 20,
    paddingRight = 0,
    marginRight = 0,

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