;; Optimized Bucket Collector
;; High efficiency bucket collection from down chest

(local turtle turtle)

(fn is_empty_bucket [item]
  "Check if item is an empty bucket"
  (and item (= item.name "minecraft:bucket")))

(fn find_empty_slot []
  "Find first empty inventory slot"
  (for [slot 1 16]
    (turtle.select slot)
    (when (not (turtle.getItemDetail))
      (lua "return slot")))
  nil)

(fn stack_buckets []
  "Stack buckets together for inventory efficiency"
  (var stacked 0)
  (for [slot1 1 15]
    (turtle.select slot1)
    (let [item1 (turtle.getItemDetail)]
      (when (and item1 (is_empty_bucket item1) (< item1.count 64))
        (for [slot2 (+ slot1 1) 16]
          (let [item2 (turtle.getItemDetail slot2)]
            (when (and item2 (is_empty_bucket item2))
              (turtle.select slot2)
              (turtle.transferTo slot1)
              (set stacked (+ stacked 1))))))))
  stacked)

(fn batch_return_non_buckets []
  "Return all non-bucket items in one batch"
  (var returned 0)
  (for [slot 1 16]
    (turtle.select slot)
    (let [item (turtle.getItemDetail)]
      (when (and item (not (is_empty_bucket item)))
        (turtle.dropDown)
        (set returned (+ returned 1)))))
  returned)

(fn collect_phase []
  "Fast collection phase - grab everything first"
  (var collected 0)
  (var attempts 0)
  
  (print "Phase 1: Fast collection...")
  
  (while (and (< attempts 200) (find_empty_slot))
    (set attempts (+ attempts 1))
    (let [empty_slot (find_empty_slot)]
      (when empty_slot
        (turtle.select empty_slot)
        (if (turtle.suckDown)
            (set collected (+ collected 1))
            (lua "break"))))
    
    ;; Stack every 16 items for efficiency
    (when (= (% collected 16) 0)
      (stack_buckets)))
  
  (print (.. "Collected " collected " items in " attempts " attempts"))
  collected)

(fn sort_phase []
  "Sorting phase - return non-buckets, count buckets"
  (print "Phase 2: Sorting items...")
  
  (let [returned (batch_return_non_buckets)]
    (print (.. "Returned " returned " non-bucket items")))
  
  ;; Final stacking
  (let [stacked (stack_buckets)]
    (when (> stacked 0)
      (print (.. "Stacked " stacked " bucket groups"))))
  
  ;; Count final buckets
  (var total_buckets 0)
  (for [slot 1 16]
    (turtle.select slot)
    (let [item (turtle.getItemDetail)]
      (when (and item (is_empty_bucket item))
        (set total_buckets (+ total_buckets item.count)))))
  
  total_buckets)

(fn main []
  (print "Optimized Bucket Collector v2.0")
  (print "===============================")
  (print "")
  
  (if (not (turtle.detectDown))
      (do
        (print "ERROR: No chest below!")
        (lua "return"))
      (do
        (let [start_time (os.clock)]
          
          ;; Phase 1: Fast collection
          (let [items_collected (collect_phase)]
            
            ;; Phase 2: Smart sorting
            (let [bucket_count (sort_phase)]
              
              (let [end_time (os.clock)
                    duration (- end_time start_time)]
                
                (print "")
                (print "=== RESULTS ===")
                (print (.. "Empty buckets collected: " bucket_count))
                (print (.. "Time taken: " (string.format "%.2f" duration) " seconds"))
                (print (.. "Efficiency: " (string.format "%.1f" (/ bucket_count duration)) " buckets/sec"))
                
                ;; Show final inventory
                (print "")
                (print "Final inventory:")
                (for [slot 1 16]
                  (turtle.select slot)
                  (let [item (turtle.getItemDetail)]
                    (when item
                      (print (.. "Slot " slot ": " item.name " x" item.count)))))
                
                (print "")
                (print "Collection optimized!"))))))))

;; Run immediately
(main)