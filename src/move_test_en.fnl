;; Movement Test Script (English)
;; Test turtle movement and navigation

(local turtle turtle)
(local term term)

(fn clear_screen []
  "Clear the terminal screen"
  (term.clear)
  (term.setCursorPos 1 1))

(fn move_forward_test []
  "Test forward movement"
  (print "Testing forward movement...")
  (if (turtle.forward)
    (print "Forward movement OK")
    (print "Cannot move forward - blocked")))

(fn move_back_test []
  "Test backward movement"
  (print "Testing backward movement...")
  (if (turtle.back)
    (print "Backward movement OK")
    (print "Cannot move backward")))

(fn turn_test []
  "Test turning"
  (print "Testing rotation...")
  (turtle.turnLeft)
  (print "Left turn complete")
  (turtle.turnRight)
  (print "Right turn complete")
  (print "Back to original direction"))

(fn movement_loop []
  "Test continuous movement"
  (print "Movement loop test (5 steps)")
  (for [i 1 5]
    (print (.. "Step " i "/5"))
    (if (turtle.forward)
        (print "  Forward OK")
        (do
          (print "  Forward blocked - trying detour")
          (turtle.turnLeft)
          (if (turtle.forward)
              (do
                (print "  Left detour OK")
                (turtle.turnRight))
              (do
                (turtle.turnRight)
                (turtle.turnRight)
                (if (turtle.forward)
                    (do
                      (print "  Right detour OK")
                      (turtle.turnLeft))
                    (do
                      (turtle.turnLeft)
                      (print "  All directions blocked")))))))
    (os.sleep 1)))

(fn detection_test []
  "Test detection in all directions"
  (print "Obstacle detection test")
  (print (.. "Front: " (if (turtle.detect) "blocked" "clear")))
  (print (.. "Up: " (if (turtle.detectUp) "blocked" "clear")))
  (print (.. "Down: " (if (turtle.detectDown) "blocked" "clear"))))

(fn inspect_test []
  "Test block inspection"
  (print "Block inspection test")
  
  (let [(has_block block_data) (turtle.inspect)]
    (if has_block
        (print (.. "Front block: " block_data.name))
        (print "Front: nothing")))
        
  (let [(has_block block_data) (turtle.inspectUp)]
    (if has_block
        (print (.. "Up block: " block_data.name))
        (print "Up: nothing")))
        
  (let [(has_block block_data) (turtle.inspectDown)]
    (if has_block
        (print (.. "Down block: " block_data.name))
        (print "Down: nothing"))))

(fn main []
  "Main movement test program"
  (clear_screen)
  (print "Movement Test v1.0")
  (print "==================")
  (print "")
  
  (print "Available tests:")
  (print "1 - Forward movement test")
  (print "2 - Backward movement test")
  (print "3 - Rotation test")
  (print "4 - Movement loop test")
  (print "5 - Obstacle detection test")
  (print "6 - Block inspection test")
  (print "Enter choice (1-6): ")
  
  (let [choice (read)]
    (if (= choice "1") (move_forward_test)
        (= choice "2") (move_back_test)
        (= choice "3") (turn_test)
        (= choice "4") (movement_loop)
        (= choice "5") (detection_test)
        (= choice "6") (inspect_test)
        (print "Invalid choice"))))

;; Run the main function
(main)