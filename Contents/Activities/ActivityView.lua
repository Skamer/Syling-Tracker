-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.ActivityView"                 ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop
}

__UIElement__()
class "ActivityView" (function(_ENV)
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

    self.ActivityName = data.name
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "ActivityName" {
    type = String,
    default = ""
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Name = FontString
  }
  function __ctor(self) end
end)

-- Optional Children for QuestView 
__ChildProperty__(ActivityView, "Objectives")
class(tostring(ActivityView) .. ".Objectives") { ObjectiveListView }


__UIElement__()
class "ActivityListView" { ListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ActivityView] = {
    autoAdjustHeight                  = true, 
    backdrop                          = FromBackdrop(),
    showBackground                    = true,
    showBorder                        = true,
    backdropColor                     =  Color(35/255, 40/255, 46/255, 0.73),
    backdropBorderColor               = Color(0, 0, 0, 0.4),
    borderSize                        = 1,
    
    Name = {
      text                            = FromUIProperty("ActivityName"),
      justifyV                        = "MIDDLE",
      mediaFont                       = FontType("DejaVuSansCondensed Bold", 10),
      location                        = {
                                        Anchor("TOP", 0, -5),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
    },

    [ActivityView.Objectives] = {
      spacing                         = 5,
      location                        = {
                                        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
                                      }
    }
  },

  [ActivityListView] = {
    viewClass                         = ActivityView,
    indexed                           = false
  }
})