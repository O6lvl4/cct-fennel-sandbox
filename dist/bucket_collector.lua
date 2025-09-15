local turtle = turtle
local peripheral = peripheral
local utils = require("utils")
local current_pos = {x = -1838, y = 64, z = -128}
local target_chest = {x = -1836, y = 63, z = -127}
local current_facing = "east"
local config_file = "bucket_collector_config.txt"
local function inspect_direction(direction)
  local has_block, block_data = nil, nil
  if (direction == "front") then
    has_block, block_data = turtle.inspect()
  elseif (direction == "up") then
    has_block, block_data = turtle.inspectUp()
  elseif (direction == "down") then
    has_block, block_data = turtle.inspectDown()
  else
    has_block, block_data = false, {}
  end
  if has_block then
    return {block_name = block_data.name, block = block_data}
  else
    return {block_name = nil, block = nil}
  end
end
local function find_chest(direction)
  local chest_type = peripheral.getType(direction)
  local inspect_result
  if ((direction == "front") or (direction == "up") or (direction == "down")) then
    inspect_result = inspect_direction(direction)
  else
    inspect_result = {block_name = nil}
  end
  utils.print_status((direction .. "\227\130\146\231\162\186\232\170\141\228\184\173:"))
  utils.print_status(("  \229\145\168\232\190\186\230\169\159\229\153\168: " .. (chest_type or "\227\129\170\227\129\151")))
  utils.print_status(("  \232\170\191\230\159\187: " .. (inspect_result.block_name or "\227\129\170\227\129\151")))
  local is_chest_peripheral = ((chest_type == "minecraft:chest") or (chest_type == "minecraft:trapped_chest") or (chest_type == "ironchests:iron_chest") or (chest_type == "ironchests:gold_chest") or (chest_type == "ironchests:diamond_chest"))
  local is_chest_inspect = utils.is_chest_block(inspect_result.block_name)
  if (is_chest_peripheral or is_chest_inspect) then
    utils.print_status(("\226\156\147 " .. direction .. "\227\129\167\227\131\129\227\130\167\227\130\185\227\131\136\231\153\186\232\166\139!"))
    local wrapped = peripheral.wrap(direction)
    if wrapped then
      return wrapped
    else
      return {direction = direction, type = "manual"}
    end
  else
    utils.print_status(("\226\156\151 " .. direction .. "\227\129\171\227\131\129\227\130\167\227\130\185\227\131\136\227\129\170\227\129\151"))
    return nil
  end
end
local function collect_empty_buckets(chest, direction)
  if (chest and (chest.type == "manual")) then
    utils.print_status("\230\137\139\229\139\149\227\131\129\227\130\167\227\130\185\227\131\136\230\164\156\229\135\186 - \227\130\162\227\130\164\227\131\134\227\131\160\229\155\158\229\143\142\232\169\166\232\161\140\228\184\173")
    local collected = 0
    local attempts = 0
    while ((attempts < 64) and (collected < 16)) do
      attempts = (attempts + 1)
      local empty_slot = utils.find_empty_inventory_slot()
      if empty_slot then
        turtle.select(empty_slot)
        local success
        if (direction == "front") then
          success = turtle.suck()
        elseif (direction == "up") then
          success = turtle.suckUp()
        elseif (direction == "down") then
          success = turtle.suckDown()
        else
          success = false
        end
        if success then
          local item = turtle.getItemDetail()
          if (item and utils.is_empty_bucket(item)) then
            collected = (collected + item.count)
            utils.print_status((item.count .. "\229\128\139\227\129\174\231\169\186\227\131\144\227\130\177\227\131\132\227\130\146\229\155\158\229\143\142"))
          else
            if item then
              utils.print_status(("\233\157\158\227\131\144\227\130\177\227\131\132\227\130\162\227\130\164\227\131\134\227\131\160\227\130\146\229\155\158\229\143\142: " .. item.name))
            else
            end
          end
        else
          break
        end
      else
        break
      end
    end
    utils.print_status(("\230\137\139\229\139\149\229\155\158\229\143\142\229\174\140\228\186\134: " .. collected .. "\229\128\139\227\129\174\231\169\186\227\131\144\227\130\177\227\131\132"))
    return collected
  else
    local items
    if chest then
      items = chest.list()
    else
      items = {}
    end
    local collected = 0
    for slot, item in pairs(items) do
      if utils.is_empty_bucket(item) then
        local empty_slot = utils.find_empty_inventory_slot()
        if empty_slot then
          turtle.select(empty_slot)
          if (direction == "front") then
            turtle.suck()
          elseif (direction == "up") then
            turtle.suckUp()
          elseif (direction == "down") then
            turtle.suckDown()
          else
          end
          collected = (collected + 1)
          utils.print_status(("\227\130\185\227\131\173\227\131\131\227\131\136" .. slot .. "\227\129\139\227\130\137\231\169\186\227\131\144\227\130\177\227\131\132\227\130\146\229\155\158\229\143\142"))
        else
          utils.print_status("\227\130\164\227\131\179\227\131\153\227\131\179\227\131\136\227\131\170\230\186\128\230\157\175\239\188\129")
          break
        end
      else
      end
    end
    utils.print_status(("\229\144\136\232\168\136\229\155\158\229\143\142\227\129\151\227\129\159\231\169\186\227\131\144\227\130\177\227\131\132: " .. collected .. "\229\128\139"))
    return collected
  end
end
local function save_config()
  local config = {current_pos = current_pos, target_chest = target_chest, current_facing = current_facing}
  return utils.save_config(config, config_file)
end
local function load_config()
  local config = utils.load_config(config_file)
  if config then
    current_pos = config.current_pos
    target_chest = config.target_chest
    if config.current_facing then
      current_facing = config.current_facing
      return nil
    else
      return nil
    end
  else
    return nil
  end
end
local function main()
  utils.clear_screen()
  print("\231\169\186\227\131\144\227\130\177\227\131\132\229\155\158\229\143\142 v1.0")
  print("================")
  print("")
  load_config()
  utils.print_status(("\231\143\190\229\156\168\228\189\141\231\189\174: " .. current_pos.x .. ", " .. current_pos.y .. ", " .. current_pos.z))
  utils.print_status(("\231\155\174\230\168\153\227\131\129\227\130\167\227\130\185\227\131\136: " .. target_chest.x .. ", " .. target_chest.y .. ", " .. target_chest.z))
  utils.check_fuel()
  utils.refuel_if_needed()
  do
    local directions = {"front", "back", "top", "bottom", "left", "right"}
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
        else
        end
      else
      end
    end
    if chest_found then
      utils.print_status("\227\131\144\227\130\177\227\131\132\229\155\158\229\143\142\227\130\146\233\150\139\229\167\139\227\129\151\227\129\190\227\129\153...")
      local collected = collect_empty_buckets(chest, direction)
      if (collected > 0) then
        utils.print_status((collected .. "\229\128\139\227\129\174\231\169\186\227\131\144\227\130\177\227\131\132\227\130\146\229\155\158\229\143\142\230\136\144\229\138\159\239\188\129"))
      else
        utils.print_status("\227\131\129\227\130\167\227\130\185\227\131\136\227\129\171\231\169\186\227\131\144\227\130\177\227\131\132\227\129\140\232\166\139\227\129\164\227\129\139\227\130\138\227\129\190\227\129\155\227\130\147\227\129\167\227\129\151\227\129\159")
      end
    else
      utils.print_status("\227\129\169\227\129\174\230\150\185\229\144\145\227\129\171\227\130\130\227\131\129\227\130\167\227\130\185\227\131\136\227\129\140\232\166\139\227\129\164\227\129\139\227\130\138\227\129\190\227\129\155\227\130\147\227\129\167\227\129\151\227\129\159\239\188\129")
    end
  end
  print("")
  return print("\229\155\158\229\143\142\229\174\140\228\186\134\239\188\129")
end
return main()
