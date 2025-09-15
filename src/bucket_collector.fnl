;; Bucket Collection Script
;; Main bucket collection functionality

(local turtle turtle)
(local peripheral peripheral)
(local utils (require "utils"))

;; Configuration
(var current_pos {:x -1838 :y 64 :z -128})
(var target_chest {:x -1836 :y 63 :z -127})
(var current_facing "east")
(local config_file "bucket_collector_config.txt")

(fn inspect_direction [direction]
  "Inspect block in specified direction using turtle.inspect"
  (let [(has_block block_data) (if (= direction "front") (turtle.inspect)
                                   (= direction "up") (turtle.inspectUp)
                                   (= direction "down") (turtle.inspectDown)
                                   (values false {}))]
    (if has_block
        {:block_name block_data.name :block block_data}
        {:block_name nil :block nil})))

(fn find_chest [direction]
  "Find chest using both peripheral and inspect methods"
  (let [chest_type (peripheral.getType direction)
        inspect_result (if (or (= direction "front") (= direction "up") (= direction "down"))
                           (inspect_direction direction)
                           {:block_name nil})]
    
    (utils.print_status (.. direction "を確認中:"))
    (utils.print_status (.. "  周辺機器: " (or chest_type "なし")))
    (utils.print_status (.. "  調査: " (or inspect_result.block_name "なし")))
    
    (let [is_chest_peripheral (or (= chest_type "minecraft:chest")
                                  (= chest_type "minecraft:trapped_chest")
                                  (= chest_type "ironchests:iron_chest")
                                  (= chest_type "ironchests:gold_chest")
                                  (= chest_type "ironchests:diamond_chest"))
          is_chest_inspect (utils.is_chest_block inspect_result.block_name)]
      
      (if (or is_chest_peripheral is_chest_inspect)
          (do
            (utils.print_status (.. "✓ " direction "でチェスト発見!"))
            (let [wrapped (peripheral.wrap direction)]
              (if wrapped 
                  wrapped
                  {:direction direction :type "manual"})))
          (do
            (utils.print_status (.. "✗ " direction "にチェストなし"))
            nil)))))

(fn collect_empty_buckets [chest direction]
  "Collect empty buckets from chest"
  (if (and chest (= chest.type "manual"))
      ;; Manual chest handling
      (do
        (utils.print_status "手動チェスト検出 - アイテム回収試行中")
        (var collected 0)
        (var attempts 0)
        
        (while (and (< attempts 64) (< collected 16))
          (set attempts (+ attempts 1))
          (let [empty_slot (utils.find_empty_inventory_slot)]
            (if empty_slot
                (do
                  (turtle.select empty_slot)
                  (let [success (if (= direction "front") (turtle.suck)
                                    (= direction "up") (turtle.suckUp)
                                    (= direction "down") (turtle.suckDown)
                                    false)]
                    (if success
                        (let [item (turtle.getItemDetail)]
                          (if (and item (utils.is_empty_bucket item))
                              (do
                                (set collected (+ collected item.count))
                                (utils.print_status (.. item.count "個の空バケツを回収")))
                              (when item
                                (utils.print_status (.. "非バケツアイテムを回収: " item.name)))))
                        (lua "break"))))
                (lua "break"))))
        
        (utils.print_status (.. "手動回収完了: " collected "個の空バケツ"))
        collected)
      
      ;; Normal peripheral chest
      (let [items (if chest (chest.list) {})]
        (var collected 0)
        
        (each [slot item (pairs items)]
          (when (utils.is_empty_bucket item)
            (let [empty_slot (utils.find_empty_inventory_slot)]
              (if empty_slot
                  (do
                    (turtle.select empty_slot)
                    (if (= direction "front") (turtle.suck)
                        (= direction "up") (turtle.suckUp)
                        (= direction "down") (turtle.suckDown)
                        false)
                    (set collected (+ collected 1))
                    (utils.print_status (.. "スロット" slot "から空バケツを回収")))
                  (do
                    (utils.print_status "インベントリ満杯！")
                    (lua "break"))))))
        
        (utils.print_status (.. "合計回収した空バケツ: " collected "個"))
        collected)))

(fn save_config []
  "Save current configuration"
  (let [config {:current_pos current_pos
                :target_chest target_chest  
                :current_facing current_facing}]
    (utils.save_config config config_file)))

(fn load_config []
  "Load configuration"
  (let [config (utils.load_config config_file)]
    (when config
      (set current_pos config.current_pos)
      (set target_chest config.target_chest)
      (when config.current_facing
        (set current_facing config.current_facing)))))

(fn main []
  "Main bucket collection program"
  (utils.clear_screen)
  (print "空バケツ回収 v1.0")
  (print "================")
  (print "")
  
  (load_config)
  (utils.print_status (.. "現在位置: " current_pos.x ", " current_pos.y ", " current_pos.z))
  (utils.print_status (.. "目標チェスト: " target_chest.x ", " target_chest.y ", " target_chest.z))
  
  ;; Check fuel
  (utils.check_fuel)
  (utils.refuel_if_needed)
  
  ;; Try to find chest in all directions
  (let [directions ["front" "back" "top" "bottom" "left" "right"]]
    (var chest_found false)
    (var chest nil)
    (var direction nil)
    
    (each [_ dir (ipairs directions)]
      (when (not chest_found)
        (let [found_chest (find_chest dir)]
          (when found_chest
            (set chest found_chest)
            (set direction dir)
            (set chest_found true)))))
    
    (if chest_found
        (do
          (utils.print_status "バケツ回収を開始します...")
          (let [collected (collect_empty_buckets chest direction)]
            (if (> collected 0)
                (utils.print_status (.. collected "個の空バケツを回収成功！"))
                (utils.print_status "チェストに空バケツが見つかりませんでした"))))
        (utils.print_status "どの方向にもチェストが見つかりませんでした！")))
  
  (print "")
  (print "回収完了！"))

;; Run the main function
(main)