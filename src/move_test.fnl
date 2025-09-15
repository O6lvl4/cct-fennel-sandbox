;; Movement Test Script
;; Test turtle movement and navigation

(local turtle turtle)

(fn clear_screen []
  "Clear the terminal screen"
  (term.clear)
  (term.setCursorPos 1 1))

(fn move_forward_test []
  "Test forward movement"
  (print "前進テスト中...")
  (if (turtle.forward)
    (print "前進成功")
    (print "前進不可 - 障害物あり")))

(fn move_back_test []
  "Test backward movement"
  (print "後退テスト中...")
  (if (turtle.back)
    (print "後退成功")
    (print "後退不可")))

(fn turn_test []
  "Test turning"
  (print "回転テスト中...")
  (turtle.turnLeft)
  (print "左回転完了")
  (turtle.turnRight)
  (print "右回転完了")
  (print "元の向きに戻りました"))

(fn movement_loop []
  "Test continuous movement"
  (print "移動ループテスト (5回)")
  (for [i 1 5]
    (print (.. "ステップ " i "/5"))
    (if (turtle.forward)
        (print "  前進成功")
        (do
          (print "  前進失敗 - 回避試行")
          (turtle.turnLeft)
          (if (turtle.forward)
              (do
                (print "  左迂回成功")
                (turtle.turnRight))
              (do
                (turtle.turnRight)
                (turtle.turnRight)
                (if (turtle.forward)
                    (do
                      (print "  右迂回成功")
                      (turtle.turnLeft))
                    (do
                      (turtle.turnLeft)
                      (print "  全方向ブロック")))))))
    (os.sleep 1)))

(fn detection_test []
  "Test detection in all directions"
  (print "障害物検知テスト")
  (print (.. "前方: " (if (turtle.detect) "ブロックあり" "なし")))
  (print (.. "上方: " (if (turtle.detectUp) "ブロックあり" "なし")))
  (print (.. "下方: " (if (turtle.detectDown) "ブロックあり" "なし"))))

(fn inspect_test []
  "Test block inspection"
  (print "ブロック調査テスト")
  
  (let [(has_block block_data) (turtle.inspect)]
    (if has_block
        (print (.. "前方ブロック: " block_data.name))
        (print "前方: 何もなし")))
        
  (let [(has_block block_data) (turtle.inspectUp)]
    (if has_block
        (print (.. "上方ブロック: " block_data.name))
        (print "上方: 何もなし")))
        
  (let [(has_block block_data) (turtle.inspectDown)]
    (if has_block
        (print (.. "下方ブロック: " block_data.name))
        (print "下方: 何もなし"))))

(fn main []
  "Main movement test program"
  (clear_screen)
  (print "移動テスト v1.0")
  (print "==============")
  (print "")
  
  (print "利用可能テスト:")
  (print "1 - 前進テスト")
  (print "2 - 後退テスト")
  (print "3 - 回転テスト")
  (print "4 - 移動ループテスト")
  (print "5 - 障害物検知テスト")
  (print "6 - ブロック調査テスト")
  (print "選択してください (1-6): ")
  
  (let [choice (read)]
    (if (= choice "1") (move_forward_test)
        (= choice "2") (move_back_test)
        (= choice "3") (turn_test)
        (= choice "4") (movement_loop)
        (= choice "5") (detection_test)
        (= choice "6") (inspect_test)
        (print "無効な選択です"))))

;; Run the main function
(main)