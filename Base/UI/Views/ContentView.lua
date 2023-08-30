-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.UI.ContentView"                       ""
-- ========================================================================= --
export {
  TryToComputeHeightFromChildren = Utils.Frame_TryToComputeHeightFromChildren,
  FromUIProperty = Wow.FromUIProperty
}

__UIElement__()
class "ContentView" (function(_ENV)
  inherit "Frame" extend "IView" "IQueueAdjustHeight" "ISizeAnimation"

  local function OnExpandedHandler(self, new, old)
    if new then 
      self:OnExpand()
    else
      self:OnCollapse()
    end

    self:AdjustHeight()
  end

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
        Icon    = Texture,
        Label   = FontString,
        Minimize = Button,
      }
    }
  }
  function __ctor(self)
    local minimizeButton = self:GetChild("Header"):GetChild("Minimize")
    minimizeButton.OnClick = minimizeButton.OnClick + function()
      self.Expanded = not self.Expanded
    end

    -- self:SetHeight(1)
    -- self:SetClipsChildren(true)
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ContentView] = {
    height = 32,
    minResize = { width = 0, height = 32},
    clipChildren = true,
    autoAdjustHeight = true,

    -- backdrop = {
    --   bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    --   edgeFile  = [[Interface\Buttons\WHITE8X8]],
    --   edgeSize  = 1
    -- },

    -- backdropColor       = { r = 1, g = 20/255, b = 23/255, a = 0.87}, -- 87
    -- backdropBorderColor = { r = 0, g = 0, b = 0, a = 1},

    Header = {
      height = 32,
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1
      },

      backdropColor       = { r = 18/255, g = 20/255, b = 23/255, a = 0.87}, -- 87
      backdropBorderColor = { r = 0, g = 0, b = 0, a = 1},


      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      Icon = {
        -- height = 16,
        -- width = 16,
        -- atlas = AtlasType("poi-majorcity"),
        height = 20,
        width = 20,
        drawLayer = "ARTWORK",

        -- atlas = AtlasType("Dungeon"),
        mediaTexture = FromUIProperty("ContentIcon"),
        location = {
          Anchor("LEFT", 6, 0)
        }

        -- maskTexture = {
        --   hWrapMode = "CLAMPTOBLACKADDITIVE",
        --   vWrapMode = "CLAMPTOBLACKADDITIVE",
        --   file = [[Interface\CHARACTERFRAME\TempPortraitAlphaMask]]
        -- }
      },

      Label = {
        text = FromUIProperty("ContentName"),
        mediaFont = FontType("PT Sans Narrow Bold", 15),
        textColor = Color(0.18, 0.71, 1),
        justifyH  = "CENTER",
        justifyV  = "MIDDLE",
        textTransform = "NONE",
        location = {
          -- Anchor("TOP"),
          -- Anchor("LEFT", 6, 0, "Icon", "RIGHT"),
          -- Anchor("RIGHT"),
          -- Anchor("BOTTOM")
          Anchor("TOPLEFT"),
          Anchor("BOTTOMRIGHT")
        }
      },

      Minimize = {
        height = 11,
        width = 16,

        normalTexture = {
          setAllPoints = true, 
          mediaTexture = Wow.FromUIProperty("Expanded"):Map(function(expanded)
            if expanded then 
              return { atlas = AtlasType("UI-HUD-Minimap-Zoom-Out") }
            end 

            return { atlas = AtlasType("UI-HUD-Minimap-Zoom-In") }
          end)
          -- mediaTexture = { atlas = AtlasType("UI-HUD-Minimap-Zoom-In") } , -- UI-HUD-Minimap-Zoom-Out
        }, 
        location = {
          Anchor("RIGHT", -6, 0)
        }
      }
    },

    -- Content = {
    --   height = 200,
    --   backdrop = {
    --     bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    --     edgeFile  = [[Interface\Buttons\WHITE8X8]],
    --     edgeSize  = 1
    --   },

    --   backdropColor       = { r = 18/255, g = 20/255, b = 23/255, a = 0.87}, -- 87
    --   backdropBorderColor = { r = 0, g = 0, b = 0, a = 1},
    --   location = {
    --     Anchor("TOP", 0, 0, "Header", "BOTTOM"),
    --     Anchor("LEFT"),
    --     Anchor("RIGHT")
    --   }
    -- }
  }
})