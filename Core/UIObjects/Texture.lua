-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.Texture"                      ""
-- ========================================================================= --
export {
  GetMediaAtlas = API.GetMediaAtlas
}

struct "MediaTextureType" {
  { name = "name", type = String }, -- deprecated
  { name = "type", type = String }, -- deprecated 
  { name = "atlas", type = AtlasType }, -- deprecated
  { name = "file", type = String + Number }, -- deprecated
  { name = "isMediaAtlas", type = Boolean }, -- deprecated
  { name = "texCoords", type = RectType}, -- deprecated
  { name = "color", type = ColorType }, -- deprecated
  { name = "size", type = Size}, -- deprecated

  { name = "from", type = String },
  { name = "value", type = Any}
}

__UIElement__()
class "Texture" (function(_ENV)
  inherit "Scorpio.UI.Texture"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Legacy_SetMediaTexture(self, mediaTexture)
    if not mediaTexture then 
      Style[self].file      = CLEAR
      Style[self].texCoords = CLEAR 
      Style[self].size      = CLEAR
      Style[self].atlas     = CLEAR
      Style[self].color     = CLEAR
      return 
    end

    local size

    if mediaTexture.atlas and not mediaTexture.isMediaAtlas then 
      Style[self].texCoords = CLEAR
      Style[self].color     = CLEAR
      Style[self].file      = CLEAR
      Style[self].atlas     = mediaTexture.atlas
      
      if not mediaTexture.atlas.useAtlasSize and mediaTexture.size then 
        size = mediaTexture.size 
      end
    elseif mediaTexture.atlas then 
      Style[self].color     = CLEAR
      Style[self].atlas     = CLEAR
      Style[self].texCoords = atlasInfo.texCoords or CLEAR

      local atlasInfo = GetMediaAtlas(mediaTexture.atlas.atlas)
      if atlasInfo then 
        Style[self].file = atlasInfo.file 

        if mediaTexture.atlas.useAtlasSize then 
          size = Size(atlasInfo.width, atlasInfo.height)
        end 
      end
    elseif mediaTexture.file then 
      Style[self].atlas     = CLEAR
      Style[self].color     = CLEAR
      Style[self].file      = mediaTexture.file
      Style[self].texCoords = mediaTexture.texCoords or CLEAR
      size                  = mediaTexture.size
    elseif mediaTexture.color then 
      Style[self].color     = mediaTexture.color
      Style[self].file      = CLEAR
      Style[self].atlas     = CLEAR
      Style[self].texCoords = CLEAR
    end

    Style[self].size = size or CLEAR
  end

  function SetMediaTexture(self, mediaTexture)
    -- Backward compatibilty with the old interface
    if not mediaTexture or not mediaTexture.from then 
      return self:Legacy_SetMediaTexture(mediaTexture)
    end

    local from = mediaTexture.from 
    local value = mediaTexture.value

    if value == nil then 
      value = CLEAR
    end

    if from == "atlas" then
      Style[self].atlas     = value
      Style[self].color     = CLEAR
      Style[self].file      = CLEAR
    elseif from == "file" then
      Style[self].file      = value
      Style[self].atlas     = CLEAR
      Style[self].color     = CLEAR
    elseif from == "color" then
      Style[self].color     = value
      Style[self].atlas     = CLEAR
      Style[self].file      = CLEAR
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "MediaTexture" {
    type = MediaTextureType,
    handler = function(self, mediaTexture) 
      self:SetMediaTexture(mediaTexture) 
    end 
  }
end)