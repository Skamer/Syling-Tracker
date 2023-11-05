-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.AchievementView"              ""
-- ========================================================================= --
export {
  FromUIProperty  = Wow.FromUIProperty,
}

__UIElement__()
class "AchievementView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    if data.objectives then 
      Style[self].Objectives.visible = true 
      local objectivesView = self:GetPropertyChild("Objectives")

      objectivesView:UpdateView(data.objectives, ...)
    end

    self.AchievementName = data.name
    self.AchievementDesc = data.description
    self.AchievementIconFileID = data.icon
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "AchievementName" {
    type = String,
    default = ""
  }

  __Observable__()
  property "AchievementDesc" {
    type = String,
    default = ""
  }

  __Observable__()
  property "AchievementIconFileID" {
    type = Number
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Frame, 
    {
      Header = {
        Name = FontString,
        Icon = Texture,
        Description = FontString,
      }
    }

  }
  function __ctor(self) end
end)

-- Optional Children for QuestView 
__ChildProperty__(AchievementView, "Objectives")
class(tostring(AchievementView) .. ".Objectives") { ObjectiveListView }

__UIElement__()
class "AchievementListView" { ListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AchievementView] = {
    height = 24,
    minResize = { width = 0, height = 24},
    autoAdjustHeight = true,

    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

    Header = {
      height = 1,
      autoAdjustHeight = true,
      paddingBottom = 5,
      Name = {
        text = FromUIProperty("AchievementName"),
        justifyV = "MIDDLE",
        height = 24,
        mediaFont = FontType("DejaVuSansCondensed Bold", 10),
        location = {
          Anchor("TOP", 0, -5),
          Anchor("LEFT"),
          Anchor("RIGHT"),
        }
      },

      Description = {
        text = FromUIProperty("AchievementDesc"),
        mediaFont = FontType("PT Sans Bold", 11),
        textColor = Color.WHITE,
        justifyH = "LEFT",
        justifyV = "TOP",
        location = {
          Anchor("TOP", 0, -5, "Name", "BOTTOM"),
          Anchor("LEFT", 5, 0, "Icon", "RIGHT"),
          Anchor("RIGHT")
        }
      },

      Icon = {
        fileID = FromUIProperty("AchievementIconFileID"),
        width = 32,
        height = 32,
        texCoords = { left = 0.07,  right = 0.93, top = 0.07, bottom = 0.93 } ,
        location = {
          Anchor("TOPLEFT", 5, -5, "Name", "BOTTOMLEFT")
        }
      },

      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      }
    },

    [AchievementView.Objectives] = {
      spacing = 5,

      location = {
        Anchor("TOPLEFT", 0, -5, "Header", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, -5, "Header", "BOTTOMRIGHT")
      }
    }
  },

  [AchievementListView] = {
    viewClass = AchievementView,
    indexed = false
  }
})
