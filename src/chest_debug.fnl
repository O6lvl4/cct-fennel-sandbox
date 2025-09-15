;; Chest Debug Script - Clean English Version
;; Simple chest detection for CC:Tweaked

(local turtle turtle)
(local peripheral peripheral)

(fn main []
  (print "Chest Debug v1.0")
  (print "================")
  (print "")
  
  (print "Testing chest detection...")
  (print "")
  
  ;; Test all directions
  (let [directions ["front" "back" "left" "right" "top" "bottom"]]
    (each [_ dir (ipairs directions)]
      (let [ptype (peripheral.getType dir)]
        (print (.. dir ": " (if ptype ptype "none"))))
      (let [chest (peripheral.wrap dir)]
        (when chest
          (print (.. "  -> CHEST FOUND at " dir))
          (print (.. "  -> Items: " (length (chest.list))))))))
  
  (print "")
  (print "Manual suck test:")
  (print "Testing front...")
  (if (turtle.suck)
      (print "  -> Sucked something from front")
      (print "  -> Nothing to suck from front"))
      
  (print "Testing up...")
  (if (turtle.suckUp)
      (print "  -> Sucked something from up")  
      (print "  -> Nothing to suck from up"))
      
  (print "")
  (print "Basic detection:")
  (print (.. "Front blocked: " (if (turtle.detect) "yes" "no")))
  (print (.. "Up blocked: " (if (turtle.detectUp) "yes" "no")))
  (print (.. "Down blocked: " (if (turtle.detectDown) "yes" "no")))
  
  (print "")
  (print "Test complete"))

;; Run immediately
(main)