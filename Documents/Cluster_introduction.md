# Cluster introduction

---
## 目錄

- 建置 K3S
    - [介紹 - 系統架構圖](#Architecture)

----

<h1 id="build-k3s">建置 K3S</h1> 
<h2 id="present">叢集介紹</h2> 

以 7 台實體電腦為例, 如何分配各個電腦 ?

- 一台 admin: 放 **metadata** 
- 三台 master:  **接受並執行命令, 分配管理 pod** 
- 三台 worker: **執行 pod** 

以上所有電腦, 作業系統皆為 alpine. 

- [alpine](https://github.com/xuan103/Alpine/wiki/Chapter-1.-Install-On-Disk) 安裝參考

---
<h2 id="Architecture">系統架構圖</h2> 

![](https://i.imgur.com/BIixEtX.png)

- 開啟 admin 電腦以及 3 台 master 電腦, 依據以下操做, 完成安裝.
---

**[上一頁 - 目錄](https://github.com/xuan103/k3s-Enterprise-Application-System)**

**[下一頁 - Install MariaDB](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/mariadb.md)**
