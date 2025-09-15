local turtle = turtle
local peripheral = peripheral
local term = term
local function clear_screen()
  term.clear()
  return term.setCursorPos(1, 1)
end
local function chest_cmd()
  print("=== QUICK CHEST TEST ===")
  for _, dir in ipairs({"front", "back", "left", "right", "top", "bottom"}) do
    do
      local ptype = peripheral.getType(dir)
      print((dir .. ": " .. (ptype or "none")))
    end
    local chest = peripheral.wrap(dir)
    if chest then
      print(("Found chest at " .. dir))
      local items = chest.list()
      print(("Items: " .. #items))
    else
    end
  end
  return print("Test complete")
end
local function scan_cmd()
  print("=== PERIPHERAL SCAN ===")
  do
    local directions = {"front", "back", "top", "bottom", "left", "right"}
    for _, dir in ipairs(directions) do
      local ptype = peripheral.getType(dir)
      print((dir .. ": " .. (ptype or "none")))
    end
  end
  local all_peripherals = peripheral.getNames()
  print(("All peripherals: " .. table.concat(all_peripherals, ", ")))
  for _, name in ipairs(all_peripherals) do
    print(("  " .. name .. " = " .. peripheral.getType(name)))
  end
  return nil
end
local function suck_test()
  print("Testing manual collection...")
  local directions = {front = turtle.suck, up = turtle.suckUp, down = turtle.suckDown}
  for dir, func in pairs(directions) do
    print(("Testing " .. dir .. "..."))
    if func() then
      print(("  Success from " .. dir))
    else
      print(("  Nothing from " .. dir))
    end
  end
  return nil
end
local function basic_tests()
  print("=== BASIC TURTLE TESTS ===")
  print(("turtle.detect(): " .. tostring(turtle.detect())))
  print(("turtle.detectUp(): " .. tostring(turtle.detectUp())))
  return print(("turtle.detectDown(): " .. tostring(turtle.detectDown())))
end
local function main()
  clear_screen()
  print("Chest Detection Test v1.0")
  print("=========================")
  print("")
  print("Available commands:")
  print("1 - Quick chest test")
  print("2 - Peripheral scan")
  print("3 - Manual suck test")
  print("4 - Basic detection test")
  print("Enter choice (1-4): ")
  local choice = read()
  if (choice == "1") then
    return chest_cmd()
  elseif (choice == "2") then
    return scan_cmd()
  elseif (choice == "3") then
    return suck_test()
  elseif (choice == "4") then
    return basic_tests()
  else
    return print("Invalid choice")
  end
end
return main()
