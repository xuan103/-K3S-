# Autoscaling
## 目錄

- 建置 K3S
    - [隨需擴充](#Autoscaling)

---
<h2 id="Autoscaling">隨需擴充</h2>

- ### 此為模仿大量需求湧進系統裡

> ./testhpa.sh
```
#!/bin/bash

trap 'kill $(jobs -p)' EXIT        #當使用者按下ctrl-c即會滿足trap條件，就會進行kill $(jobs -p)這個指令，已終止程式

while true;                        #利用無限迴圈，不停對企業網站應用系統提出服務需求
do
  curl '120.96.143.50:8080/cgi-bin/kungfu?test&a'> /dev/null 2>&1
done &
while true; do                     #利用無限迴圈，不停對企業網站應用系統提出服務需求
  curl '120.96.143.50:8080/cgi-bin/kungfu?test&b'> /dev/null 2>&1
done &
while true; do                     #在使用者畫面上顯示目前hap的管理狀態。
  sleep 2
  clear
  kubectl get hpa hpa-sp
  echo "關閉請按 ctrl-c"
done
```
---
**[上一頁 - 自動維護](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Automatic_maintenance%20.md)**

**[返回至 - 目錄](https://github.com/xuan103/k3s-Enterprise-Application-System)**
