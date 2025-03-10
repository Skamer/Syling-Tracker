-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Core.DataProperties"                    ""
-- ========================================================================= --
import "System.Serialization"


function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

class "__DataProperties__" (function(_ENV)
  extend "IApplyAttribute"

  function ApplyAttribute(self, target, targetType, manager, owner, name, stack)
    if not Class.IsSubType(target, IObjectData) then 
      return 
    end

    for _, attributeInfo in ipairs(self) do 
      local propertyName = attributeInfo.name 
      local propertyType = attributeInfo.type 
      local propertyDefault = attributeInfo.default
      local isMap = attributeInfo.isMap
      local isArray = attributeInfo.isArray
      local singularName = attributeInfo.singleName or attributeInfo.singularName or propertyName
      local pluralName = attributeInfo.pluralName or propertyName
      local methodSingularPart = firstToUpper(singularName)
      local methodPluralPart = firstToUpper(pluralName)
      local collectionIndex = "__" .. propertyName
      local collectionCounter = 0

      local function PropertyTableGetFunction(self, idx)
        return self[collectionIndex] and self[collectionIndex][idx]
      end
    
      local function PropertyTableSetFunction(self, idx, value)
        local collection = self[collectionIndex]
    
        if value == nil and not collection then 
          return
        end
    
        if value and not collection then 
          collection = isArray and Array[propertyType]() or {}
          self[collectionIndex] = collection
        end
    
        local oldValue = collection[idx]
        collection[idx] = value 
    
        if oldValue ~= value then 
          self.DataChanged = true
    
          if Class.IsObjectType(oldValue, IObjectData) then
            oldValue:SetParent(nil)
          end
    
          if Class.IsObjectType(value, IObjectData) then 
            value:SetParent(self)
          end
        end
    
        if recycle and value == nil and oldValue and oldValue.Release then 
          oldValue:Release()
        end
      end

      -- Generate Properties
      Environment.Apply(manager, function(_ENV)
        if isArray or isMap then 
          if isArray then 
            __Indexer__(Number)
            property(propertyName) {
              type  = propertyType,
              get   = PropertyTableGetFunction,
              set   = PropertyTableSetFunction
            }
          else 
            __Indexer__(Any)
            property(propertyName) {
              type  = propertyType,
              get   = PropertyTableGetFunction,
              set   = PropertyTableSetFunction
            }    
          end
        else
          if Class.IsSubType(propertyType, IObjectData) then
            property(propertyName) {
              type = propertyType,
              get = function(self)
                local value = self[collectionIndex]
                if not value then 
                  value = propertyType()
                  value:SetParent(self)
                  self[collectionIndex] = value
                end
                return value
              end,
              set = function(self, value)
                if value == nil then
                  local oldValue = self[collectionIndex]
                  if oldValue then 
                    oldValue:SetParent(nil)
                    self.DataChanged = true
                    self[collectionIndex] = nil
                  end
                end
              end
            }

          else
            property(propertyName) { 
              type = propertyType, 
              default = propertyDefault, 
              handler = function(self) self.DataChanged = true end
            }
          end
        end
      end)


      -- Generate methods 
      Environment.Apply(manager, function(_ENV)
        target["Acquire"..methodSingularPart] = function(self, key)
          if isArray and key == nil then
            collectionCounter = collectionCounter + 1
            key = collectionCounter
          end
          
          local obj = self[propertyName][key]
          if not obj then 
            obj = propertyType()
            self[propertyName][key] = obj 
          end

          return obj
        end

        target["Set"..methodPluralPart.."Count"] = function(self, count) end

        if isMap or isArray then 
          target["Iterate"..methodPluralPart] = function(self)
            if isMap then 
              return pairs(self[collectionIndex])
            elseif isArray then 
              return self[collectionIndex] and self[collectionIndex]:GetIterator()
            end
          end

          target["Clear"..methodPluralPart] = function(self)
            if not self[collectionIndex] then 
              return 
            end

            local iterator = self.isMap and pairs(self[collectionIndex]) or self[collectionIndex]:GetIterator()

            for k in iterator() do 
              self[propertyName][k] = nil
            end
          end

          if isArray then
            target["Start"..methodPluralPart.."Counter"] = function(self)
              collectionCounter = 0
            end

            target["Stop"..methodPluralPart.."Counter"] = function(self)
              local collection = self[collectionIndex]
              if not collection then 
                return 
              end

              local oldCount = self[collectionIndex].Count
              
              if oldCount == collectionCounter then 
                return 
              end
              
              for i = 1, oldCount do 
                if i > collectionCounter then 
                  collection[i] = nil 
                end
              end
            end
          end
        end
      end)
    end
  end

  function AttachAttribute(self, target, targetType, owner, name, stack)
    if not Class.IsSubType(target, IObjectData) then 
      return 
    end


    Attribute.IndependentCall(function()
      
      __Serializable__()
      class(target) (function(_ENV)
        extend(ISerializable)

        function Serialize(obj, info)
          for _, attributeInfo in ipairs(self) do
            local propertyName = attributeInfo.name 
            local propertyType = attributeInfo.type 
            local propertyDefault = attributeInfo.default
            local isMap = attributeInfo.isMap
            local isArray = attributeInfo.isArray
            local collectionIndex = "__" .. propertyName

            if isArray then
              if obj[collectionIndex] and obj[collectionIndex].Count > 0  then 
                info:SetValue(propertyName, obj[collectionIndex], Array[propertyType])
              end
            elseif isMap then
              if obj[collectionIndex] and next(obj[collectionIndex]) ~= nil then 
                info:SetValue(propertyName, obj[collectionIndex], Table)
              end
            else
              if Class.IsSubType(propertyType, IObjectData) then 
                info:SetValue(propertyName, obj[collectionIndex], propertyType)
              else 
                info:SetValue(propertyName, obj[propertyName], propertyType)
              end
            end
          end
        end

        function ResetDataProperties(obj, info)
          for _, attributeInfo in ipairs(self) do 
            local propertyName = attributeInfo.name 
            local propertyType = attributeInfo.type 
            local isMap = attributeInfo.isMap 
            local isArray = attributeInfo.isArray
            local collectionIndex = "__" .. propertyName
            local collection = obj[collectionIndex]

            if isMap then
              if collection then 
                for k in pairs(collection) do 
                  obj[propertyName][k] = nil
                end
              end
            elseif isArray then
              if collection then 
                for k in collection:GetIterator() do
                    obj[propertyName][k] = nil 
                end
              end
            else
              obj[propertyName] = nil 
            end
          end
        end
      end)
    end)
  end

  property "AttributeTarget" { default = AttributeTargets.Class }
end)