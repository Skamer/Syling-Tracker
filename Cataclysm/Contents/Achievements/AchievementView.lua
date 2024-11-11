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
  FromUIProperty                      = Wow.FromUIProperty,
  ContextMenu_Show                    = API.ContextMenu_Show,
  FromBackdrop                        = Frame.FromBackdrop,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
}

__UIElement__()
class "AchievementView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    if data.objectives then 
      Style[self].Objectives.visible = true 
      local objectivesView = self:GetPropertyChild("Objectives")

      objectivesView:UpdateView(data.objectives, ...)
    end

    self.AchievementID          = data.achievementID
    self.AchievementName        = data.name
    self.AchievementDesc        = data.description
    self.AchievementIconFileID  = data.icon
  end
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local achievementID = self.AchievementID
    local contextMenuPattern = self.ContextMenuPattern

    if mouseButton == "RightButton" then 
      if achievementID and contextMenuPattern then 
        ContextMenu_Show(contextMenuPattern, self, achievementID)
      end
    end
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

  property "QuestID" {
    type = Number
  }

  property "ContextMenuPattern" {
    type = String,
    default = "achievement"
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
  function __ctor(self) 
    self.OnClick = self.OnClick + OnClickHandler
  end
end)

-- Optional Children for QuestView 
__ChildProperty__(AchievementView, "Objectives")
class(tostring(AchievementView) .. ".Objectives") { ObjectiveListView }

__UIElement__()
class "AchievementListView" { ListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("achievement.showBackground", true)
RegisterUISetting("achievement.showBorder", true)
RegisterUISetting("achievement.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("achievement.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("achievement.borderSize", 1)
RegisterUISetting("achievement.name.mediaFont", FontType("DejaVuSansCondensed Bold", 10))
RegisterUISetting("achievement.name.justifyH", "CENTER")
RegisterUISetting("achievement.name.textTransform", "NONE")
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AchievementView] = {
    height                            = 24,
    minResize                         = { width = 0, height = 24},
    autoAdjustHeight                  = true,
    registerForClicks                 = { "LeftButtonDown", "RightButtonDown" },
    backdrop                        = FromBackdrop(),
    showBackground                  = FromUISetting("achievement.showBackground"),
    showBorder                      = FromUISetting("achievement.showBorder"),
    backdropColor                   = FromUISetting("achievement.backgroundColor"),
    backdropBorderColor             = FromUISetting("achievement.borderColor"),
    borderSize                      = FromUISetting("achievement.borderSize"),
    
    Header = {
      height                          = 24,
      autoAdjustHeight                = true,
      paddingBottom                   = 5,
      Name = {
        height                        = 24,
        text                          = FromUIProperty("AchievementName"),
        justifyV                      = "MIDDLE",
        justifyH                      = FromUISetting("achievement.name.justifyH"),
        mediaFont                     = FromUISetting("achievement.name.mediaFont"),
        textTransform                 = FromUISetting("achievement.name.textTransform"),
        location                      = {
                                        Anchor("TOP", 0, -5),
                                        Anchor("LEFT", 4, 0),
                                        Anchor("RIGHT", -4, 0),
                                      }
      },

      Description = {
        text                          = FromUIProperty("AchievementDesc"),
        mediaFont                     = FontType("PT Sans Bold", 11),
        textColor                     = Color.WHITE,
        justifyH                      = "LEFT",
        justifyV                      = "TOP",
        location                      = {
                                        Anchor("TOP", 0, -5, "Name", "BOTTOM"),
                                        Anchor("LEFT", 5, 0, "Icon", "RIGHT"),
                                        Anchor("RIGHT")
                                      }
      },

      Icon = {
        fileID                        = FromUIProperty("AchievementIconFileID"),
        width                         = 32,
        height                        = 32,
        texCoords                     = { left = 0.07,  right = 0.93, top = 0.07, bottom = 0.93 } ,
        location                      = { Anchor("TOPLEFT", 5, -5, "Name", "BOTTOMLEFT") }
      },

      location                        = { Anchor("TOPLEFT"), Anchor("TOPRIGHT") }
    },

    [AchievementView.Objectives] = {
      spacing                         = 5,

      location                        = {
                                        Anchor("TOPLEFT", 0, -5, "Header", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, -5, "Header", "BOTTOMRIGHT")
                                      }
    }
  },

  [AchievementListView] = {
    viewClass                         = AchievementView,
    indexed                           = false
  }
})
