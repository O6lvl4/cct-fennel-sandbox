local turtle = turtle
local peripheral = peripheral
local function main()
  print("Chest Debug v1.0")
  print("================")
  print("")
  print("Testing chest detection...")
  print("")
  do
    local directions = {"front", "back", "left", "right", "top", "bottom"}
    for _, dir in ipairs(directions) do
      do
        local ptype = peripheral.getType(dir)
        local _1_
        if ptype then
          _1_ = ptype
        else
          _1_ = "none"
        end
        print((dir .. ": " .. _1_))
      end
      local chest = peripheral.wrap(dir)
      if chest then
        print(("  -> CHEST FOUND at " .. dir))
        print(("  -> Items: " .. #chest.list()))
      else
      end
    end
  end
  print("")
  print("Manual suck test:")
  print("Testing front...")
  if turtle.suck() then
    print("  -> Sucked something from front")
  else
    print("  -> Nothing to suck from front")
  end
  print("Testing up...")
  if turtle.suckUp() then
    print("  -> Sucked something from up")
  else
    print("  -> Nothing to suck from up")
  end
  print("")
  print("Basic detection:")
  local _6_
  if turtle.detect() then
    _6_ = "yes"
  else
    _6_ = "no"
  end
  print(("Front blocked: " .. _6_))
  local _8_
  if turtle.detectUp() then
    _8_ = "yes"
  else
    _8_ = "no"
  end
  print(("Up blocked: " .. _8_))
  local _10_
  if turtle.detectDown() then
    _10_ = "yes"
  else
    _10_ = "no"
  end
  print(("Down blocked: " .. _10_))
  print("")
  return print("Test complete")
end
return main()
