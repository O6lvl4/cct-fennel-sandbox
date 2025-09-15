local turtle = turtle
local function is_empty_bucket(item)
  return (item and (item.name == "minecraft:bucket"))
end
local function find_empty_slot()
  for slot = 1, 16 do
    turtle.select(slot)
    if not turtle.getItemDetail() then
      return slot
    else
    end
  end
  return nil
end
local function stack_buckets()
  local stacked = 0
  for slot1 = 1, 15 do
    turtle.select(slot1)
    local item1 = turtle.getItemDetail()
    if (item1 and is_empty_bucket(item1) and (item1.count < 64)) then
      for slot2 = (slot1 + 1), 16 do
        local item2 = turtle.getItemDetail(slot2)
        if (item2 and is_empty_bucket(item2)) then
          turtle.select(slot2)
          turtle.transferTo(slot1)
          stacked = (stacked + 1)
        else
        end
      end
    else
    end
  end
  return stacked
end
local function batch_return_non_buckets()
  local returned = 0
  for slot = 1, 16 do
    turtle.select(slot)
    local item = turtle.getItemDetail()
    if (item and not is_empty_bucket(item)) then
      turtle.dropDown()
      returned = (returned + 1)
    else
    end
  end
  return returned
end
local function collect_phase()
  local collected = 0
  local attempts = 0
  print("Phase 1: Fast collection...")
  while ((attempts < 200) and find_empty_slot()) do
    attempts = (attempts + 1)
    do
      local empty_slot = find_empty_slot()
      if empty_slot then
        turtle.select(empty_slot)
        if turtle.suckDown() then
          collected = (collected + 1)
        else
          break
        end
      else
      end
    end
    if ((collected % 16) == 0) then
      stack_buckets()
    else
    end
  end
  print(("Collected " .. collected .. " items in " .. attempts .. " attempts"))
  return collected
end
local function sort_phase()
  print("Phase 2: Sorting items...")
  do
    local returned = batch_return_non_buckets()
    print(("Returned " .. returned .. " non-bucket items"))
  end
  do
    local stacked = stack_buckets()
    if (stacked > 0) then
      print(("Stacked " .. stacked .. " bucket groups"))
    else
    end
  end
  local total_buckets = 0
  for slot = 1, 16 do
    turtle.select(slot)
    local item = turtle.getItemDetail()
    if (item and is_empty_bucket(item)) then
      total_buckets = (total_buckets + item.count)
    else
    end
  end
  return total_buckets
end
local function main()
  print("Optimized Bucket Collector v2.0")
  print("===============================")
  print("")
  if not turtle.detectDown() then
    print("ERROR: No chest below!")
    return
    return nil
  else
    local start_time = os.clock()
    local items_collected = collect_phase()
    local bucket_count = sort_phase()
    local end_time = os.clock()
    local duration = (end_time - start_time)
    print("")
    print("=== RESULTS ===")
    print(("Empty buckets collected: " .. bucket_count))
    print(("Time taken: " .. string.format("%.2f", duration) .. " seconds"))
    print(("Efficiency: " .. string.format("%.1f", (bucket_count / duration)) .. " buckets/sec"))
    print("")
    print("Final inventory:")
    for slot = 1, 16 do
      turtle.select(slot)
      local item = turtle.getItemDetail()
      if item then
        print(("Slot " .. slot .. ": " .. item.name .. " x" .. item.count))
      else
      end
    end
    print("")
    return print("Collection optimized!")
  end
end
return main()
