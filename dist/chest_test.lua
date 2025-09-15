local turtle = turtle
local peripheral = peripheral
local function clear_screen()
  term.clear()
  return term.setCursorPos(1, 1)
end
local function chest_cmd()
  print("=== \227\130\175\227\130\164\227\131\131\227\130\175\227\131\129\227\130\167\227\130\185\227\131\136\227\131\134\227\130\185\227\131\136 ===")
  for _, dir in ipairs({"front", "back", "left", "right", "top", "bottom"}) do
    do
      local ptype = peripheral.getType(dir)
      print((dir .. ": " .. (ptype or "\227\129\170\227\129\151")))
    end
    local chest = peripheral.wrap(dir)
    if chest then
      print((dir .. "\227\129\167\227\131\129\227\130\167\227\130\185\227\131\136\231\153\186\232\166\139"))
      local items = chest.list()
      print(("\227\130\162\227\130\164\227\131\134\227\131\160\230\149\176: " .. #items))
    else
    end
  end
  return print("\227\131\134\227\130\185\227\131\136\229\174\140\228\186\134")
end
local function scan_cmd()
  print("=== \229\145\168\232\190\186\230\169\159\229\153\168\227\130\185\227\130\173\227\131\163\227\131\179 ===")
  do
    local directions = {"front", "back", "top", "bottom", "left", "right"}
    for _, dir in ipairs(directions) do
      local ptype = peripheral.getType(dir)
      print((dir .. ": " .. (ptype or "\227\129\170\227\129\151")))
    end
  end
  local all_peripherals = peripheral.getNames()
  print(("\229\133\168\229\145\168\232\190\186\230\169\159\229\153\168: " .. table.concat(all_peripherals, ", ")))
  for _, name in ipairs(all_peripherals) do
    print(("  " .. name .. " = " .. peripheral.getType(name)))
  end
  return nil
end
local function suck_test()
  print("\230\137\139\229\139\149\229\155\158\229\143\142\227\131\134\227\130\185\227\131\136\228\184\173...")
  local directions = {front = turtle.suck, up = turtle.suckUp, down = turtle.suckDown}
  for dir, func in pairs(directions) do
    print((dir .. "\227\130\146\227\131\134\227\130\185\227\131\136\228\184\173..."))
    if func() then
      print(("  " .. dir .. "\227\129\139\227\130\137\229\155\158\229\143\142\230\136\144\229\138\159"))
    else
      print(("  " .. dir .. "\227\129\139\227\130\137\227\129\175\228\189\149\227\130\130\227\129\170\227\129\151"))
    end
  end
  return nil
end
local function basic_tests()
  print("=== \229\159\186\230\156\172\227\130\191\227\131\188\227\131\136\227\131\171\227\131\134\227\130\185\227\131\136 ===")
  print(("turtle.detect(): " .. tostring(turtle.detect())))
  print(("turtle.detectUp(): " .. tostring(turtle.detectUp())))
  return print(("turtle.detectDown(): " .. tostring(turtle.detectDown())))
end
local function main()
  clear_screen()
  print("\227\131\129\227\130\167\227\130\185\227\131\136\230\164\156\231\159\165\227\131\134\227\130\185\227\131\136 v1.0")
  print("====================")
  print("")
  print("\229\136\169\231\148\168\229\143\175\232\131\189\227\130\179\227\131\158\227\131\179\227\131\137:")
  print("1 - \227\130\175\227\130\164\227\131\131\227\130\175\227\131\129\227\130\167\227\130\185\227\131\136\227\131\134\227\130\185\227\131\136")
  print("2 - \229\145\168\232\190\186\230\169\159\229\153\168\227\130\185\227\130\173\227\131\163\227\131\179")
  print("3 - \230\137\139\229\139\149\229\155\158\229\143\142\227\131\134\227\130\185\227\131\136")
  print("4 - \229\159\186\230\156\172\230\164\156\231\159\165\227\131\134\227\130\185\227\131\136")
  print("\233\129\184\230\138\158\227\129\151\227\129\166\227\129\143\227\129\160\227\129\149\227\129\132 (1-4): ")
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
    return print("\231\132\161\229\138\185\227\129\170\233\129\184\230\138\158\227\129\167\227\129\153")
  end
end
return main()
