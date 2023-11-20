-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.UI.POIButton"                      ""
-- ========================================================================= --
export {
  IsLegendaryQuest                    = C_QuestLog.IsLegendaryQuest,
  GetThreatPOIIcon                    = QuestUtil.GetThreatPOIIcon,
  SetSuperTrackedQuestID              = C_SuperTrack.SetSuperTrackedQuestID,
  GetSuperTrackedQuestID              = C_SuperTrack.GetSuperTrackedQuestID,
}

-- POI text colors (offsets into texture)
local IconsPerRow = 8;
local IconCoordSize = 0.125;
local POIButtonColorBlackCoord = 0;
local POIButtonColorYellowCoord = 0.5;

local function POIButton_CalculateNumericTexCoords(index, color)
	if index then
		color = color or POIButtonColorYellowCoord;
		local iconIndex = index - 1;
		local yOffset = color + floor(iconIndex / IconsPerRow) * IconCoordSize;
		local xOffset = mod(iconIndex, IconsPerRow) * IconCoordSize;
		return xOffset, xOffset + IconCoordSize, yOffset, yOffset + IconCoordSize;
	end
end

local CONTENT_TRACKING_MEDIA_TEXTURE = { atlas = AtlasType("waypoint-mappin-minimap-untracked")}
local CONTENT_TRACKING_SELECTED_MEDIA_TEXTURE = { atlas =AtlasType("waypoint-mappin-minimap-tracked") }

local NORMAL_MEDIA_TEXTURE = { 
  file =  [[Interface/WorldMap/UI-QuestPoi-NumberIcons]],
  texCoords = { left = 0.5, right = 0.625, top = 0.875, bottom = 1.0 }
}

local NORMAL_SELECTED_MEDIA_TEXTURE = {
  file =  [[Interface/WorldMap/UI-QuestPoi-NumberIcons]],
  texCoords = { left = 0.5, right = 0.625, top = 0.375, bottom = 0.5 }
}


local PUSHED_MEDIA_TEXTURE = {
  file = [[Interface/WorldMap/UI-QuestPoi-NumberIcons]],
  texCoords = { left = 0.375, right = 0.500, top = 0.875, bottom = 1.0 }
}

local PUSHED_SELECTED_MEDIA_TEXTURE = {
  file = [[Interface/WorldMap/UI-QuestPoi-NumberIcons]],
  texCoords = { left = 0.375, right = 0.500, top = 0.375, bottom = 0.5 }
}

local CAMPAIGN_NORMAL_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiCampaign-QuestNumber")}
local CAMPAIGN_NORMAL_SELECTED_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiCampaign-QuestNumber-SuperTracked")}
local CAMPAIGN_PUSHED_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiCampaign-QuestNumber-Pressed")}
local CAMPAIGN_PUSHED_SELECTED_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiCampaign-QuestNumber-Pressed-SuperTracked")}


local IMPORTANT_NORMAL_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiCampaign-QuestNumber") }
local IMPORTANT_NORMAL_SELECTED_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiCampaign-QuestNumber-SuperTracked")}
local IMPORTANT_PUSHED_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiImportant-QuestNumber-Pressed") }
local IMPORTANT_PUSHED_SELECTED_MEDIA_TEXTURE = { atlas = AtlasType("UI-QuestPoiImportant-QuestNumber-Pressed-SuperTracked")}


__UIElement__()
class "POIButton" (function(_ENV)  
  inherit "Button"

  enum "Style" {
    Waypoint        = 1,
    Numeric         = 2,
    QuestComplete   = 3,
    QuestDisabled   = 4,
    QuestThreat     = 5,
    ContentTracking = 6
  }

  enum "QuestType" {
    Normal    = 1,
    Campaign  = 2,
    Calling   = 3,
    Important = 4
  }
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self)
    local questID = self.QuestID 
    if questID then
      SetSuperTrackedQuestID(questID)
    end
  end
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  __Arguments__ { Number }
  function SetNumber(self, number)
    self.Number = number
  end
  
  __Arguments__ { Style }
  function SetStyle(self, style)
    self.Style = style
  end

  __Arguments__ { QuestType }
  function SetQuestType(self, questType)
    self.QuestType = questType
  end

  __Arguments__ { Number }
  function SetQuestID(self, questID)
    self.QuestID = questID
  end

  __Arguments__ { Boolean}
  function SetSelected(self, selected)
    self.Selected = selected
  end

  function OnSystemEvent(self, event, questID)
    local questID = self.QuestID
    if questID then 
      self:SetSelected(questID == GetSuperTrackedQuestID())
    end
  end

  function OnAcquire(self)
    self:RegisterSystemEvent("SUPER_TRACKING_CHANGED")
  end

  function OnRelease(self)
    self:UnregisterSystemEvent("SUPER_TRACKING_CHANGED")
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "Style" {
    type = Style,
    default = Style.Numeric
  }

  __Observable__()
  property "QuestType" {
    type = QuestType,
    default = QuestType.Normal
  }

  __Observable__()
  property "Selected" {
    type = Boolean,
    default = false
  }

  __Observable__()
  property "Number" {
    type = Number,
    default = 1
  }

  __Observable__()
  property "QuestID" {
    type = Number,
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__{
    Display = Texture
  }
  function __ctor(self)
    self.OnClick = self.OnClick + OnClickHandler
  end
end)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromDisplayMediaTexture()
  return Wow.FromUIProperty("Style", "QuestType", "Number", "QuestID", "Selected")
    :Next()
    :Map(function(style, questType, number, questID, selected)
      if style == POIButton.Style.Numeric then
        local color = selected and POIButtonColorBlackCoord or POIButtonColorYellowCoord
        local texLeft, texRight, texTop, texBottom = POIButton_CalculateNumericTexCoords(number, color)
        return {
          file = [[Interface/WorldMap/UI-QuestPoi-NumberIcons]],
          texCoords = { left = texLeft, right = texRight, top = texTop, bottom = texBottom},
          size = { width = 32, height = 32}
        }
      elseif style == POIButton.Style.ContentTracking then 
        return
      elseif style == POIButton.Style.Waypoint then
        return { atlas = AtlasType("poi-traveldirections-arrow"), size = { width = 13, height = 17 } } 
      elseif style == POIButton.Style.QuestDisabled then
        return { atlas = AtlasType("QuestSharing-QuestLog-Padlock"), size = { width = 24, height = 29 }} 
      elseif style == POIButton.Style.QuestThreat then
        local iconAtlas = GetThreatPOIIcon(questID)
        return { atlas = AtlasType(iconAtlas), size = { width = 18, height = 18}}
      end

      if not questType or questType == POIButton.QuestType.Normal then
        local isLegendaryQuest = questID and IsLegendaryQuest(questID) or false

        return isLegendaryQuest and {
          atlas = AtlasType("UI-QuestPoiLegendary-QuestBangTurnIn"),
          size = { width = 24, height = 24}
        } or {
          atlas = AtlasType("UI-QuestIcon-TurnIn-Normal"),
          size = { width = 24, height = 24}
        }
      end 

     if questType == POIButton.QuestType.Campaign then 
        return { atlas = AtlasType("UI-QuestPoiCampaign-QuestBangTurnIn"), size = { width = 32, height = 32 }}
      elseif questType == POIButton.QuestType.Calling then 
        return { atlas = AtlasType("UI-DailyQuestPoiCampaign-QuestBangTurnIn"), size = { width = 32, height = 32}}
      elseif questType == POIButton.QuestType.Important then 
        return { atlas = AtlasType("UI-QuestPoiImportant-QuestBangTurnIn"), size = { width = 32, height = 36}}
      end

      -- return { file = [[Interface/WorldMap/UI-QuestPoi-NumberIcons]] }
    end)
end

function FromNormalMediaTexture()
  return Wow.FromUIProperty("Style", "QuestType", "Selected")
    :Next()
    :Map(function(style, questType, selected)
      -- Numeric Style
      if style == POIButton.Style.Numeric then 
        if questType == POIButton.QuestType.Campaign or questType == POIButton.QuestType.Calling then
          return selected and CAMPAIGN_NORMAL_SELECTED_MEDIA_TEXTURE or CAMPAIGN_NORMAL_MEDIA_TEXTURE
        elseif questType == POIButton.QuestType.Important then 
          return selected and IMPORTANT_NORMAL_SELECTED_MEDIA_TEXTURE or IMPORTANT_NORMAL_MEDIA_TEXTURE
        else
           return selected and NORMAL_SELECTED_MEDIA_TEXTURE or NORMAL_MEDIA_TEXTURE
        end
      elseif style == POIButton.Style.ContentTracking then
        return selected and CONTENT_TRACKING_SELECTED_MEDIA_TEXTURE or CONTENT_TRACKING_MEDIA_TEXTURE
      end 

      if not questType or questType == POIButton.QuestType.Normal then
        return selected and NORMAL_SELECTED_MEDIA_TEXTURE or NORMAL_MEDIA_TEXTURE
      elseif questType == POIButton.QuestType.Important then 
        return selected and IMPORTANT_NORMAL_SELECTED_MEDIA_TEXTURE or IMPORTANT_NORMAL_MEDIA_TEXTURE
      else 
        return selected and CAMPAIGN_NORMAL_SELECTED_MEDIA_TEXTURE or CAMPAIGN_NORMAL_MEDIA_TEXTURE
      end
    end)
end

function FromPushedMediaTexture()
  return Wow.FromUIProperty("Style", "QuestType", "Selected")
    :Next()
    :Map(function(style, questType, selected)
      -- Numeric Style
      if style == POIButton.Style.Numeric then 
        if questType == POIButton.QuestType.Campaign or questType == POIButton.QuestType.Calling then
          return selected and CAMPAIGN_PUSHED_SELECTED_MEDIA_TEXTURE or CAMPAIGN_PUSHED_MEDIA_TEXTURE
        elseif questType == POIButton.QuestType.Important then 
          return selected and IMPORTANT_PUSHED_SELECTED_MEDIA_TEXTURE or IMPORTANT_PUSHED_MEDIA_TEXTURE
        else
           return selected and PUSHED_SELECTED_MEDIA_TEXTURE or PUSHED_MEDIA_TEXTURE
        end
      elseif style == POIButton.Style.ContentTracking then
        return selected and CONTENT_TRACKING_SELECTED_MEDIA_TEXTURE or CONTENT_TRACKING_MEDIA_TEXTURE
      end 

      if not questType or questType == POIButton.QuestType.Normal then
        return selected and PUSHED_SELECTED_MEDIA_TEXTURE or PUSHED_MEDIA_TEXTURE
      elseif questType == POIButton.QuestType.Important then 
        return selected and IMPORTANT_PUSHED_SELECTED_MEDIA_TEXTURE or IMPORTANT_PUSHED_MEDIA_TEXTURE
      else 
        return selected and CAMPAIGN_PUSHED_SELECTED_MEDIA_TEXTURE or CAMPAIGN_PUSHED_SELECTED_MEDIA_TEXTURE
      end
    end)
end

function FromAlpha()
  return Wow.FromUIProperty("Style"):Map(function(style)
    if style == POIButton.Style.QuestDisabled then 
      return 0
    end

    return 1
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [POIButton] = {
    width                             = 28,
    height                            = 28,

    Display = {
      width                           = 32,
      height                          = 32,
      sublevel                        = 1,
      mediaTexture                    = FromDisplayMediaTexture(),
      location                        = { Anchor("CENTER") }
    },

    NormalTexture = {
      mediaTexture                    = FromNormalMediaTexture(),
      alpha                           = FromAlpha(),
    },

    PushedTexture = {
      mediaTexture                    = FromPushedMediaTexture(),
      alpha                           = FromAlpha()
    }   
  }
})
