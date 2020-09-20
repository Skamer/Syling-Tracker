-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Achievements.ContentView"               ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren = Utils.IterateFrameChildren

__Recyclable__ "SylingTracker_AchievementsContentView%d"
class "AchievementsContentView" (function(_ENV)
  inherit "Frame" extend "IView"

  function OnViewUpdate(self, data)
    if data.achievements then 
      local achievements = self:GetChild("Achievements")
      achievements:UpdateView(data.achievements)

      -- print("Check Achievement Data")
      -- print("---------------------")
      -- for k,v in pairs(data) do print(k,v) end
      -- print("-------------------------")
    end
  end

  function OnAdjustHeight(self, useAnimation)
    -- print("OnAdjustHeight","-------------------------")
    local maxOuterBottom
    for childName, child in IterateFrameChildren(self) do
      local outerBottom = child:GetBottom()
      -- print("ChildName", childName, outerBottom) 
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
          maxOuterBottom = outerBottom
        end 
      end 
    end
    
    if maxOuterBottom then 
      -- print("useAnimation", useAnimation)
      -- print("MaxOuterBottom", maxOuterBottom)
      -- print("Selft Get Top", self:GetTop())
      local computeHeight = self:GetTop() - maxOuterBottom + self.PaddingBottom
      -- print("Compute Height", computeHeight)
      -- self:SetAnimatedHeight(computeHeight)
      -- print("Compute Height", computeHeight)
      -- PixelUtil.SetHeight(self, computeHeight)
      -- self:SetHeight(computeHeight)
      if useAnimation then 
        self:SetAnimatedHeight(computeHeight)
      else 
        self:SetHeight(computeHeight)
      end
    end
    -- print("--------------------------------------------")
  end

  function OnRelease(self)
    local achievements = self:GetChild("Achievements")
    achievements.OnSizeChanged = achievements.OnSizeChanged - self.OnAchievementsSizeChanged

    -- NOTE: We send to achievements an empty table, so it will release all
    -- achievements and its objectives.
    achievements:UpdateView({})

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
  end

  function OnAcquire(self)
    self:Show()

    local achievements = self:GetChild("Achievements")
    achievements.OnSizeChanged = achievements.OnSizeChanged + self.OnAchievementsSizeChanged


    -- self:AdjustHeight(true)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "PaddingBottom" {
    type = Number,
    default = 10
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Header = ContentHeader,
    Achievements = AchievementListView
  }
  function __ctor(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    self.OnAchievementsSizeChanged = function() self:AdjustHeight(true) end
 

    self:SetClipsChildren(true)
  end
end)

Style.UpdateSkin("Default", {
  [AchievementsContentView] = {
    Header = {
      height = 32,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      },

      IconBadge = {
        backdropColor = { r = 0, g = 0, b = 0, a = 0},
        Icon = {
          file = [[Interface\ACHIEVEMENTFRAME\UI-ACHIEVEMENT-SHIELDS]],
          texCoords = { left = 0, right = 64/128, top = 0, bottom = 64/128 }
        }
      },

      Label = {
        text = "Achievements"
      }
    },
    Achievements = {
      location = {
        Anchor("TOP", 0, -5, "Header", "BOTTOM"),
        Anchor("LEFT", 4, 0),
        Anchor("RIGHT", -4, 0)
      }
    }
  }
})

function OnLoad(self)
  ac = AchievementsContentView.Acquire() 
  ac:SetParent(UIParent)
  ac:SetPoint("CENTER", 0, 200)
  ac:SetWidth(300)

  ac:UpdateView({
    achievements = {
      [150] = {
        title = "Achievement #1",
        name = "Achievement #1",
        description = [[ This is a achievement description for achievement 1]],
        objectives = {
          [1] = { text = "Fetch the achievement #1"},
          [2] = { text = "Fetch the achievement #2"},
          [3] = { text = "Fetch the achievement #3", isCompleted = true}
        }
      }
    }
  })


end 