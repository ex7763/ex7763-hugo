---
title: "Mercurial備忘錄"
date: 2018-08-13T00:15:14+08:00
draft: false
categories: ["devtools", "vcs"]
tags: ["mercurial", "bitbucket"]
---
## 原因
原本都是用 `git` + `github` ，因為有 `mercurial` 比較好用的說法，加上 `bitbucket` 能有免費的私有倉庫，所以嘗試看看 `mercurial` + `bitbucket` 的方式。

## 建立新的專案

### 遠端
到 [bitbucket](https://bitbucket.org/product) 創帳號， 開新的 repository

### 本地
到新專案的資料夾下：

`hg init` ： 建立新的專案，類似 `git init`  
`hg add` ： 加入所有檔案，類似 `git add -A`

<!--more-->

## hgrc

`hgrc` 放專案中的 `.hg` 資料夾下，或參考下列的優先順序：

On Unix, the following files are consulted:

* /.hg/hgrc (per-repository)
* $HOME/.hgrc (per-user)
* /etc/mercurial/hgrc (per-installation)
* /etc/mercurial/hgrc.d/*.rc (per-installation)
* /etc/mercurial/hgrc (per-system)
* /etc/mercurial/hgrc.d/*.rc (per-system)
* /default.d/*.rc (defaults)

On Windows, the following files are consulted:

* /.hg/hgrc (per-repository)
* %USERPROFILE%.hgrc (per-user)
* %USERPROFILE%\Mercurial.ini (per-user)
* %HOME%.hgrc (per-user)
* %HOME%\Mercurial.ini (per-user)
* HKEY_LOCAL_MACHINE\SOFTWARE\Mercurial (per-installation)
* \hgrc.d*.rc (per-installation)
* \Mercurial.ini (per-installation)
* /default.d/*.rc (defaults)

記得在裡面加 `ui` 的資訊，不然不能 `commit`  
可以把 `paths` 中的 `default` 設為 bitbucket 上的網址， `hg push` 時就會自動用這個位置  
```
[ui]
username = Your name <your@email>
    
[paths]
default = https://<username>@bitbucket.org/<username>/<project>
# 可加可不加
# local = /home/.......
```

## .hgignore

不要加入版本控制的檔案名稱格式寫在這，同 `.gitignore` 的功能

```
# 類似 .gitignore 的格式設定
syntax: glob

*~

# 正則表示法
syntax: regexp

^\.pc/
```
