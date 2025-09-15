;; Chest Detection Test Script
;; Simple standalone chest detection and testing

(local turtle turtle)
(local peripheral peripheral)

(fn clear_screen []
  "Clear the terminal screen"
  (term.clear)
  (term.setCursorPos 1 1))

(fn chest_cmd []
  "Quick chest test command"
  (print "=== クイックチェストテスト ===")
  (each [_ dir (ipairs ["front" "back" "left" "right" "top" "bottom"])]
    (let [ptype (peripheral.getType dir)]
      (print (.. dir ": " (or ptype "なし"))))
    (let [chest (peripheral.wrap dir)]
      (when chest
        (print (.. dir "でチェスト発見"))
        (let [items (chest.list)]
          (print (.. "アイテム数: " (length items)))))))
  (print "テスト完了"))

(fn scan_cmd []
  "Scan all peripherals"
  (print "=== 周辺機器スキャン ===")
  (let [directions ["front" "back" "top" "bottom" "left" "right"]]
    (each [_ dir (ipairs directions)]
      (let [ptype (peripheral.getType dir)]
        (print (.. dir ": " (or ptype "なし"))))))
  (let [all_peripherals (peripheral.getNames)]
    (print (.. "全周辺機器: " (table.concat all_peripherals ", ")))
    (each [_ name (ipairs all_peripherals)]
      (print (.. "  " name " = " (peripheral.getType name))))))

(fn suck_test []
  "Manual suck test"
  (print "手動回収テスト中...")
  (let [directions {"front" turtle.suck "up" turtle.suckUp "down" turtle.suckDown}]
    (each [dir func (pairs directions)]
      (print (.. dir "をテスト中..."))
      (if (func)
          (print (.. "  " dir "から回収成功"))
          (print (.. "  " dir "からは何もなし"))))))

(fn basic_tests []
  "Basic turtle detection tests"
  (print "=== 基本タートルテスト ===")
  (print (.. "turtle.detect(): " (tostring (turtle.detect))))
  (print (.. "turtle.detectUp(): " (tostring (turtle.detectUp))))
  (print (.. "turtle.detectDown(): " (tostring (turtle.detectDown)))))

(fn main []
  "Main chest test program"
  (clear_screen)
  (print "チェスト検知テスト v1.0")
  (print "====================")
  (print "")
  
  (print "利用可能コマンド:")
  (print "1 - クイックチェストテスト")
  (print "2 - 周辺機器スキャン") 
  (print "3 - 手動回収テスト")
  (print "4 - 基本検知テスト")
  (print "選択してください (1-4): ")
  
  (let [choice (read)]
    (if (= choice "1") (chest_cmd)
        (= choice "2") (scan_cmd)
        (= choice "3") (suck_test)
        (= choice "4") (basic_tests)
        (print "無効な選択です"))))

;; Run the main function
(main)