-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Dungeon.ContentView"                  ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
class "DungeonContentHeader" (function(_ENV)
  inherit "ContentHeader"

  __Template__ {
    Name = SLTFontString
  }
  function __ctor(self) end
end)


__Recyclable__ "SylingTracker_DungeonContentView%d"
class "DungeonContentView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local dungeonData = data.dungeon 
    if not dungeonData then 
      return 
    end

    local name, texture, objectives = dungeonData.name, dungeonData.icon, dungeonData.objectives

    if objectives then 
      local objectivesFrame = self:AcquireObjectiveListView()
      objectivesFrame:UpdateView(objectives)
    end

    if texture then 
      local icon = self:GetChild("Icon")
      Style[icon].Icon.fileID = texture
    end

    if name then 
      local nameFrame = self:GetChild("Header"):GetChild("Name")
      Style[nameFrame].text = name 
    end
  end


  function AcquireObjectiveListView(self)
    local objectives = self:GetChild("Objectives")
    if not objectives then 
      objectives = ObjectiveListView.Acquire()

      -- We need to keep the old name when we'll release the objective list
      self.__previousObjectiveListViewName = objectives:GetName()

      objectives:SetParent(self)
      objectives:SetName("Objectives")

      if self.Objectives then 
        Style[objectives] = self.Objectives
      end

      -- Register the events
      objectives.OnSizeChanged = objectives.OnSizeChanged + self.OnObjectivesSizeChanged
    end

    return objectives
  end

  function ReleaseObjectiveListView(self)
    local objectives = self:GetChild("Objectives")
    if objectives then 
      objectives:SetName(self.__previousObjectiveListViewName)
      self.__previousObjectiveListViewName = nil 

      -- Unregister the events
      objectives.OnSizeChanged = objectives.OnSizeChanged - self.OnObjectivesSizeChanged

      objectives:Release()
      -- NOTE: If we release objective list view, this is probably the dungeon
      -- content is releasing, so it's useless to call a "AdjustHeight" as it 
      -- will be resized to 1 by default.
    end
  end 

  function OnAdjustHeight(self, useAnimation)
    local maxOuterBottom 

    for childName, child in self:GetChilds() do 
      local outerBottom = child:GetBottom() 
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
          maxOuterBottom = outerBottom
        end 
      end 
    end
    
    if maxOuterBottom then 
      local computeHeight = self:GetTop() - maxOuterBottom + self.PaddingBottom
      if useAnimation then 
        self:SetAnimatedHeight(computeHeight)
      else 
        self:SetHeight(computeHeight)
      end
      -- PixelUtil.SetHeight(self, computeHeight)
    end
  end

  function OnRelease(self)
    self:ReleaseObjectiveListView()

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
  end

  function OnAcquire(self)
    self:Show()

    self:AdjustHeight(true)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "PaddingBottom" {
    type = Number,
    default = 10
  }

  property "Objectives" {
    type = Table
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = DungeonContentHeader,
    Icon = IconBadge,
    -- Objectives = ObjectiveListView
  }
  function __ctor(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    -- local objectives = self:GetChild("Objectives")
    -- objectives.OnSizeChanged = objectives.OnSizeChanged + function()
    --   self:AdjustHeight(true)
    -- end

    self.OnObjectivesSizeChanged = function() self:AdjustHeight() end

    self:SetClipsChildren(true)
  end
end)

-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [DungeonContentHeader] = {
    Label = {
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      justifyV = "TOP",
    },

    Name = {
      sharedMediaFont = FontType("PT Sans Caption Bold", 13),
      textColor = Color(1, 233/255, 174/255),
      justifyV = "BOTTOM",
      textTransform = "UPPERCASE",
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM", 0, 2)
      }
    }
  },

  [DungeonContentView] = {
    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      -- edgeFile = [[Interface\Buttons\WHITE8X8]],
      -- edgeSize = 1
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

    Header = {
      height = 32,
      -- backdropColor = { r = 0, g = 74/255, b = 127/255, a = 0.73 },
      backdropBorderColor = { r = 0, g = 0, b = 0, a = 0 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      },

      IconBadge = {
        backdropColor = { r = 0, g = 0, b = 0, a = 0},
        Icon = {
          atlas = AtlasType("Dungeon")
        }
      },

      Label = {
        text = "Dungeon",
        sharedMediaFont = FontType("PT Sans Narrow Bold", 14),
        justifyV = "TOP"
      }
    },

    Icon = {
      width = 64,
      height = 64,
      location = {
        Anchor("TOPLEFT", 5, -5, "Header", "BOTTOMLEFT"),
      },
    },

    Objectives = {
      spacing = 10,
      location = {
        Anchor("TOP", 0, -5, "Header", "BOTTOM"),
        Anchor("LEFT", 5, 0, "Icon", "RIGHT"),
        Anchor("RIGHT"),
      }
    }
  }
})