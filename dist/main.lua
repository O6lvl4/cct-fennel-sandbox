local turtle = turtle
local peripheral = peripheral
local term = term
local function clear_screen()
  term.clear()
  return term.setCursorPos(1, 1)
end
local function print_status(message)
  local time = os.date("%H:%M:%S")
  return print(("[" .. time .. "] " .. message))
end
local function is_empty_bucket_3f(item)
  return (item and (item.name == "minecraft:bucket") and ((item.count == nil) or (item.count == 0) or (item.count >= 1)))
end
local function find_chest(direction)
  local chest_type
  if (direction == "front") then
    chest_type = peripheral.getType("front")
  else
    if (direction == "back") then
      chest_type = peripheral.getType("back")
    else
      if (direction == "top") then
        chest_type = peripheral.getType("top")
      else
        if (direction == "bottom") then
          chest_type = peripheral.getType("bottom")
        else
          chest_type = nil
        end
      end
    end
  end
  if ((chest_type == "minecraft:chest") or (chest_type == "minecraft:trapped_chest") or (chest_type == "ironchests:iron_chest") or (chest_type == "ironchests:gold_chest") or (chest_type == "ironchests:diamond_chest")) then
    return peripheral.wrap(direction)
  else
    return nil
  end
end
local function get_chest_items(chest)
  if chest then
    return chest.list()
  else
    return {}
  end
end
local function collect_empty_buckets(chest, direction)
  local items = get_chest_items(chest)
  local collected = 0
  local bucket_count = 0
  for slot, item in pairs(items) do
    if is_empty_bucket_3f(item) then
      bucket_count = (bucket_count + item.count)
      local empty_slot = find_empty_inventory_slot()
      if empty_slot then
        turtle.select(empty_slot)
        if (direction == "front") then
          turtle.suck()
        else
          if (direction == "back") then
            turtle.suckBack()
          else
            if (direction == "top") then
              turtle.suckUp()
            else
              if (direction == "bottom") then
                turtle.suckDown()
              else
              end
            end
          end
        end
        collected = (collected + 1)
        print_status(("Collected empty bucket from slot " .. slot))
      else
        print_status("Inventory full! Cannot collect more buckets")
        break
      end
    else
    end
  end
  print_status(("Total empty buckets collected: " .. collected))
  return collected
end
local function find_empty_inventory_slot()
  for slot = 1, 16 do
    turtle.select(slot)
    local item = turtle.getItemDetail()
    if not item then
      return slot
    else
    end
  end
  return nil
end
local function test_is_empty_bucket()
  print_status("Testing is-empty-bucket? function...")
  local test_cases = {{item = {name = "minecraft:bucket", count = 1}, expected = true, desc = "Normal empty bucket"}, {item = {name = "minecraft:water_bucket", count = 1}, desc = "Water bucket", expected = false}, {item = {name = "minecraft:lava_bucket", count = 1}, desc = "Lava bucket", expected = false}, {item = {name = "minecraft:bucket", count = 3}, expected = true, desc = "Stack of empty buckets"}, {item = {name = "minecraft:cobblestone", count = 64}, desc = "Non-bucket item", expected = false}, {item = nil, desc = "No item", expected = false}}
  local passed = 0
  local total = #test_cases
  for _, test in ipairs(test_cases) do
    local result = is_empty_bucket_3f(test.item)
    if (result == test.expected) then
      passed = (passed + 1)
      print_status(("\226\156\147 PASS: " .. test.desc))
    else
      print_status(("\226\156\151 FAIL: " .. test.desc .. " (expected " .. tostring(test.expected) .. ", got " .. tostring(result) .. ")"))
    end
  end
  return print_status(("Tests passed: " .. passed .. "/" .. total))
end
local function main()
  clear_screen()
  print("Empty Bucket Collector v1.0")
  print("===========================")
  print("")
  test_is_empty_bucket()
  print("")
  do
    local directions = {"front", "back", "top", "bottom"}
    local chest_found = false
    local chest = nil
    local direction = nil
    for _, dir in ipairs(directions) do
      if not chest_found then
        local found_chest = find_chest(dir)
        if found_chest then
          chest = found_chest
          direction = dir
          chest_found = true
          print_status(("Found chest: " .. dir))
        else
        end
      else
      end
    end
    if chest_found then
      print_status("Starting bucket collection...")
      local collected = collect_empty_buckets(chest, direction)
      if (collected > 0) then
        print_status(("Successfully collected " .. collected .. " empty buckets!"))
      else
        print_status("No empty buckets found in chest.")
      end
    else
      print_status("No chest found in any direction!")
    end
  end
  print("")
  return print("Collection completed!")
end
return main()
