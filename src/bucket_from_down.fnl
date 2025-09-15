;; Bucket Collector from Down Chest
;; Collect only empty buckets from chest below

(local turtle turtle)

(fn is_empty_bucket [item]
  "Check if item is an empty bucket"
  (and item
       (= item.name "minecraft:bucket")
       (> item.count 0)))

(fn find_empty_slot []
  "Find first empty inventory slot"
  (for [slot 1 16]
    (turtle.select slot)
    (let [item (turtle.getItemDetail)]
      (when (not item)
        (lua "return slot"))))
  nil)

(fn return_non_bucket [slot]
  "Return non-bucket item to chest"
  (turtle.select slot)
  (let [item (turtle.getItemDetail)]
    (when item
      (print (.. "Returning " item.name " to chest"))
      (turtle.dropDown)
      (os.sleep 0.1))))

(fn main []
  (print "Bucket Collector from Down v1.0")
  (print "===============================")
  (print "")
  
  (if (not (turtle.detectDown))
      (do
        (print "ERROR: No chest detected below!")
        (print "Place turtle above chest and try again"))
      (do
        (print "Chest detected below turtle")
        (print "Starting bucket collection...")
        (print "")
        
        (var buckets_collected 0)
        (var attempts 0)
        (var items_returned 0)
        
        (while (< attempts 64)
          (set attempts (+ attempts 1))
          (let [empty_slot (find_empty_slot)]
            (if empty_slot
                (do
                  (turtle.select empty_slot)
                  (if (turtle.suckDown)
                      (let [item (turtle.getItemDetail)]
                        (if (and item (is_empty_bucket item))
                            (do
                              (set buckets_collected (+ buckets_collected item.count))
                              (print (.. "Collected " item.count " empty bucket(s) - Total: " buckets_collected)))
                            (if item
                                (do
                                  (print (.. "Found " item.name " (not bucket) - returning to chest"))
                                  (return_non_bucket empty_slot)
                                  (set items_returned (+ items_returned 1)))
                                (print "Collected nothing"))))
                      (do
                        (print "Chest is empty")
                        (lua "break"))))
                (do
                  (print "Inventory full!")
                  (lua "break"))))
          
          (when (> attempts 32)
            (os.sleep 0.1)))
        
        (print "")
        (print "=== COLLECTION COMPLETE ===")
        (print (.. "Empty buckets collected: " buckets_collected))
        (print (.. "Non-bucket items returned: " items_returned))
        (print (.. "Total attempts: " attempts))
        
        (print "")
        (print "Current inventory (buckets only):")
        (for [slot 1 16]
          (turtle.select slot)
          (let [item (turtle.getItemDetail)]
            (when (and item (is_empty_bucket item))
              (print (.. "Slot " slot ": " item.name " x" item.count)))))
        
        (print "")
        (print "Bucket collection finished!"))))

;; Run immediately
(main)