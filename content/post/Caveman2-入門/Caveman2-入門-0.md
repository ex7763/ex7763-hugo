---
title: "Caveman2-入門-0"
description: ""
date: 2018-07-15T12:45:32+08:00
categories: ["common-lisp"]
tags: ["caveman2"]
---

## 簡介
[Caveman2](https://github.com/fukamachi/caveman)，作者是 Eitaro Fukamachi 。 Caveman2 是一個功能齊全的 common lisp 的網站框架，常見的模板功能、資料庫、路由的功能都有包含在內，而且後端的部份是建構在[clack](https://github.com/fukamachi/clack)上，所以可以任意切換想要使用的 web server像是[Hunchentoot](https://edicl.github.io/hunchentoot/)或是[Woo](https://github.com/fukamachi/woo)等。

<!--more-->

## 建立專案
本系列文章假設大家都有基本的 common lisp 知識（也不用太深入，語法懂就可以了，不過不會可能也沒太大關係），且有開發環境，像是 emacs + slime 、lispworks、lispbox等，還有套件管理程式 quicklisp ，所以就略過這些安裝的部份。

### 安裝 caveman2
跟大多數在`quicklisp`上的套件一樣，一句話解決。
``` lisp
(ql:quickload :caveman2)
```

### 建立新的專案
``` lisp
(caveman2:make-project #P"/path/to/myapp/"
                       :name "專案名稱"
                       :description "專案簡介"
                       :author "作者名稱"
                       :email "email"
                       :license "版權"
                       )
``` 
其中 **#P"/path/to/myapp/"** 是建立專案的位置，下面的 *:name* *:description* *:author* *:email* *:license* 則是可以自由選擇要不加入的，有寫的話之後自動加入 asdf 檔中，如果 *:name* 沒寫的話，路徑中 **myapp** 的部份就會自動變成專案名稱。

## 專案目錄
根據上面的步驟做完，你的終端機應該會像下面這樣。
``` lisp
* (ql:quickload :caveman2)
To load "caveman2":
  Load 1 ASDF system:
    caveman2
; Loading "caveman2"
.....
(:CAVEMAN2)
* (caveman2:make-project #P"./caveman2-tutorial")

writing ./caveman2-tutorial/caveman2-tutorial.asd
writing ./caveman2-tutorial/caveman2-tutorial-test.asd
writing ./caveman2-tutorial/app.lisp
writing ./caveman2-tutorial/README.markdown
writing ./caveman2-tutorial/.gitignore
writing ./caveman2-tutorial/db/schema.sql
writing ./caveman2-tutorial/src/config.lisp
writing ./caveman2-tutorial/src/db.lisp
writing ./caveman2-tutorial/src/main.lisp
writing ./caveman2-tutorial/src/view.lisp
writing ./caveman2-tutorial/src/web.lisp
writing ./caveman2-tutorial/static/css/main.css
writing ./caveman2-tutorial/templates/index.html
writing ./caveman2-tutorial/templates/_errors/404.html
writing ./caveman2-tutorial/templates/layouts/default.html
writing ./caveman2-tutorial/tests/caveman2-tutorial.lisp
T
```

進入目錄後可以看到下面的結構
```
.
├── app.lisp
├── caveman2-tutorial.asd
├── caveman2-tutorial-test.asd
├── db
│   └── schema.sql
├── README.markdown
├── src
│   ├── config.lisp
│   ├── db.lisp
│   ├── main.lisp
│   ├── view.lisp
│   └── web.lisp
├── static
│   └── css
│       └── main.css
├── templates
│   ├── _errors
│   │   └── 404.html
│   ├── index.html
│   └── layouts
│       └── default.html
└── tests
    └── caveman2-tutorial.lisp

```
### asdf
caveman2-tutorial.asd 是管理用到的套件庫，跟檔案的編譯方式及相依性的，軟體的相關說明也會在其中，可以看到預設的模板是 djula ，一個類似 django 中的模板系統。
``` lisp
(defsystem "caveman2-tutorial"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ("clack"
               "lack"
               "caveman2"
               "envy"
               "cl-ppcre"
               "uiop"

               ;; for @route annotation
               "cl-syntax-annot"

               ;; HTML Template
               "djula"

               ;; for DB
               "datafly"
               "sxql")
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "caveman2-tutorial-test"))))
```
### src
以下有五個檔案分別是 `config` `db` `main` `view` `web`，這邊簡單介紹一下功能。
#### config
這個檔案主要是控制，現在專案是要在什麼情況運行？是開發環境還是實際運行的環境等，`databases`的使用設定也可以在這裡進行。
```
(defconfig :common
  `(:databases ((:maindb :sqlite3 :database-name ":memory:"))))
```
#### db
裡面有些寫好的連接 database 的函數，基本上不需要改動，之後將連接資料庫的函數寫在下面。
#### main
管理 server 的運行、停止，這個檔案基本上不動。
#### view
管理如何呈現頁面的函數，如果要改模板庫的話可以在這邊調整，不過這個教學主要還是用`djula`這個模板庫作為範例。
#### web
**最重要的檔案**，主要的改動會是在這個檔案，負責網站的 routing ，進去後可以看見
``` lisp
(defroute "/" ()
  (render #P"index.html"))
```
就是表示連入 `"http://<web>/"` 後，顯示經過`djula`編譯後的 `#P"index.html"` 頁面。

### static
這個部份下的檔案會直接被加入 route 中，像是`./static/css/main.css`這個檔案，就可以從`http://<web>/css/main.css`連結。

### templates
所有模板檔案都放在這裡，之後新增的模板、網站頁面就放入這裡。

## 啟動
### clackup
如果有安裝 [roswell](https://github.com/roswell/roswell)的話，可以先安裝`clack`
```
ros install clack
```
之後在 terminal 中輸入
```
clackup --server :woo --port 8000 app.lisp
```
就可以看到網站運行了

### REPL
在 REPL 下也可以運行
```
(<project>:start :server :woo :port 8000)
```
停止
```
(<project>:stop)
```
