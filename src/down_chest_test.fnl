;; Down Chest Test - Test suckDown functionality

(local turtle turtle)

(fn main []
  (print "Down Chest Test v1.0")
  (print "====================")
  (print "")
  
  (print "Testing down direction...")
  (print (.. "Down blocked: " (if (turtle.detectDown) "yes" "no")))
  
  (print "")
  (print "Attempting to suck from down chest...")
  
  (var attempts 0)
  (var items_collected 0)
  
  (while (< attempts 10)
    (set attempts (+ attempts 1))
    (print (.. "Attempt " attempts "/10"))
    
    (if (turtle.suckDown)
        (do
          (set items_collected (+ items_collected 1))
          (print "  -> SUCCESS! Item collected")
          (let [item (turtle.getItemDetail)]
            (when item
              (print (.. "  -> Item: " item.name " x" item.count)))))
        (do
          (print "  -> Nothing to collect")
          (lua "break")))
    
    (os.sleep 0.5))
  
  (print "")
  (print (.. "Total items collected: " items_collected))
  
  (print "")
  (print "Current inventory:")
  (for [slot 1 16]
    (turtle.select slot)
    (let [item (turtle.getItemDetail)]
      (when item
        (print (.. "Slot " slot ": " item.name " x" item.count)))))
  
  (print "")
  (print "Test complete"))

;; Run immediately
(main)