---
title: "用roswell寫腳本-實作cat"
description: "製作簡單的 cat 程式"
date: 2017-12-16T00:00:00+08:00
categories: ["common-lisp"]
tags: ["roswell"]
---

## 開始
首先執行
``` sh
$ ros init cl-cat
Successfully generated: cl-cat.ros
```
這樣就自動產生了需要的模板，這裡我的目標是做出一個簡單的 cat ，所以取為 `cl-cat` 。

馬上看一下裡面有什麼：
``` lisp
#!/bin/sh
#|-*- mode:lisp -*-|#
#|
exec ros -Q -- $0 "$@"
|#
(progn ;;init forms
  (ros:ensure-asdf)
  ;;#+quicklisp (ql:quickload '() :silent t)
  )

(defpackage :ros.script.cl-cat.3722427695
  (:use :cl))
(in-package :ros.script.cl-cat.3722427695)

(defun main (&rest argv)
  (declare (ignorable argv)))
;;; vim: set ft=lisp lisp:
```
<!--more-->
跟一般的 common-lisp 程式差不多，只是前面多了點東西，但我們可以先不用管它們，除了...
``` sh
exec ros -Q -- $0 "$@"
```
這裡我們可以把 `-Q` 改成 `+Q` 讓 `roswell` 不會自動載入 `quicklisp` ，可以加快啟動的速度，我們的範例不需要用到 `quicklisp` 所以可以直接關掉。
<!--more-->
## 寫程式
基本的邏輯非常簡單，讀入每個字並輸出到螢幕上即可。
``` lisp
#!/bin/sh
#|-*- mode:lisp -*-|#
#|
exec ros +Q -- $0 "$@"
|#
(progn ;;init forms
  (ros:ensure-asdf)
  ;;#+quicklisp (ql:quickload '() :silent t)
  )

(defpackage :ros.script.test.3721532382
  (:use :cl))
(in-package :ros.script.test.3721532382)

(defun main (&rest argv)
  (mapcar #'(lambda (file)
              (if (not (probe-file file))
                  (format t "lcat: ~A: No such file or directory~%" file)
                  ;; 讀入每個 char 並輸出到 standard output
                  (with-open-file (in file)
                    (do ((i (read-char in nil 'eof) (read-char in nil 'eof)))
                        ((eq i 'eof))
                      (format t "~A" i)))))
          argv))
;;; vim: set ft=lisp lisp:
```
`argv` 讀入的參數會用 list 表示，所以用 `mapcar` 把每份檔案印出來。

現在讓我們執行看看
``` sh
$ time ./clscat.ros t NoThisFile t
123
    uaoeu
 123
Hellolcat: NoThisFile: No such file or directory
123
    uaoeu
 123
Hello
real	0m0.355s
user	0m0.323s
sys	0m0.020s

$ time cat t NoThisFile t
123
    uaoeu
 123
Hellocat: NoThisFile: No such file or directory
123
    uaoeu
 123
Hello
real	0m0.003s
user	0m0.000s
sys	0m0.000s
```
跟真正的 `cat` 幾乎一模一樣！

## 編譯
現在我們完成了一個 `cat` 不過有一個嚴重的問題，那就是太慢了！！！
**0.355s** 足夠產生人體能感到的延遲，這主要是因為開啟 common-lisp 編譯器本身就需要時間，我們可以藉由將腳本編譯成可執行檔解決這個問題。

藉由 `roswell` 我們可以很輕易的完成這件事
``` sh
$ ros build cl-cat.ros
```

讓我們再試一次
``` sh
$ time ./cl-cat t NoThisFile t
123
    uaoeu
 123
Hellolcat: NoThisFile: No such file or directory
123
    uaoeu
 123
Hello
real	0m0.016s
user	0m0.010s
sys	0m0.003s
```
快了大約 **20** 倍！！！

你可能會發現編譯出來的檔案 **非常大** （在我這裡是 44.6 MB），這是正常的，因為它包含了 lisp 執行的環境，目前我還沒找到很好的方法解決這個問題。
## 更方便的使用程式
現在我們完成了需要做的事，運作的也不錯，不過我們需要知道執行檔的目錄，才能執行，我們可以加進 `$PATH` 省去這個麻煩。

將你的 `script` 編譯出來的檔案，放在一個固定的位置，最好是選擇 `~/.roswell/bin` ，有一些依賴 `roswell` 的程式會將執行檔放在這邊，所以不管是否自己有寫程式，最好還是將這個位置加進去 `$PATH` 裡。

在 `shell` 中輸入
``` sh
PATH`$PATH:~/.roswell/bin
```

要自動加入的話可以放進 `~/.bash_profile` 裡面。

現在可以直接使用了
``` sh
$ time cl-cat t NoThisFile t
123
    uaoeu
 123
Hellolcat: NoThisFile: No such file or directory
123
    uaoeu
 123
Hello
real	0m0.016s
user	0m0.010s
sys	0m0.003s
```

## Reference
Common Lisp Scripting with Roswell: https://gist.github.com/fukamachi/94f067a22776bede563c
