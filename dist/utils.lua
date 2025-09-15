local turtle = turtle
local fs = fs
local term = term
local function clear_screen()
  term.clear()
  return term.setCursorPos(1, 1)
end
local function print_status(message)
  local time = os.date("%H:%M:%S")
  return print(("[" .. time .. "] " .. message))
end
local function is_empty_bucket(item)
  return (item and (item.name == "minecraft:bucket") and ((item.count == nil) or (item.count == 0) or (item.count >= 1)))
end
local function is_chest_block(block_name)
  return ((block_name == "minecraft:chest") or (block_name == "minecraft:trapped_chest") or (block_name == "ironchests:iron_chest") or (block_name == "ironchests:gold_chest") or (block_name == "ironchests:diamond_chest") or (block_name == "minecraft:ender_chest"))
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
local function find_index(tbl, item)
  local result = nil
  for i, v in ipairs(tbl) do
    if (v == item) then
      result = i
    else
    end
  end
  return result
end
local function calculate_distance(pos1, pos2)
  return (math.abs((pos1.x - pos2.x)) + math.abs((pos1.z - pos2.z)))
end
local function save_config(config, config_file)
  local file = fs.open(config_file, "w")
  if file then
    file.write(textutils.serialize(config))
    file.close()
    return print_status("Configuration saved to file")
  else
    return nil
  end
end
local function load_config(config_file)
  if fs.exists(config_file) then
    local file = fs.open(config_file, "r")
    if file then
      local data = file.readAll()
      file.close()
      local config = textutils.unserialize(data)
      if config then
        print_status("Configuration loaded from file")
        return config
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
local function check_fuel()
  local fuel = turtle.getFuelLevel()
  print_status(("Fuel level: " .. fuel))
  if (fuel < 10) then
    print_status("WARNING: Low fuel")
  else
  end
  return fuel
end
local function refuel_if_needed()
  local fuel = turtle.getFuelLevel()
  if (fuel < 10) then
    print_status("Attempting to refuel...")
    for slot = 1, 16 do
      turtle.select(slot)
      local item = turtle.getItemDetail()
      if (item and ((item.name == "minecraft:coal") or (item.name == "minecraft:charcoal") or (item.name == "minecraft:lava_bucket"))) then
        if turtle.refuel(1) then
          print_status("Refuel successful")
          break
        else
          print_status("Refuel failed")
        end
      else
      end
    end
    return nil
  else
    return nil
  end
end
return {clear_screen = clear_screen, print_status = print_status, is_empty_bucket = is_empty_bucket, is_chest_block = is_chest_block, find_empty_inventory_slot = find_empty_inventory_slot, find_index = find_index, calculate_distance = calculate_distance, save_config = save_config, load_config = load_config, get_gps_position = get_gps_position, check_fuel = check_fuel, refuel_if_needed = refuel_if_needed}
