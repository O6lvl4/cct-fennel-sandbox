;; Chest Detection Test Script (English)
;; Simple standalone chest detection and testing

(local turtle turtle)
(local peripheral peripheral)
(local term term)

(fn clear_screen []
  "Clear the terminal screen"
  (term.clear)
  (term.setCursorPos 1 1))

(fn chest_cmd []
  "Quick chest test command"
  (print "=== QUICK CHEST TEST ===")
  (each [_ dir (ipairs ["front" "back" "left" "right" "top" "bottom"])]
    (let [ptype (peripheral.getType dir)]
      (print (.. dir ": " (or ptype "none"))))
    (let [chest (peripheral.wrap dir)]
      (when chest
        (print (.. "Found chest at " dir))
        (let [items (chest.list)]
          (print (.. "Items: " (length items)))))))
  (print "Test complete"))

(fn scan_cmd []
  "Scan all peripherals"
  (print "=== PERIPHERAL SCAN ===")
  (let [directions ["front" "back" "top" "bottom" "left" "right"]]
    (each [_ dir (ipairs directions)]
      (let [ptype (peripheral.getType dir)]
        (print (.. dir ": " (or ptype "none"))))))
  (let [all_peripherals (peripheral.getNames)]
    (print (.. "All peripherals: " (table.concat all_peripherals ", ")))
    (each [_ name (ipairs all_peripherals)]
      (print (.. "  " name " = " (peripheral.getType name))))))

(fn suck_test []
  "Manual suck test"
  (print "Testing manual collection...")
  (let [directions {"front" turtle.suck "up" turtle.suckUp "down" turtle.suckDown}]
    (each [dir func (pairs directions)]
      (print (.. "Testing " dir "..."))
      (if (func)
          (print (.. "  Success from " dir))
          (print (.. "  Nothing from " dir))))))

(fn basic_tests []
  "Basic turtle detection tests"
  (print "=== BASIC TURTLE TESTS ===")
  (print (.. "turtle.detect(): " (tostring (turtle.detect))))
  (print (.. "turtle.detectUp(): " (tostring (turtle.detectUp))))
  (print (.. "turtle.detectDown(): " (tostring (turtle.detectDown)))))

(fn main []
  "Main chest test program"
  (clear_screen)
  (print "Chest Detection Test v1.0")
  (print "=========================")
  (print "")
  
  (print "Available commands:")
  (print "1 - Quick chest test")
  (print "2 - Peripheral scan") 
  (print "3 - Manual suck test")
  (print "4 - Basic detection test")
  (print "Enter choice (1-4): ")
  
  (let [choice (read)]
    (if (= choice "1") (chest_cmd)
        (= choice "2") (scan_cmd)
        (= choice "3") (suck_test)
        (= choice "4") (basic_tests)
        (print "Invalid choice"))))

;; Run the main function
(main)