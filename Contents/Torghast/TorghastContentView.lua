-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                        "SylingTracker.Torghast.ContentView"           ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
export {
  ValidateFlags                     = System.Toolset.validateflags,
  ResetStyles                       = Utils.ResetStyles,
  AnimaPowerRarity                  = Utils.Torghast.AnimaPowerRarity,
  GameTooltip                       = GameTooltip
}
-- ========================================================================= --
__Recyclable__ "SylingTracker_TorghastTarragrueWidget%d"
class "TorghastTarragrueWidget" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function UpdateText(self, new)
    Style[self].Label.text = new
  end

  local function UpdateTimerBarValue(self, new)
    local timerBar = self:GetChild("TimerBar")

    Style[timerBar].Text.text = SecondsToTime(new, false, true, 2, true)
    timerBar:SetValue(new)
  end

  local function UpdateTimerBarRange(self, new, old, prop)
    local timerBar = self:GetChild("TimerBar")
    if prop == "TimerBarMin" then 
      timerBar:SetMinMaxValues(new, self.TimerBarMax)
    elseif prop == "TimerBarMax" then 
      timerBar:SetMinMaxValues(self.TimerBarMin, new)
    end 
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TooltipText" { 
    type = String,
    default = ""
  }

  property "Text" {
    type = String, 
    default = "",
    handler = UpdateText
  }

  property "OverrideBarText" {
    type = String, 
    default = ""
  }

  property "TimerBarMin" {
    type = Number,
    default = 0,
    handler = UpdateTimerBarRange
  }

  property "TimerBarMax" {
    type = Number, 
    default = 0,
    handler = UpdateTimerBarRange
  }

  property "TimerBarValue" {
    type = Number,
    default = 30,
    handler = UpdateTimerBarValue
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnRelease(self)
    self:Hide()
    self:SetParent()
    self:ClearAllPoints()
  end

  function OnAcquire(self)
    self:Show()
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Label     = SLTFontString,
    TimerBar  = ProgressBar
  }
  function __ctor(self) 
    self:InstantApplyStyle()

    self.OnEnterHandler = function()
      if self.OverrideBarText ~= "" then 
        Style[self].TimerBar.Text.text = self.OverrideBarText
      end 
    end

    self.OnEnter = self.OnEnterHandler
  end

end)


__Recyclable__ "SylingTracker_TorghastContentView%d"
class "TorghastAnimaPowerView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    Style[self].IconTex.fileID = data.icon

    local rarity = data.rarity 
    if rarity then 
      local borderColor = self:GetRarityBorderColor(rarity)
      Style[self].backdropBorderColor = borderColor 
    end

    local count = data.count 
    if count and count > 1 then 
      Style[self].CountRingTex.visible = true  
      Style[self].CountFS.visible = true
      Style[self].CountFS.text = tostring(count)  
    else 
      Style[self].CountRingTex.visible = false 
      Style[self].CountFS.visible = false 
    end

    local slot = data.slot 
    if slot then 
      self.OnEnter = function() 
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetUnitAura("player", slot, "MAW")
      end
      
      self.OnLeave = function() 
        GameTooltip_Hide()
      end 
    else 
      self.OnEnter = nil 
      self.OnLeave = nil
    end
    
    local spellID = data.spellID 
    if spellID then 
      self.OnClick = function() 
        if IsModifiedClick("CHATLINK") then 
          ChatEdit_InsertLink(GetMawPowerLinkBySpellID(spellID))
        end
      end 
    else 
      self.OnClick = nil
    end 
  end

  function GetRarityBorderColor(self, rarity)
    if rarity == AnimaPowerRarity.COMMON then 
      return self.CommonBorderColor
    elseif rarity == AnimaPowerRarity.UNCOMMON then 
      return self.UncommonBorderColor
    elseif rarity == AnimaPowerRarity.RARE then 
      return self.RareBorderColor 
    elseif rarity == AnimaPowerRarity.EPIC then 
      return self.EpicBorderColor 
    end 
  end

  function OnRelease(self)
    self:Hide()
    self:SetParent()
    self:ClearAllPoints()
  end

  function OnAcquire(self)
    self:Show()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "CommonBorderColor" {
    type = ColorType,
    default = Color.COMMON
  }

  property "UncommonBorderColor" {
    type = ColorType,
    default = Color.UNCOMMON
  }

  property "RareBorderColor" {
    type = ColorType,
    default = Color.RARE 
  }

  property "EpicBorderColor" {
    type = ColorType,
    default = Color.EPIC
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    IconTex       = Texture,
    CountRingTex  = Texture,
    CountFS       = SLTFontString 
  }
  function __ctor(self)
    self:InstantApplyStyle()
  end
end)
-- ========================================================================= --
__Recyclable__ "SylingTracker_TorghastAnimaPowerListView%d"
class "TorghastAnimaPowerListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local animaPowerIndex = 0 

    wipe(self.animaPowersID)
    wipe(self.animaPowersOrder)

    for _, animaPowerData in pairs(data) do 
      tinsert(self.animaPowersOrder, animaPowerData)
      animaPowerIndex = animaPowerIndex + 1
    end
    
    table.sort(self.animaPowersOrder, function(a, b)
      if a.rarity ~= b.rarity then 
        return a.rarity > b.rarity 
      end 

      return a.spellID < b.spellID
    end)

    local previousAnimaPower
    for _, animaPowerData in ipairs(self.animaPowersOrder) do 
      local spellID = animaPowerData.spellID 
      local animaPower = self:AcquireAnimaPower(spellID)
      animaPower:UpdateView(animaPowerData)

      previousAnimaPower = animaPower 

      self.animaPowersID[spellID] = true 
    end

    self:DoGrid()
    self:ReleaseUnusedAnimaPowers()
  end
  
  function AcquireAnimaPower(self, id)
    local animaPower = self.animaPowersCache[id]
    if not animaPower then 
      animaPower = self.AnimaPowerClass.Acquire() 
      animaPower:SetParent(self)

      animaPower.OnSizeChanged = animaPower.OnSizeChanged + self.OnAnimaPowerSizeChanged

      self:AdjustHeight() 

      self.animaPowersCache[id] = animaPower
    end 

    return animaPower
  end

  function ReleaseUnusedAnimaPowers(self)
    for animaPowerID, animaPower in pairs(self.animaPowersCache) do 
      if not self.animaPowersID[animaPowerID] then 
        self.animaPowersCache[animaPowerID] = nil 

        animaPower.OnSizeChanged = animaPower.OnSizeChanged - self.OnAnimaPowerSizeChanged
        animaPower:Release()
        self:AdjustHeight()
      end
    end 
  end

  function DoGrid(self)
    local currentColumn = 0
    local currentRow    = 0
    local itemWidth     = 0
    local itemHeight    = 0
    local totalWidth    = self:GetWidth()
    local rowSize       = 0
    local numItemsByRow

    -- If the totalWidth isn't known or equal to 0, don't continue 
    -- as the grid cannot work
    if not totalWidth or totalWidth == 0 then 
      return 
    end

    -- Create a cache for retrieving the items by inde
    local itemsByIndex  = setmetatable({}, { __mode = "v"})

    for index, data in ipairs(self.animaPowersOrder) do 
      local spellID       = data.spellID
      local item          = self:AcquireAnimaPower(spellID)
      itemWidth           = item:GetWidth()
      itemHeight          = item:GetHeight()
      itemsByIndex[index] = item

      if index == 1 then 
        currentColumn = 1
        currentRow    = 1
      elseif not numItemsByRow and index > 1 then 
        currentColumn = currentColumn + 1
      else 
        currentColumn = ((index - 1) % numItemsByRow) + 1
        currentRow    = ceil(index / numItemsByRow)
      end 

      local horizontalSpacing = currentColumn > 1 and self.HorizontalSpacing or 0
      local verticalSpacing = currentRow > 1 and self.VerticalSpacing or 0

      -- Try to find the num itemsByRow
      if not numItemsByRow then
        rowSize = rowSize + itemWidth + horizontalSpacing 

        if rowSize > totalWidth then 
          -- We have found the num items by row
          numItemsByRow = currentColumn - 1
          -- We come back to column 1
          currentColumn = 1
          -- Go in the next row 
          currentRow = currentRow + 1

          -- Refetch the spacing 
          horizontalSpacing = currentColumn > 1 and self.HorizontalSpacing or 0
          verticalSpacing = currentRow > 1 and self.VerticalSpacing or 0
        end 
      end

      item:ClearAllPoints()
      if currentColumn == 1 then 
        item:SetPoint("LEFT")
        if currentRow == 1 then 
          item:SetPoint("TOPLEFT")
        else 
          item:SetPoint("TOP", itemsByIndex[index-numItemsByRow], "BOTTOM", 0, -verticalSpacing)
        end
      else 
        item:SetPoint("LEFT", itemsByIndex[index-1], "RIGHT", horizontalSpacing, 0)
      end
    end

    self:SetHeight(currentRow * itemHeight + max(0, currentRow - 1) * self.VerticalSpacing + self.PaddingBottom)
 
    self.__PreviousWidth = totalWidth
  end 

  function OnRelease(self)
    self.OnSizeChanged = self.OnSizeChanged - self.OnWidthChangedHandler

    wipe(self.animaPowersID)
    wipe(self.animaPowersOrder)
    self:ReleaseUnusedAnimaPowers()

    self:Hide()
    self:SetParent()
    self:ClearAllPoints()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
  end 

  function OnAcquire(self)
    -- Register to the "OnSizeChanged" for the grid is updated when the width
    -- has been changed
    self.OnSizeChanged = self.OnSizeChanged + self.OnWidthChangedHandler

    self:Show()
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "AnimaPowerClass" {
    type = ClassType,
    default = TorghastAnimaPowerView
  }

  property "HorizontalSpacing" {
    type = Number,
    default = 10
  }

  property "VerticalSpacing" {
    type = Number,
    default = 15
  }

  property "PaddingBottom" {
    type = Number,
    default = 15
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    -- Keep in the cache the anima powers, to be reused
    -- use: self.animaPowersCache[spellID] = animaPowerObject
    self.animaPowersCache = setmetatable({}, { __mode = "v"})

    -- Get the current anima power id's list. Used internally to release
    -- the unused anima powers 
    -- use: self.animaPowersID[spellID] = true or nil 
    self.animaPowersID = {}


    self.animaPowersOrder = {}

    self.OnAnimaPowerSizeChanged = function() self:AdjustHeight() end

    self:SetClipsChildren(true)

    self.OnWidthChangedHandler = function(_, width, height)
      if self.__PreviousWidth and self.__PreviousWidth ~= width then 
        self:DoGrid()
      end
    end
  end
end)
-- ========================================================================= --
__Recyclable__ "SylingTracker_TorghastContentView%d"
class "TorghastContentView" (function(_ENV)
  inherit "ContentView"

  __Flags__()
  enum "Flags" {
    NONE                  = 0,
    HAS_ANIMA_POWERS      = 1,
    HAS_TARRUGRUE_WIDGET  = 2
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local torghastData = data.torghast
    if not torghastData then 
      return 
    end

    -- Get the elements
    local contentFrame        = self:GetChild("Content")
    local topInfoFrame        = contentFrame:GetChild("TopInfo")
    local levelTextBadge      = topInfoFrame:GetChild("Level")
    local fanstasmFrame       = topInfoFrame:GetChild("Fanstasm")
    local fanstasmTextFS      = fanstasmFrame:GetChild("TextFS")
    local remainingDeathFrame = topInfoFrame:GetChild("RemainingDeath")
    local remainingDeathFS    = remainingDeathFrame:GetChild("TextFS")
    
    -- Determine the flags 
    local flags = Flags.NONE
    
    local numAnimaPowers = torghastData.numAnimaPowers

    if numAnimaPowers and numAnimaPowers > 0 then 
      flags = flags + Flags.HAS_ANIMA_POWERS
    end

    local tarragrueData = torghastData.tarragrue 
    if tarragrueData then 
      flags = flags + Flags.HAS_TARRUGRUE_WIDGET
    end

    if flags ~= self.Flags then 
      ResetStyles(self)

      -- Is there anima powers 
      if ValidateFlags(Flags.HAS_ANIMA_POWERS, flags) then
        self:AcquireAnimaPowers()
      else
        self:ReleaseAnimaPowers()
      end

      -- Is there the tarragrue widget
      if ValidateFlags(Flags.HAS_TARRUGRUE_WIDGET, flags) then
        self:AcquireTarragrueWidget()
      else
        self:ReleaseTarragrueWidget()
      end

      -- Styling stuff
      if flags ~= Flags.NONE then 
        local styles = self.FlagsStyles and self.FlagsStyles[flags]
        if styles then 
          Style[self] = styles 
        end 
      end 
    end


    -- Update level 
    local levelText = torghastData.levelText
    if levelText then 
      Style[levelTextBadge].Label.text = levelText
    end

    -- Update the level tooltip 
    local stageName        = torghastData.stageName
    local stageDescription = torghastData.stageDescription
    if stageName and stageDescription then 
      levelTextBadge.OnEnter = function()
        GameTooltip:SetOwner(levelTextBadge, "ANCHOR_NONE")
        GameTooltip:SetPoint("RIGHT", levelTextBadge, "LEFT")
        GameTooltip:SetText(stageName, 1, 0.914, 0.682, 1)
        GameTooltip:AddLine(stageDescription, 1, 1, 1, true)
        GameTooltip:Show()
      end 
      levelTextBadge.OnLeave = function() GameTooltip_Hide() end 
    else 
      levelTextBadge.OnLeave = nil 
      levelTextBadge.OnEnter = nil
    end 

    -- Update the fantasm currency 
    local fanstasm = torghastData.fanstasm
    if fanstasm then
      Style[fanstasmTextFS].text = tostring(fanstasm)
    end

    -- Update the fanstasm tooltilp 
    local fanstasmTooltip = torghastData.fanstasmTooltip
    if fanstasmTooltip then 
      fanstasmFrame.OnEnter = function()
         GameTooltip:SetOwner(fanstasmFrame, "ANCHOR_BOTTOMLEFT")
         GameTooltip_ShowHyperlink(GameTooltip, fanstasmTooltip, 0, 0, true)
      end 

      fanstasmFrame.OnLeave = function()
        GameTooltip_Hide()
      end 
    else 
      fanstasmFrame.OnEnter = nil 
      fanstasmFrame.OnLeave = nil 
    end 
    
    -- Update the remaining death 
    local remainingDeath = torghastData.remainingDeath
    if remainingDeath then 
      Style[remainingDeathFS].text = tostring(remainingDeath)
    end

    -- Update the remaining death tooltip 
    local deathTooltip = torghastData.deathTooltip 
    if deathTooltip then 
      remainingDeathFrame.OnEnter = function() 
        GameTooltip:SetOwner(remainingDeathFrame, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText(deathTooltip)
        GameTooltip:Show()
      end

      remainingDeathFrame.OnLeave = function() GameTooltip_Hide() end 
    else 
      remainingDeathFrame.OnEnter = nil 
      remainingDeathFrame.OnLeave = nil
    end

    -- Update the num animas
    if numAnimaPowers then 
      Style[contentFrame].AnimaPowerCountFS.text = JAILERS_TOWER_BUFFS_BUTTON_TEXT:format(numAnimaPowers)
    end

    -- Update the anima powers if exists 
    if numAnimaPowers and numAnimaPowers > 0 then 
      local animaPowersView = self:AcquireAnimaPowers() 
      local animaPowersData = torghastData.animaPowers

      animaPowersView:UpdateView(animaPowersData)
    end

    -- Update the tarragrue widget if exists 
    if tarragrueData then 
      local tarragrueWidget = self:AcquireTarragrueWidget() 
      tarragrueWidget.Text = tarragrueData.text 
      tarragrueWidget.TooltipText = tarragrueData.tooltip
      tarragrueWidget.OverrideBarText = tarragrueData.overrideBarText
      tarragrueWidget.TimerBarMin = tarragrueData.barMin 
      tarragrueWidget.TimerBarMax = tarragrueData.barMax
      tarragrueWidget.TimerBarValue = tarragrueData.barValue
    end 
    
    -- Don't forget to set the new flag for avoiding "Flashy" behaviors
    self.Flags = flags
  end

  function AcquireTarragrueWidget(self)
    local content = self:GetChild("Content")
    local tarragrueWidget = content:GetChild("TarragrueWidget")

    if not tarragrueWidget then 
      tarragrueWidget = self.TarragrueWidgetClass.Acquire()

      -- We need to keep the old when we'll release it 
      self.__PreviousTarragrueWidgetName = tarragrueWidget:GetName() 

      tarragrueWidget:SetParent(content)
      tarragrueWidget:SetName("TarragrueWidget")
      tarragrueWidget:InstantApplyStyle() 

      tarragrueWidget.OnSizeChanged = tarragrueWidget.OnSizeChanged + self.OnAnimaPowersChanged

      self:AdjustHeight(true)
    end
    
    return tarragrueWidget
  end

  function ReleaseTarragrueWidget(self)
    local content = self:GetChild("Content")
    local tarragrueWidget = content:GetChild("TarragrueWidget")

    if tarragrueWidget then 
      -- Give its old name (generated by the recycle system)
      tarragrueWidget:SetName(self.__PreviousTarragrueWidgetName)
      self.__PreviousTarragrueWidgetName = nil 

      -- Unregister the events 
      tarragrueWidget.OnSizeChanged = tarragrueWidget.OnSizeChanged - self.OnAnimaPowersChanged

      -- It's better to release after events have been unregistered for avoiding 
      -- useless calls 
      tarragrueWidget:Release()

      self:AdjustHeight(true)
    end
  end

  function AcquireAnimaPowers(self)
    local content = self:GetChild("Content")
    local animaPowers = content:GetChild("AnimaPowers")

    if not animaPowers then 
      animaPowers = self.AnimaPowersClass.Acquire()

      -- We need to keep the old name when we'll release it
      self.__PreviousAnimaPowersName = animaPowers:GetName()

      animaPowers:SetParent(content)
      animaPowers:SetName("AnimaPowers")
      animaPowers:InstantApplyStyle()

      animaPowers.OnSizeChanged = animaPowers.OnSizeChanged + self.OnAnimaPowersChanged

      self:AdjustHeight(true)
    end

    return animaPowers
  end

  function ReleaseAnimaPowers(self)
    local content = self:GetChild("Content")
    local animaPowers = content:GetChild("AnimaPowers")

    if animaPowers then 
      -- Give its old name (generated by the recycle system)
      animaPowers:SetName(self.__PreviousAnimaPowersName)
      self.__PreviousAnimaPowersName = nil 

      -- Unregister the events 
      animaPowers.OnSizeChanged = animaPowers.OnSizeChanged - self.OnAnimaPowersChanged

      -- It's better to release after events have been unregistered for avoiding 
      -- useless calls 
      animaPowers:Release()

      self:AdjustHeight(true)
    end
  end

  function OnRelease(self)
    -- First, release the children 
    self:ReleaseAnimaPowers()

    -- We call the "Parent" OnRelease (see ContentView class)
    super.OnRelease(self)

    -- Reset the class properties 
    self.Flags = nil 
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Flags" {
    type    = TorghastContentView.Flags,
    default = TorghastContentView.Flags.NONE 
  }

  property "AnimaPowersClass" {
    type    = ClassType,
    default = TorghastAnimaPowerListView
  }

  property "TarragrueWidgetClass" {
    type    = ClassType,
    default = TorghastTarragrueWidget
  }

  property "FlagsStyles" {
    type    = Table 
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    {
      Content = {
        TopInfo           = Frame,
        Separator         = Texture,
        AnimaPowerCountFS = SLTFontString,
        Separator         = Texture,
        {
          TopInfo = {
            Level           = TextBadge,
            Fanstasm        = Frame,
            RemainingDeath  = Frame,
            {

              Fanstasm = {
                IconTex     = Texture,
                TextFS      = SLTFontString
              },
              RemainingDeath = {
                IconTex     = Texture,
                TextFS      = SLTFontString
              }
            }
          }
        }
      }
    }
  }
  function __ctor(self)
    self:InstantApplyStyle()

    self.OnAnimaPowersChanged = function() self:AdjustHeight(true) end
  end
end)
-- ========================================================================= --
--                                Styles                                     --
-- ========================================================================= --
Style.UpdateSkin("Default", {
  [TorghastTarragrueWidget] = {
    height = 50,

    Label = {
      --text = "Tarragrue arrives in:",
      -- height = 24,
      textColor = Color(0.9, 0, 0),
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    TimerBar = {
      location = {
        Anchor("TOP", 0, -3, "Label", "BOTTOM"),
        Anchor("LEFT", 5, 0),
        Anchor("RIGHT", -5, 0)
      }
    }
  },

  [TorghastAnimaPowerView] = {
    width = 32,
    height = 32,
    RegisterForClicks = { "AnyUp"},

    backdrop = {
      edgeFile  = [[Interface\Buttons\WHITE8X8]],
      edgeSize  = 1    
    },

    IconTex = {
      location = {
        Anchor("TOPLEFT", 1, -1),
        Anchor("BOTTOMRIGHT", -1, 1)
      },
      texCoords = RectType(0.07, 0.93, 0.07, 0.93)
    },

    CountRingTex = {
      atlas = AtlasType("jailerstower-animapowerlist-rank", true),
      location = {
        Anchor("CENTER", 0, 0, "IconTex", "BOTTOM")
      }
    },

    CountFS = {
      location  = {
        Anchor("CENTER", 0, 0, "CountRingTex", "CENTER")
      }
    }
  },

  [TorghastContentView] = {
    Header = {
      IconBadge = {
        Icon = {
          atlas = AtlasType("poi-torghast")
        }
      },
      Label = {
        text = "Torghast"
      }
    },

    Content = {
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      },
      backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      TopInfo = {
        height = 28,
        backdrop = {
          bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
        },

        backdropColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.7},
        location = {
          Anchor("TOP"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        },

        Level = {
          height  = 24,
          width   = 65, 
          location = {
            Anchor("TOP"),
            Anchor("LEFT", 5, 0)
          },

          Label = {
            sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
            textTransform   = "UPPERCASE",
            textColor = Color(0.9, 0.9, 0.9),
          },          
        },

        Fanstasm = {
          height = 24,
          width = 60,
          location = {
            Anchor("TOP")
          },

          IconTex = {
            height = 16,
            width = 16,
            fileID = 3743737,
            texCoords = RectType(0.07, 0.93, 0.07, 0.93),
            location = {
              Anchor("LEFT")
            }
          },

          TextFS = {
            sharedMediaFont = FontType("PT Sans Caption Bold", 11),
            justifyH = "LEFT",
            location = {
              Anchor("LEFT", 5, 0, "IconTex", "RIGHT"),
              Anchor("RIGHT")
            }
          }
        },

        RemainingDeath = {
          height = 24,
          width  = 50,
          location = {
            Anchor("TOP"),
            Anchor("RIGHT", -5, 0)
          },

          IconTex = {
            height = 16,
            width  = 16,
            fileID = 3450602,

            location = {
              Anchor("LEFT")
            }
          },

          TextFS = {
            sharedMediaFont = FontType("PT Sans Caption Bold", 11),
            justifyH = "LEFT",
            location = {
              Anchor("LEFT", 5, 0, "IconTex", "RIGHT"),
              Anchor("RIGHT")
            }
          }
        }
      },
      AnimaPowerCountFS = {
        textColor = Color(0.9, 0.9, 0.9),
        sharedMediaFont = FontType("PT Sans Caption Bold", 12),
        justifyH = "CENTER",
        location = {
          Anchor("TOP", 0, -5, "TopInfo", "BOTTOM"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        }
      },
      Separator = {
        height = 2,

        color = { r = 1, g = 1, b = 1, a = 0.15 },
        location = {
          Anchor("TOP", 0, -5, "AnimaPowerCountFS", "BOTTOM"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        }
      },
    },
    FlagsStyles = {
      [TorghastContentView.Flags.HAS_ANIMA_POWERS] = {
        Content = {
          AnimaPowers = {
            location = {
              Anchor("TOP", 0, -5, "Separator", "BOTTOM"),
              Anchor("LEFT", 5, 0),
              Anchor("RIGHT", -5, 0)
            }
          }
        }
      },
      [TorghastContentView.Flags.HAS_ANIMA_POWERS + TorghastContentView.Flags.HAS_TARRUGRUE_WIDGET] = {
        Content = {
          AnimaPowers = {
            location = {
              Anchor("TOP", 0, -5, "Separator", "BOTTOM"),
              Anchor("LEFT", 5, 0),
              Anchor("RIGHT", -5, 0)
            }
          },

          TarragrueWidget = {
            location = {
              Anchor("TOP", 0, -5, "AnimaPowers", "BOTTOM"),
              Anchor("LEFT", 5, 0),
              Anchor("RIGHT", -5, 0)
            }
          }
        }
      }
    }
  }
})