---
title: "common-lisp-爬中央氣象局天氣"
description: ""
date: 2017-10-24T00:00:00+08:00
categories: ["common-lisp"]
tags: ["crawler"]
---

## 使用的函式庫
這次我用到的的函式庫有兩個
http請求： drakma
正則表示法： cl-ppcre

主要是用到裡面的
``` lisp
(http-request 網址) ; 發起http請求

(all-matches-as-strings 表示法 比對字串) ; 比對符合的字串，並以列表的型式返回
;; 網站上的範例
(all-matches-as-strings "\\w*" "foo bar baz")
("foo" "" "bar" "" "baz" "")

(regex-replace-all 表示法 比對字串 替換字串) ; 替換比對的字串
;; 網站上的範例
(regex-replace-all "(?i)fo+" "foo Fooo FOOOO bar" "frob" :preserve-case t)
"frob Frob FROB bar"
``` 
<!--more-->
## 實作方法
先到各個縣市的氣象網頁如台北市的：http://www.cwb.gov.tw/V7/forecast/taiwan/Taipei_City.htm

用http-request抓取網頁
``` lisp
(http-request http://www.cwb.gov.tw/V7/forecast/taiwan/Taipei_City.htm)
```

要加入下面這行
``` lisp
(setf drakma:*drakma-default-external-format* :utf-8)
```
不然抓下來的網頁，中文會出現亂碼

找到我們需要的資訊
``` html
<tbody><tr>
		<th scope="row">今晚至明晨 07/31 18:00~08/01 06:00</th>
		<td>27 ~ 30</td>
		<td>
		<img src="../../symbol/weather/gif/night/07.gif" alt="多雲時晴" title="多雲時晴"></td>
		<td>舒適至悶熱</td>
		<td>10 %</td>
		</tr><tr>
		<th scope="row">明日白天 08/01 06:00~08/01 18:00</th>
		<td>27 ~ 35</td>
		<td>
		<img src="../../symbol/weather/gif/day/17.gif" alt="多雲短暫陣雨或雷雨" title="多雲短暫陣雨或雷雨"></td>
		<td>舒適至易中暑</td>
		<td>60 %</td>
		</tr><tr>
		<th scope="row">明日晚上 08/01 18:00~08/02 06:00</th>
		<td>27 ~ 31</td>
		<td>
		<img src="../../symbol/weather/gif/night/17.gif" alt="多雲短暫陣雨或雷雨" title="多雲短暫陣雨或雷雨"></td>
		<td>悶熱</td>
		<td>30 %</td>
		</tr></tbody>
	</table>
```

用正則表示法切出來
``` lisp
(all-matches-as-strings "(<tbody><tr>)(\\s|\\S)*(</tr></tbody>" page)
```

把不同的時段切開
``` lisp
(all-matches-as-strings "<tr>(\\s|\\S)*?</tr>" (car parsed))
```

將雜訊清掉
``` lisp
(regex-replace-all "<.*?>" x "")
```

## 程式碼
``` lisp
(defpackage cwb-crawler
  (:use :cl
        :drakma
        :cl-ppcre)
  (:export :parse
           :output
           :main))
(in-package cwb-crawler)

(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args)
      (princ a s))))

(defparameter *web-list* '("http://www.cwb.gov.tw/V7/forecast/taiwan/Taipei_City.htm"
                           "http://www.cwb.gov.tw/V7/forecast/taiwan/New_Taipei_City.htm"
                           "http://www.cwb.gov.tw/V7/forecast/taiwan/Kaohsiung_City.htm"))

(defun parse (web)
  (setf drakma:*drakma-default-external-format* :utf-8)
  (let* ((page (http-request web))
         (city-name (subseq (car (all-matches-as-strings "<th width=\"25\%\">...</th>" page)) 16 19))
         (lst (all-matches-as-strings "(<tbody><tr>)(\\s|\\S)*(</tr></tbody>)" page)))
    (values lst city-name)))

;; 因為字串在list裡所以要先用car取出來
(defun spilt-data (parsed name)
  (let* ((comment (mapcar #'(lambda (x)
                              (regex-replace-all "([a-z]|[A-Z]|\"|=)*"
                                                 x ""))
                          (all-matches-as-strings "alt=\".*?\"" (car parsed))))
         (data (all-matches-as-strings "<tr>(\\s|\\S)*?</tr>" (car parsed)))
         (clean-data (mapcar #'(lambda (x y)
                                 (mkstr (regex-replace-all "<.*?>" x "")
                                        y))
                             data
                             comment)))
    (format t "~A  DONE~%" name)
    (append (list name) clean-data)))

(defun clear-space (str)
  (regex-replace-all "\\t\\t\\n" str ""))

(defun output (file data)
  (with-open-file (out (mkstr file ".txt")
                       :direction :output
                       :if-exists :supersede)
    (let ((clean (clear-space (format nil "~{###~%~{~A~%---~}~%~}" data))))
    (format t "~%~A" clean)
    (format out "~A" clean))))

(defun main (filename web-list)
  (output filename (mapcar #'(lambda (x)
                               (multiple-value-bind (parsed name) (parse x)
                                 (spilt-data parsed name)))
                           web-list)))

(main "test" *web-list*)
```

運行結果

臺北市  DONE
新北市  DONE
高雄市  DONE

###
臺北市
---
		今晚至明晨 07/31 18:00~08/01 06:00
		27 ~ 30
		舒適至悶熱
		10 %
		多雲時晴
---
		明日白天 08/01 06:00~08/01 18:00
		27 ~ 35
		舒適至易中暑
		60 %
		多雲短暫陣雨或雷雨
---
		明日晚上 08/01 18:00~08/02 06:00
		27 ~ 31
		悶熱
		30 %
		多雲短暫陣雨或雷雨
---
###
新北市
---
		今晚至明晨 07/31 18:00~08/01 06:00
		27 ~ 29
		舒適至悶熱
		10 %
		多雲時晴
---
		明日白天 08/01 06:00~08/01 18:00
		27 ~ 35
		舒適至易中暑
		70 %
		多雲短暫陣雨或雷雨
---
		明日晚上 08/01 18:00~08/02 06:00
		28 ~ 31
		悶熱
		30 %
		多雲短暫陣雨或雷雨
---
###
高雄市
---
		今晚至明晨 07/31 18:00~08/01 06:00
		28 ~ 29
		悶熱
		70 %
		陰陣雨或雷雨
---
		明日白天 08/01 06:00~08/01 18:00
		28 ~ 32
		悶熱至易中暑
		70 %
		多雲時陰陣雨或雷雨
---
		明日晚上 08/01 18:00~08/02 06:00
		28 ~ 30
		悶熱
		50 %
		多雲短暫陣雨或雷雨
---
## 心得
拿來練正則表示法還蠻好玩的，但遇到複雜一些的網頁，直接這樣做可能就會不方便了。
drakma的速度感覺有點慢改用fast-http可能會好一點。
