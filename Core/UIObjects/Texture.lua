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
  { name = "name", type = String },
  { name = "type", type = String },
  { name = "atlas", type = AtlasType },
  { name = "file", type = String + Number },
  { name = "isMediaAtlas", type = Boolean },
  { name = "texCoords", type = RectType},
  { name = "color", type = ColorType },
}

__UIElement__()
class "Texture" (function(_ENV)
  inherit "Scorpio.UI.Texture"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetMediaTexture(self, mediaTexture)
    if not mediaTexture then 
      Style[self].file      = CLEAR
      Style[self].texCoords = CLEAR 
      Style[self].size      = CLEAR
      Style[self].atlas     = CLEAR
      Style[self].color     = CLEAR
      return 
    end 

    if mediaTexture.atlas and not mediaTexture.isMediaAtlas then
      if mediaTexture.atlas.useAtlasSize or not mediaTexture.size then 
        Style[self].size = CLEAR 
      else 
        Style[self].size = mediaTexture.size
      end

      Style[self].atlas     = mediaTexture.atlas 
      Style[self].texCoords = CLEAR
    elseif mediaTexture.atlas then
      local atlasInfo = GetMediaAtlas(mediaTexture.atlas.atlas)
      if atlasInfo then 
        Style[self].file = atlasInfo.file 

        if mediaTexture.atlas.useAtlasSize then 
          Style[self].size = Size(atlasInfo.width, atlasInfo.height)
        else 
          Style[self].size = CLEAR 
        end

        Style[self].texCoords = atlasInfo.texCoords or CLEAR
      end
    elseif mediaTexture.file then
      Style[self].file      = mediaTexture.file 
      Style[self].size      = mediaTexture.size or CLEAR
      Style[self].texCoords = mediaTexture.texCoords or CLEAR
    elseif mediaTexture.color then
      Style[self].color     = mediaTexture.color
      Style[self].texCoords = CLEAR
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