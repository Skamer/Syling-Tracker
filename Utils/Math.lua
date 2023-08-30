-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Math"                           ""
-- ========================================================================= --
export {
  pow = math.pow
}



__Static__() function Utils.Linear(a, b, progress)
  return a + (b - a) * progress
end

__Static__() function Utils.QuadraticEaseIn(a, b, progress)
  return a + (b - a) * (progress * progress)  
end

__Static__() function Utils.QuadracticEaseOut(a, b, progress)
  return a + (b - a) * (-progress * (progress - 2))
end

__Arguments__ { Number, Number/0, Boolean/false }
__Static__() function Utils.TruncateDecimal(number, decimal, round)
  local tenPower = math.pow(10, decimal)

  if round then 
    return math.floor(number * tenPower + 0.5)/ tenPower
  else
    return math.floor(number * tenPower)/ tenPower
  end
end

__Arguments__ { Number }
__Static__() function Utils.GetDecimalCount(number)
  local strNumber = tostring(number)
  local decimalCount = 0
  local foundDecimal = false 
  
  for i = 1, string.len(strNumber) do 
    if foundDecimal then 
      decimalCount = decimalCount + 1
    elseif string.sub(strNumber, i, i) == "." then 
      foundDecimal = true 
    end
  end

  return decimalCount
end
