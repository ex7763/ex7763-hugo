---
title: "如何建立一個lisp專案"
description: "簡單介紹如何建立一個基本的common lisp專案"
date: 2017-11-22T00:00:00+08:00
categories: ["common-lisp"]
tags: ["asdf"]
---
## 建立一個專案
一個現代的lisp專案通常會包含幾個檔案， `Project.asd` ， `package.lisp` ，第一個功能類似makefile，用於建立每一個檔案的相依性、用到的外部函式庫、作者的資訊、使用的license等等，都可以寫在這裡，詳細資訊可以參考[asdf](https://common-lisp.net/project/asdf/) ，下面是一個範例：

``` lisp
(asdf:defsystem #:chess
    :version "0.2"
    :name "chess"
    :author "Hsu,Po-Chun"
    :license "MIT License"
    :depends-on (:ltk)  ; 使用到的函式庫，quicklisp會自動幫忙載入對應的庫
    :serial t  ; 設定檔案為依序存取
    :components ((:file "package")  ; 專案的檔案，.lisp可以省去
                 (:file "array")
                 (:file "gui")
                 (:file "main" :depends-on ("array" "gui"))))  ; 建立跟其他檔案的相依性
```
<!--more-->
而前面提到的 `package.lisp` 顧名思義，主要是用來定義package，在所有file中最先載入，需要先初始化的程式也可以放在這裡，範例：

``` lisp
(defpackage chess
  (:use :cl :ltk)
  (:export :ascii-main
           :gui-main))
```

## 設定quicklisp找專案的位置
### 預設
quicklisp預設的放專案的路徑在 `~/quicklisp/local-project/` 其中 `~/quicklisp/` 是安裝quicklisp時的位置。
因為quicklisp使用到asdf來建構專案，所以也可以直接放在asdf的預設路徑下 `~/common-lisp/` 和 `~/.local/share/common-lisp/source/` ，如果沒看到這兩個位置，自己創一個就可以了。
### 自訂
有時候我們想要使用自己的位置，我們可以在 `~/.config/common-lisp/source-registry.conf.d/` 下面，建立一個 `.conf` 檔，名字自取，例如 `my.conf` ，並在裡面加入

``` lisp
(:tree "/home/user/mylocal")
```
其中的 `/home/user/mylocal` 就是讓asdf去找的位置。

更清楚的可以參考官方文檔[ASDF Manual](https://common-lisp.net/project/asdf/asdf.html#Configuring-ASDF)
## 使用quickproject快速建立
先用quicklisp安裝[quickproject](https://www.xach.com/lisp/quickproject/)

``` lisp
(ql:quickload "quickproject")
```

之後只要

``` lisp
(quickproject:make-project #p"~/test/" :name "hello-world" :depends-on '(ltk))
```

就會幫你自動建立上面講的asd跟package檔。
這個quickproject的功能基本上就這樣，我覺得自己打其實也不會慢到哪，而且新增一些依賴的庫或檔案，還是自己來方便。
