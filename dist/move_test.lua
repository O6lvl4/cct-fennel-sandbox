local turtle = turtle
local term = term
local function clear_screen()
  term.clear()
  return term.setCursorPos(1, 1)
end
local function move_forward_test()
  print("Testing forward movement...")
  if turtle.forward() then
    return print("Forward movement OK")
  else
    return print("Cannot move forward - blocked")
  end
end
local function move_back_test()
  print("Testing backward movement...")
  if turtle.back() then
    return print("Backward movement OK")
  else
    return print("Cannot move backward")
  end
end
local function turn_test()
  print("Testing rotation...")
  turtle.turnLeft()
  print("Left turn complete")
  turtle.turnRight()
  print("Right turn complete")
  return print("Back to original direction")
end
local function movement_loop()
  print("Movement loop test (5 steps)")
  for i = 1, 5 do
    print(("Step " .. i .. "/5"))
    if turtle.forward() then
      print("  Forward OK")
    else
      print("  Forward blocked - trying detour")
      turtle.turnLeft()
      if turtle.forward() then
        print("  Left detour OK")
        turtle.turnRight()
      else
        turtle.turnRight()
        turtle.turnRight()
        if turtle.forward() then
          print("  Right detour OK")
          turtle.turnLeft()
        else
          turtle.turnLeft()
          print("  All directions blocked")
        end
      end
    end
    os.sleep(1)
  end
  return nil
end
local function detection_test()
  print("Obstacle detection test")
  local _6_
  if turtle.detect() then
    _6_ = "blocked"
  else
    _6_ = "clear"
  end
  print(("Front: " .. _6_))
  local _8_
  if turtle.detectUp() then
    _8_ = "blocked"
  else
    _8_ = "clear"
  end
  print(("Up: " .. _8_))
  local _10_
  if turtle.detectDown() then
    _10_ = "blocked"
  else
    _10_ = "clear"
  end
  return print(("Down: " .. _10_))
end
local function inspect_test()
  print("Block inspection test")
  do
    local has_block, block_data = turtle.inspect()
    if has_block then
      print(("Front block: " .. block_data.name))
    else
      print("Front: nothing")
    end
  end
  do
    local has_block, block_data = turtle.inspectUp()
    if has_block then
      print(("Up block: " .. block_data.name))
    else
      print("Up: nothing")
    end
  end
  local has_block, block_data = turtle.inspectDown()
  if has_block then
    return print(("Down block: " .. block_data.name))
  else
    return print("Down: nothing")
  end
end
local function main()
  clear_screen()
  print("Movement Test v1.0")
  print("==================")
  print("")
  print("Available tests:")
  print("1 - Forward movement test")
  print("2 - Backward movement test")
  print("3 - Rotation test")
  print("4 - Movement loop test")
  print("5 - Obstacle detection test")
  print("6 - Block inspection test")
  print("Enter choice (1-6): ")
  local choice = read()
  if (choice == "1") then
    return move_forward_test()
  elseif (choice == "2") then
    return move_back_test()
  elseif (choice == "3") then
    return turn_test()
  elseif (choice == "4") then
    return movement_loop()
  elseif (choice == "5") then
    return detection_test()
  elseif (choice == "6") then
    return inspect_test()
  else
    return print("Invalid choice")
  end
end
return main()
