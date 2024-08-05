-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Contents.DelveContentView"              ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  FromUISetting                       = API.FromUISetting,
  RegisterUISetting                   = API.RegisterUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
  Tooltip                             = API.GetTooltip(),
}

__UIElement__()
class "DelveModifier" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "ModifierID" {
    type = Number
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Texture = Texture,
  }
  function __ctor(self)
    self.OnEnter = function()
      local modifierID = self.ModifierID
      if modifierID then
        Tooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        Tooltip:SetSpellByID(modifierID)
        Tooltip:Show()
      end
    end

    self.OnLeave = function() Tooltip:Hide() end
  end
end)

__UIElement__()
class "DelveContentView" (function(_ENV)
    inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if not data then 
      return
    end

    self.DelveName = data.name
    self.ReviveText = data.reviveText
    self.ReviveTextEnabledState = data.reviveTextEnabledState
    self.TierText = data.tierText
    self.TierTooltipSpellID = data.tierTooltipSpellID
    self.ShowRevives = data.showRevives
    self.HasRemainingRevives = data.hasRemainingRevives
    self.ShowReward = data.showReward
    self.HasEarnedReward = data.hasEarnedReward
    self.RewardTooltip = data.hasEarnedReward and data.earnedRewardTooltip or data.unearnedRewardTooltip
    self.ModifiersCount = data.modifiersCount

    local modifiers = self:GetChild("TopInfo"):GetChild("Modifiers")
    local modifiersData = data.modifiers
    for i = 1, 3 do 
      local modifierData = modifiersData and modifiersData[i]
      local modifier = modifiers:GetChild("Modifier" .. i)
      
      if modifierData then
        modifier.ModifierID = modifierData.modifierID
      else 
        modifier.ModifierID = nil 
      end
    end

    local objectives = self:GetChild("Objectives")
    objectives:UpdateView(data.objectives, metadata)

    local reviveTooltip = data.reviveTooltip
    if reviveTooltip then 
      local tooltipContainsHyperLink, preString, hyperLinkString, postString = ExtractHyperlinkString(reviveTooltip)
      self.ReviveTooltipHyperlinkString = hyperLinkString
      self.ReviveTooltipPostString = postString
    end
  end

  function OnExpand(self)
    Style[self].TopInfo.visible = true 
    Style[self].Objectives.visible = true
  end

  function OnCollapse(self)
    Style[self].TopInfo.visible = false  
    Style[self].Objectives.visible = false
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "DelveName" {
    type = String
  }

  __Observable__()
  property "ModifiersCount" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "ReviveText" {
    type = String
  }
  
  __Observable__()
  property "ShowRevives" {
    type = Boolean,
    default = false
  }

  __Observable__()
  property "HasRemainingRevives" {
    type = Boolean,
    default = true
  }
  
  property "ReviveTooltipHyperlinkString" {
    type = String
  }
  
  property "ReviveTooltipPostString" {
    type = String
  }

  __Observable__()
  property "TierText" {
    type = String
  }

  property "TierTooltipSpellID" {
    type = Number
  }

  __Observable__()
  property "ShowReward" {
    type = Boolean,
    default = false
  }

  property "RewardTooltip" {
    type = String
  }

  __Observable__()
  property "HasEarnedReward" {
    type = Boolean,
    default = true
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    TopInfo     = Frame,
    Objectives  = ObjectiveListView,
    {
        TopInfo = {
            DelveName   = FontString,
            Background  = Texture,
            Modifiers   = Frame,
            Reward      = Frame,
            Tier        = Frame,
            Revive      = Frame,
            {
              Modifiers = {
                Modifier1 = DelveModifier,
                Modifier2 = DelveModifier,
                Modifier3 = DelveModifier
              },
              Reward = {
                Icon = Texture
              },
              Tier = {
                Icon = Texture,
                Text = FontString
              },
              Revive = {
                Icon = Texture, 
                Text = FontString
              }
            }

        }
    }
  }
  function __ctor(self) 
    local topInfo = self:GetChild("TopInfo")
    local revive = topInfo:GetChild("Revive")
    local reward = topInfo:GetChild("Reward")
    local tier = topInfo:GetChild("Tier")

    revive.OnEnter = function()
      local hyperlink = self.ReviveTooltipHyperlinkString
      local postString = self.ReviveTooltipPostString 

      if hyperlink and postString then 
        Tooltip:SetOwner(revive, "ANCHOR_BOTTOM")
        Tooltip:SetHyperlink(hyperlink)
        
        local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB()
        Tooltip:AddLine(postString, r, g, b, true)
        Tooltip:Show()
      end
    end

    revive.OnLeave = function() Tooltip:Hide() end

    reward.OnEnter = function()
      local rewardTooltip = self.RewardTooltip
      if rewardTooltip then 
        Tooltip:SetOwner(reward, "ANCHOR_BOTTOMRIGHT")
        Tooltip:SetHyperlink(rewardTooltip)
        Tooltip:Show()
      end   
    end
    reward.OnLeave = function() Tooltip:Hide() end

    tier.OnEnter = function()
      local tierTooltipSpellID = self.TierTooltipSpellID
      if tierTooltipSpellID then 
        Tooltip:SetOwner(tier, "ANCHOR_TOPRIGHT")
        Tooltip:SetSpellByID(tierTooltipSpellID)
        Tooltip:Show()
      end
    end

    tier.OnLeave = function() Tooltip:Hide() end
  end

end)
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("delve", "content", function(generatedSettings)
  -- We ovveride the default value as we want by default the header wasn't show for 
  -- scenario
  if generatedSettings["delve.showHeader"] then 
    generatedSettings["delve.showHeader"].default = false
  end
end)

RegisterUISetting("delve.name.mediaFont", FontType("DejaVuSansCondensed Bold", 14))
RegisterUISetting("delve.name.textTransform", "NONE")
RegisterUISetting("delve.name.textColor", Color(1, 0.914, 0.682))
RegisterUISetting("delve.topInfo.showBackground", false)
RegisterUISetting("delve.topInfo.showBorder", true)
RegisterUISetting("delve.topInfo.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("delve.topInfo.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("delve.topInfo.borderSize", 1)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromTopInfoLocation()
  return FromUISetting("scenario.showHeader"):Map(function(visible)
    if visible then 
      return {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    end

    return {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
    }
  end)
end

function FromModifiersWidth(modifierWidth, spacing)
  return FromUIProperty("ModifiersCount"):Map(function(count) return modifierWidth * count + spacing * (count - 1) end)
end

function FromModifierVisible(index)
  return FromUIProperty("ModifiersCount"):Map(function(count) return count >= index end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
    [DelveModifier] = {
      height                              = 18,
      width                               = 18,

      Texture = {
        setAllPoints                      = true,
        file                              = FromUIProperty("ModifierID"):Map(function(modifierID) return modifierID and GetSpellTexture(modifierID) end),
        drawLayer                         = "BACKGROUND",
        texCoords                         = { left = 0.07,  right = 0.93, top = 0.07, bottom = 0.93 }
      },
    },

    [DelveContentView] = {
        Header = {
            visible                       = FromUISetting("scenario.showHeader"),
            showBackground                = FromUISetting("scenario.header.showBackground"),
            showBorder                    = FromUISetting("scenario.header.showBorder"),
            backdropColor                 = FromUISetting("scenario.header.backgroundColor"),
            backdropBorderColor           = FromUISetting("scenario.header.borderColor"),
            borderSize                    = FromUISetting("scenario.header.borderSize"),
      
            Label = {
              mediaFont                   = FromUISetting("scenario.header.label.mediaFont"),
              textColor                   = FromUISetting("scenario.header.label.textColor"),
              justifyH                    = FromUISetting("scenario.header.label.justifyH"),
              justifyV                    = FromUISetting("scenario.header.label.justifyV"),
              textTransform               = FromUISetting("scenario.header.label.textTransform"),
            }
        },

        TopInfo = {
          backdrop                        = FromBackdrop(),
          showBackground                  = FromUISetting("scenario.topInfo.showBackground"),
          showBorder                      = FromUISetting("scenario.topInfo.showBorder"),
          backdropColor                   = FromUISetting("scenario.topInfo.backgroundColor"),
          backdropBorderColor             = FromUISetting("scenario.topInfo.borderColor"),
          borderSize                      = FromUISetting("scenario.topInfo.borderSize"),
          height                          = 68,
          location                        = FromTopInfoLocation(),

          Background = {
            atlas                         = AtlasType("delves-scenario-frame"), -- 615222
            texCoords                     = { left = 0.1,  right = 0.9, top = 0.15, bottom = 0.85 } ,
            setAllPoints                  = true,
            drawLayer                     = "BACKGROUND",
          },

          DelveName = {
            text                          = FromUIProperty("DelveName"),
            mediaFont                     = FromUISetting("scenario.name.mediaFont"),
            textTransform                 = FromUISetting("scenario.name.textTransform"),
            textColor                     = FromUISetting("scenario.name.textColor"),
            location                      = {
                                            Anchor("LEFT", 5, 0),
                                            Anchor("TOP"),
                                            Anchor("BOTTOM", 0, 0, nil, "CENTER"),
                                            Anchor("RIGHT")
                                          }            
          },

          Tier = {
            width                         = 31,
            height                        = 35,
            
            Icon = {
              setAllPoints                = true,
              atlas                       = AtlasType("delves-scenario-flag"),
            },

            Text = {
              fontObject                  = GameFontHighlightLarge,
              text                        = FromUIProperty("TierText"),
              justifyV                    = "MIDDLE",
              justifyH                    = "CENTER",
              location                    = { Anchor("LEFT"), Anchor("RIGHT", -4, 0), Anchor("TOP", 0, 4), Anchor("BOTTOM")}
            },

            location                      = { Anchor("TOPRIGHT", -6, 5)}
          },

          Revive = {
            width                         = 61,
            height                        = 22,
            visible                       = FromUIProperty("ShowRevives"),

            Icon = {
              height                      = 22,
              width                       = 22,
              file                        = 6013778,
              location                    = { Anchor("LEFT") }
            },

            Text = {
              text                        = FromUIProperty("ReviveText"),
              textColor                   = FromUIProperty("HasRemainingRevives"):Map(function(hasRemainingRevives) return hasRemainingRevives and Color.WHITE or Color.RED end),
              fontObject                  = GameFontNormalMed3,
              justifyV                    = "MIDDLE",
              location                    = { Anchor("LEFT", 5, 0, "Icon", "RIGHT") }
            },

            location                      = { Anchor("BOTTOM", 0, 5)}
          },

          Modifiers = {
            height                        = 18,
            width                         = FromModifiersWidth(18, 8),

            Modifier1 = {
              visible                     = FromModifierVisible(1),
              location                    = { Anchor("LEFT") }
            },
            Modifier2 = {
              visible                     = FromModifierVisible(2),
              location                    = { Anchor("LEFT", 8, 0, "Modifier1", "RIGHT")}
            },
            Modifier3 = {
              visible                     = FromModifierVisible(3),
              location                    = { Anchor("LEFT", 8, 0, "Modifier2", "RIGHT")}
            },

            location                      = { Anchor("BOTTOMLEFT", 8, 9) }
          }, 

          Reward = {
            visible                       = FromUIProperty("ShowReward"),
            height                        = 20,
            width                         = 20,

            Icon = {
              setAllPoints                = true,
              atlas                       = FromUIProperty("HasEarnedReward"):Map(function(hasEarnedReward) return hasEarnedReward and AtlasType("delves-scenario-treasure-available") or AtlasType("delves-scenario-treasure-unavailable") end),
            },

            location                      = { Anchor("BOTTOMRIGHT", -12, 7)}
          }
        },

        Objectives = {
          autoAdjustHeight                = true,
          paddingTop                      = 5,
          paddingBottom                   = 5,
          backdrop                        = { 
                                            bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
                                          },
          backdropColor                   = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    
          location                        = {
                                            Anchor("TOP", 0, -5, "TopInfo", "BOTTOM"),
                                            Anchor("LEFT"),
                                            Anchor("RIGHT")
                                          }      
        },
    }
})