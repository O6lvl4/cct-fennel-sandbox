local turtle = turtle
local function main()
  print("Down Chest Test v1.0")
  print("====================")
  print("")
  print("Testing down direction...")
  local _1_
  if turtle.detectDown() then
    _1_ = "yes"
  else
    _1_ = "no"
  end
  print(("Down blocked: " .. _1_))
  print("")
  print("Attempting to suck from down chest...")
  local attempts = 0
  local items_collected = 0
  while (attempts < 10) do
    attempts = (attempts + 1)
    print(("Attempt " .. attempts .. "/10"))
    if turtle.suckDown() then
      items_collected = (items_collected + 1)
      print("  -> SUCCESS! Item collected")
      local item = turtle.getItemDetail()
      if item then
        print(("  -> Item: " .. item.name .. " x" .. item.count))
      else
      end
    else
      print("  -> Nothing to collect")
      break
    end
    os.sleep(0.5)
  end
  print("")
  print(("Total items collected: " .. items_collected))
  print("")
  print("Current inventory:")
  for slot = 1, 16 do
    turtle.select(slot)
    local item = turtle.getItemDetail()
    if item then
      print(("Slot " .. slot .. ": " .. item.name .. " x" .. item.count))
    else
    end
  end
  print("")
  return print("Test complete")
end
return main()
