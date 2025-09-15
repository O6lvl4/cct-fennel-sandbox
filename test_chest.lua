-- Simple chest detection test
print("=== CHEST DETECTION TEST ===")

-- Test all directions
local directions = {"front", "back", "top", "bottom", "left", "right"}

for _, dir in ipairs(directions) do
    print("Checking " .. dir .. ":")
    
    -- Method 1: peripheral.getType
    local ptype = peripheral.getType(dir)
    print("  peripheral.getType('" .. dir .. "'): " .. (ptype or "nil"))
    
    -- Method 2: turtle.inspect (only for front/up/down)
    if dir == "front" then
        local hasBlock, blockData = turtle.inspect()
        print("  turtle.inspect(): " .. tostring(hasBlock))
        if hasBlock then
            print("    Block: " .. blockData.name)
        end
    elseif dir == "top" then
        local hasBlock, blockData = turtle.inspectUp()
        print("  turtle.inspectUp(): " .. tostring(hasBlock))
        if hasBlock then
            print("    Block: " .. blockData.name)
        end
    elseif dir == "bottom" then
        local hasBlock, blockData = turtle.inspectDown()
        print("  turtle.inspectDown(): " .. tostring(hasBlock))
        if hasBlock then
            print("    Block: " .. blockData.name)
        end
    end
    
    -- Method 3: peripheral.wrap attempt
    local wrapped = peripheral.wrap(dir)
    print("  peripheral.wrap('" .. dir .. "'): " .. (wrapped and "success" or "nil"))
    
    print("")
end

-- List all peripherals
print("=== ALL PERIPHERALS ===")
local allPeripherals = peripheral.getNames()
print("Found " .. #allPeripherals .. " peripherals:")
for _, name in ipairs(allPeripherals) do
    print("  " .. name .. " = " .. peripheral.getType(name))
end

-- Test basic turtle functions
print("\n=== TURTLE BASIC TESTS ===")
print("turtle.detect(): " .. tostring(turtle.detect()))
print("turtle.detectUp(): " .. tostring(turtle.detectUp()))  
print("turtle.detectDown(): " .. tostring(turtle.detectDown()))

print("\nTest completed!")