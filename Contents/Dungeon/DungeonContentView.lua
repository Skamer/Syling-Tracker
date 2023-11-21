-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.DungeonContentView"           ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty
}

__UIElement__()
class "DungeonContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data then 
      self.DungeonName          = data.name
      self.DungeonTextureFileID = data.textureFileID

      local objectives = self:GetChild("Objectives")
      objectives:UpdateView(data.objectives, metadata)
    else 
      self.DungeonName          = nil 
      self.DungeonTextureFileID = nil
    end
  end

  function OnExpand(self)
    Style[self].TopDungeonInfo.visible  = true
    Style[self].Objectives.visible      = true
  end

  function OnCollapse(self)
    Style[self].TopDungeonInfo.visible  = false
    Style[self].Objectives.visible      = false
  end

  __Observable__()
  property "DungeonTextureFileID" {
    type = Number
  }

  __Observable__()
  property "DungeonName" {
    type = String
  }


  __Template__{
    TopDungeonInfo  = Frame,
    Objectives      = ObjectiveListView,
    {
      TopDungeonInfo = {
        DungeonName       = FontString,
        DungeonIcon       = Texture,
        DungeonObjectIcon = Texture,
      }
    }
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [DungeonContentView] = {
    Header = {
      visible                         = false
    },

    TopDungeonInfo = {
      backdrop                        = { edgeFile  = [[Interface\Buttons\WHITE8X8]], edgeSize  = 1 },
      backdropBorderColor             = Color(35/255, 40/255, 46/255, 0.73),
      height                          = 48,
      location                        = { Anchor("TOP"), Anchor("LEFT"), Anchor("RIGHT") },

      DungeonObjectIcon = {
        atlas                         = AtlasType("Dungeon", true),
        location                      = { Anchor("TOPLEFT", 5, -5) }
      },

      DungeonIcon = {
        fileID                        = FromUIProperty("DungeonTextureFileID"),
        setAllPoints                  = true,
      },

      DungeonName = {
        text                          = FromUIProperty("DungeonName"),
        fontObject                    = Game18Font,
        textColor                     = { r = 1, g = 0.914, b = 0.682},

        location                      = {
                                        Anchor("LEFT", 5, 0),
                                        Anchor("TOP"),
                                        Anchor("BOTTOM"),
                                        Anchor("RIGHT")
                                      }
      }
    },

    Objectives = {
      autoAdjustHeight                = true,
      backdrop                        = { 
                                        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
                                        edgeFile  = [[Interface\Buttons\WHITE8X8]],
                                        edgeSize  = 1
                                      },

      backdropColor                   = Color(35/255, 40/255, 46/255, 0.73),
      backdropBorderColor             = Color(0, 0, 0, 0.4),

      location                        = {
                                        Anchor("TOP", 0, -5, "TopDungeonInfo", "BOTTOM"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
    }
  }
})