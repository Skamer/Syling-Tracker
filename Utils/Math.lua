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

__Static__() function Utils.Linear(t, b, c, d)
  return c * t / d + b
end

__Static__() function Utils.QuadraticEaseIn(t, b, c, d)
  t = t / d
  return c * pow(t, 2) + b  
end

__Static__() function Utils.QuadracticEaseOut(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

__Static__() function Utils.QuadraticEaseInOut(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

__Static__() function Utils.ExponentialEaseIn(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

__Static__() function Utils.ExponentialEaseOut(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end  
end

__Static__() function Utils.ExponentialEaseInOut(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
  end
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
