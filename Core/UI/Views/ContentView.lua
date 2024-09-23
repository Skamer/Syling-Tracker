-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.UI.ContentView"                       ""
-- ========================================================================= --
export {
  TryToComputeHeightFromChildren      = Utils.Frame_TryToComputeHeightFromChildren,
  FromUIProperty                      = Wow.FromUIProperty,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  FromBackdrop                        = Frame.FromBackdrop,
}

__UIElement__()
__Sealed__() class "ContentView" (function(_ENV)
  inherit "Frame" extend "IView" "IQueueAdjustHeight" "ISizeAnimation"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnExpandedHandler(self, new, old)
    if new then 
      self:OnExpand()
    else
      self:OnCollapse()
    end

    self:AdjustHeight()
  end
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnExpand() end 
  function OnCollapse() end

  function OnViewUpdate(self, data, metadata)
    if metadata then 
      self.ContentName = metadata.contentName 
      self.ContentIcon = metadata.contentIcon
    end
  end

  function OnAdjustHeight(self)
    local height = self:TryToComputeHeightFromChildren()
    if height then 
      self:AnimateToTargetHeight(height)
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "Expanded" {
    type = Boolean,
    default = true,
    handler = OnExpandedHandler
  }

  __Observable__()
  property "ContentName" {
    type = String
  }

  __Observable__()
  property "ContentIcon" {
    type = MediaTextureType
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Header    = Frame,
    {
      Header = {
        Icon      = Texture,
        Label     = FontString,
        Minimize  = Button,
      }
    }
  }
  function __ctor(self)
    local minimizeButton = self:GetChild("Header"):GetChild("Minimize")
    minimizeButton.OnClick = minimizeButton.OnClick + function()
      self.Expanded = not self.Expanded
    end
  end
end)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromNormalMediaTexture()
  return FromUIProperty("Expanded"):Map(function(expanded)
    if expanded then 
      if IsRetail() then 
        return { atlas = AtlasType("UI-HUD-Minimap-Zoom-Out") }
      else
        return { atlas = AtlasType("minimal-scrollbar-small-arrow-top")}
      end
    end

    if IsRetail() then
      return { atlas = AtlasType("UI-HUD-Minimap-Zoom-In") }
    else
      return { atlas = AtlasType("minimal-scrollbar-small-arrow-bottom") }
    end
  end)
end
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("content.showHeader", true)
RegisterUISetting("content.header.showBackground", true)
RegisterUISetting("content.header.showBorder", true)
RegisterUISetting("content.header.backgroundColor", Color(18/255, 20/255, 23/255, 0.87))
RegisterUISetting("content.header.borderColor", Color.BLACK)
RegisterUISetting("content.header.borderSize", 1)
RegisterUISetting("content.header.label.mediaFont", FontType("PT Sans Narrow Bold", 15))
RegisterUISetting("content.header.label.textColor", Color(0.18, 0.71, 1))
RegisterUISetting("content.header.label.justifyH", "CENTER")
RegisterUISetting("content.header.label.justifyV", "MIDDLE")
RegisterUISetting("content.header.label.textTransform", "NONE")
RegisterUISetting("content.header.showMinimizeButton", true)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ContentView] = {
    height                            = 32,
    minResize                         = { width = 0, height = 32},
    clipChildren                      = true,
    autoAdjustHeight                  = true,

    Header = {
      visible                         = FromUISetting("content.showHeader"),
      height                          = 32,
      backdrop                        = FromBackdrop(),
      showBackground                  = FromUISetting("content.header.showBackground"),
      showBorder                      = FromUISetting("content.header.showBorder"),
      backdropColor                   = FromUISetting("content.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("content.header.borderColor"),
      borderSize                      = FromUISetting("content.header.borderSize"),
      location                        = {
                                        Anchor("TOP"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      },

      Icon = {
        height                        = 20,
        width                         = 20,
        drawLayer                     = "ARTWORK",
        mediaTexture                  = FromUIProperty("ContentIcon"),
        location                      = { Anchor("LEFT", 6, 0) }
      },

      Label = {
        text                          = FromUIProperty("ContentName"),
        mediaFont                     = FromUISetting("content.header.label.mediaFont"),
        textColor                     = FromUISetting("content.header.label.textColor"),
        justifyH                      = FromUISetting("content.header.label.justifyH"),
        justifyV                      = FromUISetting("content.header.label.justifyV"),
        textTransform                 = FromUISetting("content.header.label.textTransform"),
        location                      = {
                                        Anchor("TOP"),
                                        Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
                                        Anchor("BOTTOM"),
                                        Anchor("RIGHT", 0, 0, "Minimize", "LEFT")
                                      }
      },

      Minimize = {
        visible                       = FromUISetting("content.header.showMinimizeButton"),
        height                        = 11,
        width                         = 16,

        normalTexture = {
          setAllPoints                = true, 
          mediaTexture                = FromNormalMediaTexture()
        },

        location                      = { Anchor("RIGHT", -6, 0) }
      }
    }
  }
})