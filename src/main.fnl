;; CC:Tweaked Empty Bucket Collector with Coordinate System
;; Collects only empty buckets from specified chest with GPS tracking

(local turtle turtle)
(local peripheral peripheral)
(local term term)
(local fs fs)

;; Global coordinates configuration (update these based on current position)
(var current-pos {:x -1838 :y 64 :z -128})
(var target-chest {:x -1836 :y 63 :z -127})
(var current-facing "east") ; Track which direction turtle is facing
(local config-file "bucket_collector_config.txt")

(fn clear-screen []
  "Clear the terminal screen"
  (term.clear)
  (term.setCursorPos 1 1))

(fn print-status [message]
  "Print a status message with timestamp"
  (let [time (os.date "%H:%M:%S")]
    (print (.. "[" time "] " message))))

(fn is-empty-bucket? [item]
  "Check if item is an empty bucket"
  (and item
       (= item.name "minecraft:bucket")
       (or (= item.count nil) (= item.count 0) (>= item.count 1))))

(fn find-chest [direction]
  "Find chest in specified direction with detailed logging"
  (let [chest-type (if (= direction "front") 
                       (peripheral.getType "front")
                       (if (= direction "back")
                           (peripheral.getType "back")
                           (if (= direction "top")
                               (peripheral.getType "top")
                               (if (= direction "bottom")
                                   (peripheral.getType "bottom")
                                   nil))))]
    (print-status (.. "Checking " direction ": " (or chest-type "nothing")))
    (if (or (= chest-type "minecraft:chest")
            (= chest-type "minecraft:trapped_chest")
            (= chest-type "ironchests:iron_chest")
            (= chest-type "ironchests:gold_chest")
            (= chest-type "ironchests:diamond_chest"))
        (do
          (print-status (.. "Found chest in " direction "!"))
          (peripheral.wrap direction))
        (do
          (print-status (.. "No chest found in " direction))
          nil))))

(fn get-chest-items [chest]
  "Get all items from chest"
  (if chest
      (chest.list)
      {}))

(fn collect-empty-buckets [chest direction]
  "Collect empty buckets from chest"
  (let [items (get-chest-items chest)]
    (var collected 0)
    (var bucket-count 0)
    
    (each [slot item (pairs items)]
      (when (is-empty-bucket? item)
        (set bucket-count (+ bucket-count item.count))
        (let [empty-slot (find-empty-inventory-slot)]
          (if empty-slot
              (do
                (turtle.select empty-slot)
                (if (= direction "front")
                    (turtle.suck)
                    (if (= direction "back") 
                        (turtle.suckBack)
                        (if (= direction "top")
                            (turtle.suckUp)
                            (if (= direction "bottom")
                                (turtle.suckDown)
                                false))))
                (set collected (+ collected 1))
                (print-status (.. "Collected empty bucket from slot " slot)))
              (do
                (print-status "Inventory full! Cannot collect more buckets")
                (lua "break"))))))
    
    (print-status (.. "Total empty buckets collected: " collected))
    collected))

(fn find-empty-inventory-slot []
  "Find first empty inventory slot"
  (for [slot 1 16]
    (turtle.select slot)
    (let [item (turtle.getItemDetail)]
      (when (not item)
        (lua "return slot"))))
  nil)

(fn save-config []
  "Save current configuration to file"
  (let [config-data {:current-pos current-pos
                     :target-chest target-chest
                     :current-facing current-facing}
        file (fs.open config-file "w")]
    (when file
      (file.write (textutils.serialize config-data))
      (file.close)
      (print-status "Configuration saved to file"))))

(fn load-config []
  "Load configuration from file"
  (when (fs.exists config-file)
    (let [file (fs.open config-file "r")]
      (when file
        (let [data (file.readAll)]
          (file.close)
          (let [config (textutils.unserialize data)]
            (when config
              (set current-pos config.current-pos)
              (set target-chest config.target-chest)
              (when config.current-facing
                (set current-facing config.current-facing))
              (print-status "Configuration loaded from file"))))))))

(fn get-gps-position []
  "Get current GPS position"
  (let [x (gps.locate 5)]
    (if x
        (let [y (select 2 (gps.locate 5))
              z (select 3 (gps.locate 5))]
          {:x x :y y :z z})
        nil)))

(fn update-current-position []
  "Update current position using GPS"
  (let [gps-pos (get-gps-position)]
    (if gps-pos
        (do
          (set current-pos gps-pos)
          (save-config)
          (print-status (.. "Position updated: " current-pos.x ", " current-pos.y ", " current-pos.z)))
        (print-status "GPS not available, using stored position"))))

(fn turn-left []
  "Turn left and update facing direction"
  (turtle.turnLeft)
  (if (= current-facing "north") (set current-facing "west")
      (= current-facing "east") (set current-facing "north") 
      (= current-facing "south") (set current-facing "east")
      (= current-facing "west") (set current-facing "south"))
  (print-status (.. "Turned left, now facing " current-facing)))

(fn turn-right []
  "Turn right and update facing direction"
  (turtle.turnRight)
  (if (= current-facing "north") (set current-facing "east")
      (= current-facing "east") (set current-facing "south")
      (= current-facing "south") (set current-facing "west") 
      (= current-facing "west") (set current-facing "north"))
  (print-status (.. "Turned right, now facing " current-facing)))

(fn move-forward []
  "Move forward and update position based on facing direction"
  (when (turtle.forward)
    (if (= current-facing "north") (set current-pos.z (+ current-pos.z 1))
        (= current-facing "south") (set current-pos.z (- current-pos.z 1))
        (= current-facing "east") (set current-pos.x (+ current-pos.x 1))
        (= current-facing "west") (set current-pos.x (- current-pos.x 1)))
    (print-status (.. "Moved forward to " current-pos.x ", " current-pos.y ", " current-pos.z))
    (save-config)
    true))

(fn check-obstacles []
  "Check for obstacles in all directions"
  (let [front (turtle.detect)
        up (turtle.detectUp)
        down (turtle.detectDown)]
    (print-status (.. "Obstacles - Front: " (if front "YES" "NO") 
                      " Up: " (if up "YES" "NO") 
                      " Down: " (if down "YES" "NO")))
    {:front front :up up :down down}))

(fn scan-all-peripherals []
  "Scan all peripheral directions and log what's found"
  (print-status "=== PERIPHERAL SCAN ===")
  (let [directions ["front" "back" "top" "bottom" "left" "right"]]
    (each [_ dir (ipairs directions)]
      (let [ptype (peripheral.getType dir)]
        (print-status (.. dir ": " (or ptype "nothing")))))
    
    ;; Also check all peripheral names
    (let [all-peripherals (peripheral.getNames)]
      (print-status (.. "All peripherals: " (table.concat all-peripherals ", ")))
      (each [_ name (ipairs all-peripherals)]
        (print-status (.. "  " name " = " (peripheral.getType name)))))))

(fn calculate-distance [pos1 pos2]
  "Calculate Manhattan distance between two positions (X and Z only)"
  (+ (math.abs (- pos1.x pos2.x))
     (math.abs (- pos1.z pos2.z))))

(fn get-direction-to-target []
  "Calculate direction to target chest based on adjacent position"
  (let [dx (- target-chest.x current-pos.x)
        dy (- target-chest.y current-pos.y)
        dz (- target-chest.z current-pos.z)]
    (print-status (.. "Target offset: x=" dx " y=" dy " z=" dz))
    (if (and (= dx 1) (= dy 0) (= dz 0))
        "front"    ; Chest is +X (East)
        (if (and (= dx -1) (= dy 0) (= dz 0))
            "back"    ; Chest is -X (West)  
            (if (and (= dx 0) (= dy 1) (= dz 0))
                "top"      ; Chest is +Y (Up)
                (if (and (= dx 0) (= dy -1) (= dz 0))
                    "bottom"  ; Chest is -Y (Down)
                    (if (and (= dx 0) (= dy 0) (= dz 1))
                        "front"    ; Chest is +Z (North)
                        (if (and (= dx 0) (= dy 0) (= dz -1))
                            "back"    ; Chest is -Z (South)
                            nil))))))))

(fn try-detour []
  "Try to move around obstacles using new movement functions"
  (print-status "Attempting obstacle avoidance...")
  (let [obstacles (check-obstacles)]
    
    ;; Try left detour
    (turn-left)
    (if (not obstacles.front)
        (if (move-forward)
            (do
              (print-status "Detour: moved left, trying to continue")
              (turn-right) ;; Face original direction
              (if (move-forward)
                  (do
                    (print-status "Left detour successful!")
                    (turn-left) ;; Return to original facing
                    true)
                  (do
                    (print-status "Left detour failed, undoing")
                    (turn-left)
                    (move-forward) ;; Return
                    (turn-right)
                    false)))
            false)
        (do
          (print-status "Left blocked, trying right")
          (turn-right) ;; Return to original
          (turn-right) ;; Turn right
          (if (move-forward)
              (do
                (print-status "Detour: moved right, trying to continue")
                (turn-left) ;; Face original direction
                (if (move-forward)
                    (do
                      (print-status "Right detour successful!")
                      (turn-right) ;; Return to original facing
                      true)
                    (do
                      (print-status "Right detour failed, undoing")
                      (turn-right)
                      (move-forward) ;; Return
                      (turn-left)
                      false)))
              (do
                (print-status "Both directions blocked")
                (turn-left) ;; Return to original facing
                false))))))

(fn face-direction [target-dir]
  "Turn to face the specified direction"
  (let [directions ["north" "east" "south" "west"]
        current-idx (or (find-index directions current-facing) 1)
        target-idx (or (find-index directions target-dir) 1)
        turns (- target-idx current-idx)]
    (if (= turns 0) nil ; Already facing correct direction
        (or (= turns 1) (= turns -3)) (turn-right)
        (or (= turns -1) (= turns 3)) (turn-left)
        (or (= turns 2) (= turns -2)) (do (turn-right) (turn-right)))))

(fn find-index [tbl item]
  "Find index of item in table"
  (var result nil)
  (each [i v (ipairs tbl)]
    (when (= v item)
      (set result i)))
  result)

(fn move-towards-target []
  "Move turtle one step towards the target chest with improved obstacle avoidance"
  (let [dx (- target-chest.x current-pos.x)
        dz (- target-chest.z current-pos.z)]
    
    (print-status (.. "Current: " current-pos.x ", " current-pos.y ", " current-pos.z " facing " current-facing))
    (print-status (.. "Target: " target-chest.x ", " target-chest.y ", " target-chest.z))
    (print-status (.. "Delta: dx=" dx " dz=" dz))
    
    (var moved false)
    (var tried-detour false)
    
    ;; Move in X direction first (East/West) 
    (when (and (not= dx 0) (not moved))
      (if (> dx 0)
          (do 
            (print-status "Need to move East (+X)")
            (face-direction "east")
            (if (move-forward)
                (do
                  (set moved true)
                  (print-status "Successfully moved East"))
                (do
                  (print-status "Blocked moving East - trying detour")
                  (when (try-detour)
                    (set moved true)
                    (set tried-detour true)
                    (print-status "Detour successful")))))
          (do 
            (print-status "Need to move West (-X)")
            (face-direction "west")
            (if (move-forward)
                (do
                  (set moved true)
                  (print-status "Successfully moved West"))
                (do
                  (print-status "Blocked moving West - trying detour")
                  (when (try-detour)
                    (set moved true)
                    (set tried-detour true)
                    (print-status "Detour successful")))))))
    
    ;; Move in Z direction (North/South) only if we didn't move in X
    (when (and (not= dz 0) (not moved))
      (if (> dz 0)
          (do 
            (print-status "Need to move North (+Z)")
            (face-direction "north")
            (if (move-forward)
                (do
                  (set moved true)
                  (print-status "Successfully moved North"))
                (do
                  (print-status "Blocked moving North - trying detour")
                  (when (try-detour)
                    (set moved true)
                    (set tried-detour true)
                    (print-status "Detour successful")))))
          (do 
            (print-status "Need to move South (-Z)")
            (face-direction "south")
            (if (move-forward)
                (do
                  (set moved true)
                  (print-status "Successfully moved South"))
                (do
                  (print-status "Blocked moving South - trying detour")
                  (when (try-detour)
                    (set moved true)
                    (set tried-detour true)
                    (print-status "Detour successful")))))))
    
    (when moved
      (if tried-detour
          (print-status (.. "New position (via detour): " current-pos.x ", " current-pos.y ", " current-pos.z))
          (print-status (.. "New position: " current-pos.x ", " current-pos.y ", " current-pos.z))))
    
    moved))

(fn navigate-to-chest []
  "Navigate turtle to chest position with step-by-step movement and stuck detection"
  (let [initial-distance (calculate-distance current-pos target-chest)]
    (print-status (.. "Initial distance to chest: " initial-distance " blocks"))
    
    (when (> initial-distance 1)
      (print-status "Starting navigation to chest...")
      
      ;; Navigate to a position adjacent to chest
      (var attempts 0)
      (var current-distance initial-distance)
      (var stuck-counter 0)
      (var last-distance initial-distance)
      
      (while (and (> current-distance 1) (< attempts 30))
        (set attempts (+ attempts 1))
        (print-status (.. "Navigation attempt " attempts "/30"))
        
        (let [move-result (move-towards-target)]
          (set current-distance (calculate-distance current-pos target-chest))
          (print-status (.. "Distance after move: " current-distance " blocks"))
          
          ;; Check if we're stuck (distance not improving)
          (if (= current-distance last-distance)
              (do
                (set stuck-counter (+ stuck-counter 1))
                (print-status (.. "Stuck counter: " stuck-counter "/3"))
                
                ;; If stuck for 3 attempts, try random movement
                (when (>= stuck-counter 3)
                  (print-status "Detected stuck condition - trying random detour")
                  (turtle.turnLeft)
                  (if (turtle.forward)
                      (do
                        (print-status "Random detour: moved left")
                        (set current-pos.z (+ current-pos.z 1))) ;; Approximate position update
                      (do
                        (turtle.turnRight)
                        (turtle.turnRight)
                        (when (turtle.forward)
                          (print-status "Random detour: moved right")
                          (set current-pos.z (- current-pos.z 1))) ;; Approximate position update
                        (turtle.turnLeft)))
                  (set stuck-counter 0)
                  (save-config)))
              (set stuck-counter 0))
          
          (set last-distance current-distance))
        
        (os.sleep 0.5))
      
      (if (<= current-distance 1)
          (do
            (print-status "Successfully navigated to chest area!")
            ;; Position turtle adjacent to chest based on coordinates
            (let [dx (- target-chest.x current-pos.x)
                  dy (- target-chest.y current-pos.y)
                  dz (- target-chest.z current-pos.z)]
              ;; If not exactly adjacent, try to position correctly
              (when (not= current-distance 1)
                (print-status "Adjusting final position...")
                ;; Move to be exactly 1 block away from chest
                (if (= current-distance 0)
                    (turtle.back)
                    (when (> current-distance 1)
                      (move-towards-target))))))
          (print-status (.. "Navigation incomplete after " attempts " attempts")))
      
      (save-config))))

(fn test-is-empty-bucket []
  "Test function for is-empty-bucket?"
  (print-status "Testing is-empty-bucket? function...")
  
  ;; Test cases
  (let [test-cases [
    {:item {:name "minecraft:bucket" :count 1} :expected true :desc "Normal empty bucket"}
    {:item {:name "minecraft:water_bucket" :count 1} :expected false :desc "Water bucket"}
    {:item {:name "minecraft:lava_bucket" :count 1} :expected false :desc "Lava bucket"}
    {:item {:name "minecraft:bucket" :count 3} :expected true :desc "Stack of empty buckets"}
    {:item {:name "minecraft:cobblestone" :count 64} :expected false :desc "Non-bucket item"}
    {:item nil :expected false :desc "No item"}
  ]]
    
    (var passed 0)
    (var total (length test-cases))
    
    (each [_ test (ipairs test-cases)]
      (let [result (is-empty-bucket? test.item)]
        (if (= result test.expected)
            (do
              (set passed (+ passed 1))
              (print-status (.. "✓ PASS: " test.desc)))
            (print-status (.. "✗ FAIL: " test.desc " (expected " (tostring test.expected) ", got " (tostring result) ")")))))
    
    (print-status (.. "Tests passed: " passed "/" total))))

(fn main []
  "Main program entry point with coordinate system"
  (clear-screen)
  (print "Empty Bucket Collector v2.0 with GPS")
  (print "====================================")
  (print "")
  
  ;; Load configuration
  (load-config)
  (print-status (.. "Current position: " current-pos.x ", " current-pos.y ", " current-pos.z))
  (print-status (.. "Target chest: " target-chest.x ", " target-chest.y ", " target-chest.z))
  
  ;; Update position if GPS available
  (update-current-position)
  (print "")
  
  ;; Run tests first
  (test-is-empty-bucket)
  (print "")
  
  ;; Always try to navigate to chest if not adjacent
  (let [distance (calculate-distance current-pos target-chest)]
    (if (> distance 1)
        (do
          (print-status (.. "Distance to chest: " distance " blocks - navigating..."))
          (navigate-to-chest))
        (print-status "Already adjacent to chest")))
  
  ;; Debug: Scan all peripherals
  (scan-all-peripherals)
  (print "")
  
  ;; Try to find chest, preferring calculated direction
  (let [preferred-direction (get-direction-to-target)
        directions (if preferred-direction 
                      [preferred-direction "front" "back" "top" "bottom" "left" "right"]
                      ["front" "back" "top" "bottom" "left" "right"])]
    (print-status (.. "Preferred direction: " (or preferred-direction "none")))
    (var chest-found false)
    (var chest nil)
    (var direction nil)
    
    (each [_ dir (ipairs directions)]
      (when (not chest-found)
        (let [found-chest (find-chest dir)]
          (when found-chest
            (set chest found-chest)
            (set direction dir)
            (set chest-found true)
            (print-status (.. "Found chest: " dir))))))
    
    (if chest-found
        (do
          (print-status "Starting bucket collection...")
          (let [collected (collect-empty-buckets chest direction)]
            (if (> collected 0)
                (print-status (.. "Successfully collected " collected " empty buckets!"))
                (print-status "No empty buckets found in chest."))))
        (do
          (print-status "No chest found in any direction!")
          (print-status "Final position check:")
          (print-status (.. "Current: " current-pos.x ", " current-pos.y ", " current-pos.z " facing " current-facing))
          (print-status (.. "Target: " target-chest.x ", " target-chest.y ", " target-chest.z))
          (print-status (.. "Distance: " (calculate-distance current-pos target-chest) " blocks")))))
  
  (print "")
  (print "Collection completed!"))

;; Run the main function
(main)
