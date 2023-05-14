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

__UIElement__()
class "Texture" (function(_ENV)
  inherit "Scorpio.UI.Texture"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetMediaAtlas(self, atlas)
    if atlas then 
      local atlasInfo = GetMediaAtlas(atlas.atlas)
      if atlasInfo then
        Style[self].file = atlasInfo.file 
        
        if atlas.useAtlasSize then
          Style[self].size = Size(atlasInfo.width, atlasInfo.height)
        end

        Style[self].texCoords = atlasInfo.texCoords
      end
    else
      Style[self].file      = nil 
      Style[self].size      = nil 
      Style[self].texCoords = nil 
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "MediaAtlas" {
    type    = AtlasType,
    handler = function(self, atlas) self:SetMediaAtlas(atlas) end
  }
end)