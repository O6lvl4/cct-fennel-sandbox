;; CC:Tweaked Empty Bucket Collector
;; Collects only empty buckets from specified chest

(local turtle turtle)
(local peripheral peripheral)
(local term term)

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
  "Find chest in specified direction"
  (let [chest-type (if (= direction "front") 
                       (peripheral.getType "front")
                       (if (= direction "back")
                           (peripheral.getType "back")
                           (if (= direction "top")
                               (peripheral.getType "top")
                               (if (= direction "bottom")
                                   (peripheral.getType "bottom")
                                   nil))))]
    (if (or (= chest-type "minecraft:chest")
            (= chest-type "minecraft:trapped_chest")
            (= chest-type "ironchests:iron_chest")
            (= chest-type "ironchests:gold_chest")
            (= chest-type "ironchests:diamond_chest"))
        (peripheral.wrap direction)
        nil)))

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
  "Main program entry point"
  (clear-screen)
  (print "Empty Bucket Collector v1.0")
  (print "===========================")
  (print "")
  
  ;; Run tests first
  (test-is-empty-bucket)
  (print "")
  
  ;; Try to find chest in each direction
  (let [directions ["front" "back" "top" "bottom"]]
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
        (print-status "No chest found in any direction!")))
  
  (print "")
  (print "Collection completed!"))

;; Run the main function
(main)
