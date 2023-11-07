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
  FromUIProperty = Wow.FromUIProperty
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
      self.DungeonName = data.name
      self.DungeonTextureFileID = data.textureFileID

      local objectives = self:GetChild("Objectives")
      objectives:UpdateView(data.objectives, metadata)
    else 
      self.DungeonName = nil 
      self.DungeonTextureFileID = nil
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

  __Observable__()
  property "DungeonTextureFileID" {
    type = Number
  }

  __Observable__()
  property "DungeonName" {
    type = String
  }


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
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [DungeonContentView] = {
    TopDungeonInfo = {
      backdrop = {
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1
      },
      
      backdropBorderColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
      height = 48,

      location = {
        Anchor("TOP", 0, 0, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      DungeonIcon = {
        fileID = FromUIProperty("DungeonTextureFileID"),
        setAllPoints = true,
      },

      DungeonName = {
        text = FromUIProperty("DungeonName"),
        fontObject = Game18Font,
        textColor = { r = 1, g = 0.914, b = 0.682},

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