;; Utility Functions
;; Common helper functions for CC:Tweaked scripts

(local turtle turtle)
(local fs fs)
(local term term)

(fn clear_screen []
  "Clear the terminal screen"
  (term.clear)
  (term.setCursorPos 1 1))

(fn print_status [message]
  "Print a status message with timestamp"
  (let [time (os.date "%H:%M:%S")]
    (print (.. "[" time "] " message))))

(fn is_empty_bucket [item]
  "Check if item is an empty bucket"
  (and item
       (= item.name "minecraft:bucket")
       (or (= item.count nil) (= item.count 0) (>= item.count 1))))

(fn is_chest_block [block_name]
  "Check if block name represents a chest"
  (or (= block_name "minecraft:chest")
      (= block_name "minecraft:trapped_chest") 
      (= block_name "ironchests:iron_chest")
      (= block_name "ironchests:gold_chest")
      (= block_name "ironchests:diamond_chest")
      (= block_name "minecraft:ender_chest")))

(fn find_empty_inventory_slot []
  "Find first empty inventory slot"
  (for [slot 1 16]
    (turtle.select slot)
    (let [item (turtle.getItemDetail)]
      (when (not item)
        (lua "return slot"))))
  nil)

(fn find_index [tbl item]
  "Find index of item in table"
  (var result nil)
  (each [i v (ipairs tbl)]
    (when (= v item)
      (set result i)))
  result)

(fn calculate_distance [pos1 pos2]
  "Calculate Manhattan distance between two positions (X and Z only)"
  (+ (math.abs (- pos1.x pos2.x))
     (math.abs (- pos1.z pos2.z))))

(fn save_config [config config_file]
  "Save configuration to file"
  (let [file (fs.open config_file "w")]
    (when file
      (file.write (textutils.serialize config))
      (file.close)
      (print_status "設定をファイルに保存しました"))))

(fn load_config [config_file]
  "Load configuration from file"
  (when (fs.exists config_file)
    (let [file (fs.open config_file "r")]
      (when file
        (let [data (file.readAll)]
          (file.close)
          (let [config (textutils.unserialize data)]
            (when config
              (print_status "設定をファイルから読み込みました")
              config)))))))

(fn get_gps_position []
  "Get current GPS position"
  (let [x (gps.locate 5)]
    (if x
        (let [y (select 2 (gps.locate 5))
              z (select 3 (gps.locate 5))]
          {:x x :y y :z z})
        nil)))

(fn check_fuel []
  "Check turtle fuel level"
  (let [fuel (turtle.getFuelLevel)]
    (print_status (.. "燃料レベル: " fuel))
    (when (< fuel 10)
      (print_status "警告: 燃料が不足しています"))
    fuel))

(fn refuel_if_needed []
  "Refuel turtle if fuel is low"
  (let [fuel (turtle.getFuelLevel)]
    (when (< fuel 10)
      (print_status "燃料補給を試行中...")
      (for [slot 1 16]
        (turtle.select slot)
        (let [item (turtle.getItemDetail)]
          (when (and item (or (= item.name "minecraft:coal") 
                              (= item.name "minecraft:charcoal")
                              (= item.name "minecraft:lava_bucket")))
            (if (turtle.refuel 1)
                (do
                  (print_status "燃料補給成功")
                  (lua "break"))
                (print_status "燃料補給失敗"))))))))

;; Export functions for use in other scripts
{:clear_screen clear_screen
 :print_status print_status
 :is_empty_bucket is_empty_bucket
 :is_chest_block is_chest_block
 :find_empty_inventory_slot find_empty_inventory_slot
 :find_index find_index
 :calculate_distance calculate_distance
 :save_config save_config
 :load_config load_config
 :get_gps_position get_gps_position
 :check_fuel check_fuel
 :refuel_if_needed refuel_if_needed}