local turtle = turtle
local peripheral = peripheral
local term = term
local fs = fs
local current_pos = {x = -1838, y = 64, z = -131}
local target_chest = {x = -1836, y = 63, z = -127}
local config_file = "bucket_collector_config.txt"
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
local function save_config()
  local config_data = {["current-pos"] = current_pos, ["target-chest"] = target_chest}
  local file = fs.open(config_file, "w")
  if file then
    file.write(textutils.serialize(config_data))
    file.close()
    return print_status("Configuration saved to file")
  else
    return nil
  end
end
local function load_config()
  if fs.exists(config_file) then
    local file = fs.open(config_file, "r")
    if file then
      local data = file.readAll()
      file.close()
      local config = textutils.unserialize(data)
      if config then
        current_pos = config["current-pos"]
        target_chest = config["target-chest"]
        return print_status("Configuration loaded from file")
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
local function get_gps_position()
  local x = gps.locate(5)
  if x then
    local y = select(2, gps.locate(5))
    local z = select(3, gps.locate(5))
    return {x = x, y = y, z = z}
  else
    return nil
  end
end
local function update_current_position()
  local gps_pos = get_gps_position()
  if gps_pos then
    current_pos = gps_pos
    save_config()
    return print_status(("Position updated: " .. current_pos.x .. ", " .. current_pos.y .. ", " .. current_pos.z))
  else
    return print_status("GPS not available, using stored position")
  end
end
local function calculate_distance(pos1, pos2)
  return (math.abs((pos1.x - pos2.x)) + math.abs((pos1.y - pos2.y)) + math.abs((pos1.z - pos2.z)))
end
local function get_direction_to_target()
  local dx = (target_chest.x - current_pos.x)
  local dy = (target_chest.y - current_pos.y)
  local dz = (target_chest.z - current_pos.z)
  print_status(("Target offset: x=" .. dx .. " y=" .. dy .. " z=" .. dz))
  if ((dx == 2) and (dy == -1) and (dz == 4)) then
    return "front"
  elseif ((dx == -2) and (dy == 1) and (dz == -4)) then
    return "back"
  elseif ((dy == 1) and (math.abs(dx) < 2) and (math.abs(dz) < 2)) then
    return "top"
  elseif ((dy == -1) and (math.abs(dx) < 2) and (math.abs(dz) < 2)) then
    return "bottom"
  else
    return nil
  end
end
local function move_towards_target()
  local dx = (target_chest.x - current_pos.x)
  local dy = (target_chest.y - current_pos.y)
  local dz = (target_chest.z - current_pos.z)
  print_status(("Current: " .. current_pos.x .. ", " .. current_pos.y .. ", " .. current_pos.z))
  print_status(("Target: " .. target_chest.x .. ", " .. target_chest.y .. ", " .. target_chest.z))
  print_status(("Delta: dx=" .. dx .. " dy=" .. dy .. " dz=" .. dz))
  if (dx ~= 0) then
    if (dx > 0) then
      print_status("Moving East (+X)")
      turtle.turnRight()
      if turtle.forward() then
        current_pos.x = (current_pos.x + 1)
        print_status("Moved East successfully")
      else
        print_status("Failed to move East - blocked")
      end
      turtle.turnLeft()
    else
      print_status("Moving West (-X)")
      turtle.turnLeft()
      if turtle.forward() then
        current_pos.x = (current_pos.x - 1)
        print_status("Moved West successfully")
      else
        print_status("Failed to move West - blocked")
      end
      turtle.turnRight()
    end
  else
  end
  if (dy ~= 0) then
    if (dy > 0) then
      print_status("Moving Up (+Y)")
      if turtle.up() then
        current_pos.y = (current_pos.y + 1)
        print_status("Moved Up successfully")
      else
        print_status("Failed to move Up - blocked")
      end
    else
      print_status("Moving Down (-Y)")
      if turtle.down() then
        current_pos.y = (current_pos.y - 1)
        print_status("Moved Down successfully")
      else
        print_status("Failed to move Down - blocked")
      end
    end
  else
  end
  if (dz ~= 0) then
    if (dz > 0) then
      print_status("Moving North (+Z)")
      if turtle.forward() then
        current_pos.z = (current_pos.z + 1)
        print_status("Moved North successfully")
      else
        print_status("Failed to move North - blocked")
      end
    else
      print_status("Moving South (-Z)")
      turtle.turnRight()
      turtle.turnRight()
      if turtle.forward() then
        current_pos.z = (current_pos.z - 1)
        print_status("Moved South successfully")
      else
        print_status("Failed to move South - blocked")
      end
      turtle.turnRight()
      turtle.turnRight()
    end
  else
  end
  return save_config()
end
local function navigate_to_chest()
  local initial_distance = calculate_distance(current_pos, target_chest)
  print_status(("Initial distance to chest: " .. initial_distance .. " blocks"))
  if (initial_distance > 1) then
    print_status("Starting navigation to chest...")
    local attempts = 0
    local current_distance = initial_distance
    while ((current_distance > 1) and (attempts < 20)) do
      attempts = (attempts + 1)
      print_status(("Navigation attempt " .. attempts .. "/20"))
      move_towards_target()
      current_distance = calculate_distance(current_pos, target_chest)
      print_status(("Distance after move: " .. current_distance .. " blocks"))
      os.sleep(0.5)
    end
    if (current_distance <= 1) then
      print_status("Successfully navigated to chest area!")
    else
      print_status(("Navigation incomplete after " .. attempts .. " attempts"))
    end
    return save_config()
  else
    return nil
  end
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
  print("Empty Bucket Collector v2.0 with GPS")
  print("====================================")
  print("")
  load_config()
  print_status(("Current position: " .. current_pos.x .. ", " .. current_pos.y .. ", " .. current_pos.z))
  print_status(("Target chest: " .. target_chest.x .. ", " .. target_chest.y .. ", " .. target_chest.z))
  update_current_position()
  print("")
  test_is_empty_bucket()
  print("")
  do
    local distance = calculate_distance(current_pos, target_chest)
    if (distance > 1) then
      print_status(("Distance to chest: " .. distance .. " blocks - navigating..."))
      navigate_to_chest()
    else
      print_status("Already adjacent to chest")
    end
  end
  do
    local preferred_direction = get_direction_to_target()
    local directions
    if preferred_direction then
      directions = {preferred_direction, "front", "back", "top", "bottom"}
    else
      directions = {"front", "back", "top", "bottom"}
    end
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
