---
title: "開機自動在tmux啟動程式"
description: "剛好需要開機自動啟動 web server ，簡單紀錄一下。"
date: 2017-12-24T00:00:00+08:00
categories: ["linux"]
tags: ["tmux"]
---

## 建立一個 script
隨便建立一個文件，用來當做啟動的腳本，並給他可執行的權限。
``` sh
emacs ./auto_start.sh
chmod +x auto_start.sh
```
<!--more-->
編輯檔案， =autostart= 是 tmux session 的名子， =main= 是開啟視窗的名子。
``` sh
#!/bin/sh
tmux new-session -s autostart -n main -d
tmux send-keys -t autostart 'cat /etc/passwd' C-m
```
把 `cat /etc/passwd` 改成你想執行的指令即可


## 設定 /etc/rc.local
進入 `/etc/rc.local` 這個檔案
``` sh
$ emacs /etc/rc.local
#!/bin/bash
#
# /etc/rc.local: Local multi-user startup script.
#

su user -c /home/user/autostart.sh
```
把 `user` 改成自己的 user name ， `/home/user/autostart.sh` 改成需要執行的 script
這裡用到 `su user -c` 是要切換執行的使用者，避免用 `root` 啟動，我一開始沒加上這個，導致重開機時一直沒有自動啟動的效果。

## 結束
到這邊就完成了可以重開測試效果，重啟後執行 `tmux ls`
``` sh
$ tmux ls
autostart: 1 windows (created Sun Dec 24 00:21:27 2017) [80x23]
```
如果有的話就是成功了
