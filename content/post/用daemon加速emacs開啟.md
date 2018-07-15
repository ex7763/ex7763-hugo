---
title: "用daemon加速emacs開啟"
description: "最近又新增一些設定，感覺emacs愈開愈慢了，所以有了這篇文"
date: 2017-11-04T00:00:00+08:00
categories: ["emacs"]
tags: []
---
## 環境

```
OS: Manjaro 17.0.6 Gellivara
Shell: bash 4.4.12
DE: Xfce4
WM: Xfwm4
GNU Emacs 25.3.1
```

此篇偏重於在GUI下的emacs，如果習慣在commad-line下用的人，設定可能會不一樣
<!--more-->
## 開啟daemon的方法
詳細內容可參考[emacs wiki](http://wikemacs.org/wiki/Emacs_server)
主要有兩種方式
### server-start
進入emacs
``` elisp
C-x C-e (server-start)
```
或者
``` elisp
M-x server-start
```
### emacs --daemon
在shell中輸入
``` sh
 emacs --daemon
```
即可

## 開機時自動執行emacs daemon
我用的方式是直接在 `~/.xprofile` 中加入
``` sh
 emacs --daemon
```
進入 `x window` 時就會自動執行daemon了

## 使用emacsclient連上emacs server
### command-line
開啟GUI：
``` sh
emacsclient -nc
```
開在終端機：
``` sh
emacsclient -nw
```
### gui
在xfce下可以這樣  
![daemon_gui_1](/images/daemon_gui_1.png)
設定從 `emacsclient` 啟動
![daemon_gui_2](/images/daemon_gui_2.png)

### 心得
開啟速度快多了
