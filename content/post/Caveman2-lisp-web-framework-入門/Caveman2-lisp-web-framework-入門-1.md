---
title: "Caveman2-lisp-web-framework-入門-1"
description: "URL routing"
date: 2018-07-16T22:45:32+08:00
categories: ["common lisp"]
tags: ["caveman2"]
---

## URL routing
這裡介紹網站最基本的功能，根據不同的 URL ，呈現不同的頁面，首先打開你的 `src/web.lisp` 的檔案

``` lisp
;;
;; Routing rules

(defroute "/" ()
  (render #P"index.html"))
```
<!--more-->
你可以看到預先幫你寫好一個 route 了，我們首先建立一個最簡單的頁面，連入 `http://127.0.0.1:8000/`，會看到 `helloworld`，這行字。

``` lisp
;; (defroute "/" ()
;;    (render #P"index.html"))
  
(defroute "/" ()
  (format nil "helloworld"))
```

如過不清楚如何啟動 server ，可以參考下圖右方的操作。  
*Tip: 在一個函數的末端，也就是畫面所在的位置，輸入 <kbd>C-c C-c</kbd> 就可以編譯一個函數。*

![hello world](/images/Caveman2-lisp-web-framework-入門/1-1.png)

現在打開啟動 server 並打開 `http://127.0.0.1:8000/` ，應該就可以看到 `helloworld`了。
![hello world](/images/Caveman2-lisp-web-framework-入門/1-2.png)

## 傳入參數

Caveman2 提供了多種傳參數的方式，以下列出四種方式

下面這種方式表示 `/?name=...`，會顯示出 `Hello, ...`

``` lisp
(defroute "/" (&key (|name| ""))
  (format nil "Hello, ~A" |name|))
```

也可以偽裝成靜態的網址，像是下面這樣的方式，連入 `/...` ，也會顯示相同的畫面

``` lisp
(defroute "/:name" (&key name)
  (format nil "Hello, ~A" name))
```

也能夠使用正規表達式

``` lisp
(defroute ("/hello/([\\w]+)" :regexp t) (&key captures)
  (format nil "Hello, ~A!" (first captures)))
```

或則使用萬用字元做匹配

``` lisp
(defroute "/say/*/to/*" (&key splat)
  ; matches /say/hello/to/world
  splat ;=> ("hello" "world")
  ))
```

## 不同的 method

當然，你也可以使用不同的 method，像是 `post` ，下面提供了一個簡單的表單進行測試

``` lisp
(defroute ("/" :method :GET) ()
  (format nil "
    <form action=\"/hello/post\" method=\"post\">
      <input name=\"name\" type=\"text\">
      <input type=\"submit\">
    </form>"))

(defroute ("/hello/post" :method :POST) (&key |name|)
  (format nil "Hello, ~A" |name|))
```

這裡的參數 `|name|` ，跟前面的不一樣，用 `|` 括了起來，如果你把它拿掉，會發現不管你輸入什麼，最後的結果都是 `Hello, NIL`  

只要把兩種寫法，用 `macroexpand-1` 展開後，就可以知道為什麼了  
*Tip: macroexpand-1 在 slime 中的快捷鍵是 <kbd>C-c C-m</kbd>*  

第一種寫法

``` lisp
(macroexpand-1
 `(defroute ("/hello/post" :method :POST) (&key name)
  (format nil "Hello, ~A" name)))

;; 展開 macro 後的結果
(SETF (APPLY #'NINGLE.APP:ROUTE
             (CONS
              (CAVEMAN2.APP:FIND-PACKAGE-APP
               #<PACKAGE "CAVEMAN2-TUTORIAL.WEB">)
              (LIST "/hello/post" :METHOD :POST)))
        (LAMBDA (#:PARAMS1004)
          (DECLARE (IGNORABLE #:PARAMS1004))
          (APPLY
           (LAMBDA (&KEY NAME &ALLOW-OTHER-KEYS) (FORMAT NIL "Hello, ~A" NAME))
           (NCONC
            (LET ((#:PAIR1005 (ASSOC "NAME" #:PARAMS1004 :TEST #'STRING=)))
              (IF #:PAIR1005
                  (LIST :NAME (CDR #:PAIR1005))
                  NIL))))))
```

第二種

``` lisp
(macroexpand-1
 `(defroute ("/hello/post" :method :POST) (&key |name|)
  (format nil "Hello, ~A" |name|)))

;; 展開 macro 後的結果
(SETF (APPLY #'NINGLE.APP:ROUTE
             (CONS
              (CAVEMAN2.APP:FIND-PACKAGE-APP
               #<PACKAGE "CAVEMAN2-TUTORIAL.WEB">)
              (LIST "/hello/post" :METHOD :POST)))
        (LAMBDA (#:PARAMS1014)
          (DECLARE (IGNORABLE #:PARAMS1014))
          (APPLY
           (LAMBDA (&KEY |name| &ALLOW-OTHER-KEYS)
             (FORMAT NIL "Hello, ~A" |name|))
           (NCONC
            (LET ((#:PAIR1015 (ASSOC "name" #:PARAMS1014 :TEST #'STRING=)))
              (IF #:PAIR1015
                  (LIST :|name| (CDR #:PAIR1015))
                  NIL))))))
```

可以發現第一種寫法的話會將小寫的 `name` 轉成大寫，導致 post 過去的參數名稱不對，只要把 form 裡面 text 的 name 改成 "NAME"，就可以正確的讀到了。不過我建議就直接在兩側加 `|` 就好了。  
``` lisp
;; 第一個
(ASSOC "NAME" #:PARAMS1004 :TEST #'STRING=)

;; 第二個
(ASSOC "name" #:PARAMS1014 :TEST #'STRING=)
```
<br />
對這個問題有興趣的可以參考 http://acl.readthedocs.io/en/latest/zhCN/ch8-cn.html#symbol-names  。
