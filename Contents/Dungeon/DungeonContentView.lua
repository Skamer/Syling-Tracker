-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.DungeonContentView"           ""
-- ========================================================================= --
__UIElement__()
class "DungeonContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data then 
      local objectives = self:GetChild("Objectives")
      objectives:UpdateView(data.objectives, metadata)
    end
  end

  function OnExpand(self)
    Style[self].TopDungeonInfo.visible = true
    Style[self].Objectives.visible = true
  end

  function OnCollapse(self)
    Style[self].TopDungeonInfo.visible = false
    Style[self].Objectives.visible = false
  end


  __Template__{
    TopDungeonInfo = Frame,
    Objectives = ObjectiveListView,
    {
      TopDungeonInfo = {
        DungeonName = FontString,
        DungeonIcon = Texture,

      }
    }
  }
  function __ctor(self) 
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [DungeonContentView] = {
    -- height = 450,
    -- backdrop = {
    --   bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    --   edgeFile  = [[Interface\Buttons\WHITE8X8]],
    --   edgeSize  = 1
    -- },

    -- backdropColor       = { r = 1, g = 20/255, b = 23/255, a = 0.87}, -- 87
    -- backdropBorderColor = { r = 0, g = 0, b = 0, a = 1},


    TopDungeonInfo = {
      backdrop = {
        bgFile = [[Interface\Buttons\WHITE8X8]],
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1
      },
      backdropColor       = { r = 0, g = 0, b = 0, a = 0.65}, -- 87
      backdropBorderColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
      height = 48,

      location = {
        Anchor("TOP", 0, 0, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      DungeonIcon = {
        fileID = 4742929,
        -- texCoords = { left = 0.07,  right = 0.7, top = 0.08, bottom = 0.52 } ,
        texCoords = { left = 0.04,  right = 0.64, top = 0.02, bottom = 0.70 } ,
        vertexColor = { r = 1, g = 1, b = 1, a = 0.5 },
        -- snapToPixelGrid     = false,
        -- texelSnappingBias    = 0,
        -- fileID = 4742929,
        -- fileID = 4746641,
        -- fileID = 4742826,
        height = 44,
        -- width = 445,
        -- setAllPoints = true,
        location = {
          Anchor("LEFT", 1, 0),
          Anchor("RIGHT", -1, 0)
        }

        -- location = {
        --   Anchor("TOPLEFT", 1, -1),
        --   -- Anchor("LEFT"),
        --   -- Anchor("RIGHT"),
        --   -- Anchor("BOTTOM", 0, 2)
        -- }
      },
      -- DungeonIcon = {
      --   fileID = 4742929,
      --   -- texCoords = { left = 0.07,  right = 0.7, top = 0.08, bottom = 0.52 } ,
      --   texCoords = { left = 0.04,  right = 0.64, top = 0.02, bottom = 0.70 } ,
      --   vertexColor = { r = 1, g = 1, b = 1, a = 0.5 },
      --   -- snapToPixelGrid     = false,
      --   -- texelSnappingBias    = 0,
      --   -- fileID = 4742929,
      --   -- fileID = 4746641,
      --   -- fileID = 4742826,
      --   height = 64,
      --   width = 64,
      --   -- setAllPoints = true,
      --   location = {
      --     Anchor("LEFT", 2, 0),
      --     -- Anchor("RIGHT", -2, 0)
      --   }

      --   -- location = {
      --   --   Anchor("TOPLEFT", 1, -1),
      --   --   -- Anchor("LEFT"),
      --   --   -- Anchor("RIGHT"),
      --   --   -- Anchor("BOTTOM", 0, 2)
      --   -- }
      -- },

      DungeonName = {
        text = "Académie d'Algeth'ar",
        fontObject = Game18Font,
        textColor = { r = 1, g = 0.914, b = 0.682},

        -- location = {
        --   Anchor("LEFT", 5, 0),
        --   Anchor("TOP"),
        --   Anchor("BOTTOM"),
        --   Anchor("RIGHT")
        -- }
        location = {
          Anchor("LEFT", 5, 0),
          Anchor("TOP"),
          Anchor("BOTTOM"),
          Anchor("RIGHT")
        }
      }
    },

    Objectives = {
      autoAdjustHeight = true,
      height = 32,
      backdrop = { 
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      },
      backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      location = {
        Anchor("TOP", 0, 0, "TopDungeonInfo", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})