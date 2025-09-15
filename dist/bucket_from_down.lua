local turtle = turtle
local function is_empty_bucket(item)
  return (item and (item.name == "minecraft:bucket") and (item.count > 0))
end
local function find_empty_slot()
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
local function return_non_bucket(slot)
  turtle.select(slot)
  local item = turtle.getItemDetail()
  if item then
    print(("Returning " .. item.name .. " to chest"))
    turtle.dropDown()
    return os.sleep(0.1)
  else
    return nil
  end
end
local function main()
  print("Bucket Collector from Down v1.0")
  print("===============================")
  print("")
  if not turtle.detectDown() then
    print("ERROR: No chest detected below!")
    return print("Place turtle above chest and try again")
  else
    print("Chest detected below turtle")
    print("Starting bucket collection...")
    print("")
    local buckets_collected = 0
    local attempts = 0
    local items_returned = 0
    while (attempts < 64) do
      attempts = (attempts + 1)
      do
        local empty_slot = find_empty_slot()
        if empty_slot then
          turtle.select(empty_slot)
          if turtle.suckDown() then
            local item = turtle.getItemDetail()
            if (item and is_empty_bucket(item)) then
              buckets_collected = (buckets_collected + item.count)
              print(("Collected " .. item.count .. " empty bucket(s) - Total: " .. buckets_collected))
            else
              if item then
                print(("Found " .. item.name .. " (not bucket) - returning to chest"))
                return_non_bucket(empty_slot)
                items_returned = (items_returned + 1)
              else
                print("Collected nothing")
              end
            end
          else
            print("Chest is empty")
            break
          end
        else
          print("Inventory full!")
          break
        end
      end
      if (attempts > 32) then
        os.sleep(0.1)
      else
      end
    end
    print("")
    print("=== COLLECTION COMPLETE ===")
    print(("Empty buckets collected: " .. buckets_collected))
    print(("Non-bucket items returned: " .. items_returned))
    print(("Total attempts: " .. attempts))
    print("")
    print("Current inventory (buckets only):")
    for slot = 1, 16 do
      turtle.select(slot)
      local item = turtle.getItemDetail()
      if (item and is_empty_bucket(item)) then
        print(("Slot " .. slot .. ": " .. item.name .. " x" .. item.count))
      else
      end
    end
    print("")
    return print("Bucket collection finished!")
  end
end
return main()
