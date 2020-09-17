-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio            "SylingTracker.Quests.QuestCategoryView"                  ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren = Utils.IterateFrameChildren

class "QuestCategoryView" (function(_ENV)
  inherit "Frame" extend "IView"

  _Recycler = Recycle(QuestCategoryView, "SylingTracker_QuestCategoryView%d")
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, updater)
    local name
    for _, v in pairs(data) do 
      name = v.category
      break;
    end

    local textFrame = self:GetChild("Name")
    textFrame:SetText(name)

    local questsView = self:GetChild("Quests")
    questsView:Update(data)
  end

  function OnAdjustHeight(self)
    local height = 0
    local maxOuterBottom 

    for childName, child in IterateFrameChildren(self) do 
      local outerBottom = child:GetBottom() 
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
          maxOuterBottom = outerBottom
        end 
      end 
    end
    
    if maxOuterBottom then 
      local computeHeight = self:GetTop() - maxOuterBottom
      PixelUtil.SetHeight(self, computeHeight)
    end
  end
  --- Recycle System
  function Recycle(self)
    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:CancelAdjustHeight()

    self:SetHeight(1)

    _Recycler(self)
  end

  __Static__()
  function Acquire()
    local obj = _Recycler()
    obj:Show()

    return obj
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Name  = SLTFontString,
    Quests = QuestListView
  }
  function __ctor(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    local questsView = self:GetChild("Quests")
    questsView.OnSizeChanged = questsView.OnSizeChanged + function()
      self:AdjustHeight()
    end 
  end 
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestCategoryView] = {
    width   = 150,
    -- backdrop = { bgFile = [[Interface\Buttons\WHITE8X8]] },
    -- backdropColor = ColorType(1, 0, 0, 0.25), -- 0 0 0 0.5

    Name = {
      location = {
        Anchor("TOPLEFT", 20, 0),
        Anchor("TOPRIGHT")
      },
      justifyH = "LEFT",
      font = FontType([[Interface\AddOns\EskaTracker2\Media\Fonts\PTSans-Narrow-Bold.ttf]], 12),
      textColor = Color(1, 0.38, 0),
      textTransform = "UPPERCASE",


    },

    Quests = {
      location = {
        Anchor("TOP", 0, -10, "Name", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})