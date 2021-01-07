# Install MariaDB

## 目錄

*   [安裝 mariaDB](#install-mariadb)
    *   [設定 mariaDB](#system-mariaDB)
  
*   [mariaDB 帳號授權](#mariadb-useradd)
    *   [測試連線 mariaDB](#test-mariadb)
  
*   [建立 K3s Master](#make-k3s-marter)
    *   [加入 k3s node](#add-k3s-node)
    *   [設定 k3s worker 標籤](#k3s-worker-lable)

*   [查看資料庫](#check-database)
*   [建置 Pod](#mariadb-pod)
*   [參考文件](#references)
---
<h1 id="install-mariadb">安裝 mariaDB</h1>

### 在 admin 主機操作

- ### 安裝套件清單
> sudo apk update

- ### 安裝 mariadb-client
> sudo apk add mariadb mariadb-client

- ### 設定 MariaDB Default 設定
> sudo /etc/init.d/mariadb setup

- ### 設定 root 帳號
```
 * Creating a new MySQL database ...
Installing MariaDB/MySQL system tables in '/var/lib/mysql' ...
OK
……
……
Two all-privilege accounts were created.
One is root@localhost, it has no password, but you need to
be system 'root' user to connect. Use, for example, sudo mysql
The second is mysql@localhost, it has no password either, but
you need to be the system 'mysql' user to connect.
```

- ### 啟動 mariadb 服務
> sudo rc-service mariadb start
```
* Caching service dependencies ... 
* Starting mariadb ...
210103 15:03:06 mysqld_safe Logging to syslog.
210103 15:03:06 mysqld_safe Starting mysqld daemon with databases from /var/lib/                 mysql                                                                     [ ok ]
```

-----
<h2 id="system-mariaDB">設定 mariaDB</h2>

### 在 admin 主機操作

- ### 將 mariadb 設為開機時，自動啟動
> sudo rc-update add mariadb default

- ### 檢查是否設定成功
> rc-status default
```
Runlevel: default
 cgroups                                                            [  started  ]
 sshd                                                               [  started  ]
 crond                                                              [  started  ]
 acpid                                                              [  started  ]
 chronyd                                                            [  started  ]
 local                                                              [  started  ]
```

- ### 進入並且修改 /etc/my.cnf.d/mariadb-server.cnf
> sudo nano /etc/my.cnf.d/mariadb-server.cnf

- ### 將 skip-networking 加上註解，MariaDB Client 才可連進去
```bash=
# skip-networking
```

- ### 重新開機
> sudo reboot

- ### 查看 MariaDB 狀態
> sudo rc-service mariadb status
```
 * status: started
```

---
<h2 id="mariadb-useradd">mariaDB 帳號授權</h2>

### 在 admin 主機操作

- ### 登入 mariadb
> mysql -uroot

- ### 建立使用者和權限
**MariaDB [(none)]>** 

> `grant all on *.* to 'k3s'@'120.xx.xx.50' identified by 'k3s' with grant option;`

> `grant all on *.* to 'k3s'@'120.xx.xx.52' identified by 'k3s' with grant option;`

> `grant all on *.* to 'k3s'@'120.xx.xx.53' identified by 'k3s' with grant option;`

- ### 刷新 MariaDB 的系統權限相關表
> FLUSH PRIVILEGES;

- `'k3s'@'120.xx.xx.50': `
    - 'k3s'

<h2 id="test-mariadb">測試連線 mariaDB</h2>

**MariaDB [(none)]>**

- ### 查看使用者
> select host,user from mysql.user;
```
+---------------+-------------+
| Host          | User        |
+---------------+-------------+
| 120.96.143.50 | lcs         |
| 120.96.143.52 | lcs         |
| 120.96.143.53 | lcs         |
| localhost     | mariadb.sys |
| localhost     | mysql       |
| localhost     | root        |
+---------------+-------------+
6 rows in set (0.001 sec)
```

> quit;

### 在三台 master 主機操作

> sudo apk add mariadb-client

### 在 master 主機操作

登入資料庫

> mysql -uk3s -pk3s -h 120.xx.xx.50
```
+---------------+-------------+
| Host          | User        |
+---------------+-------------+
| 120.xx.xx.51 | lcs         |
| 120.xx.xx..52 | lcs         |
| 120.xx.xx..53 | lcs         |
| localhost     | mariadb.sys |
| localhost     | mysql       |
| localhost     | root        |
+---------------+-------------+
6 rows in set (0.001 sec)
```
**MariaDB [(none)]>**
> quit;

---
<h2 id="make-k3s-marter">建立 K3s Master</h2>

### 在 master 主機操作

- ### 3 台 master 執行以下命令
> curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 \
--datastore-endpoint mysql://lcs:lcs@tcp(120.96.143.56:3306)/kubernetes \
--cluster-cidr=10.20.0.0/16 \
--service-cidr=172.30.0.0/24 \
--cluster-domain=dt.io" sh - && sudo reboot

- ### 查看 master 是否有加入叢集裡
> kubectl get nodes
```
NAME    STATUS     ROLES    AGE    VERSION
lcs51   Ready      master   6d3h   v1.19.5+k3s2
lcs52   Ready      master   6d3h   v1.19.5+k3s2
lcs53   Ready      master   6d3h   v1.19.5+k3s2
```

---
<h2 id="add-k3s-node">加入 k3s node</h2>

### 在 master 主機操作
```bash=
clear; echo " sudo curl -sfL https://get.k3s.io | K3S_URL=https://master_ip:6443 K3S_TOKEN=`sudo cat /var/lib/rancher/k3s/server/node-token` K3S_KUBECONFIG_MODE='644' sh - &&sudo reboot "
```

- ### 將顯示的指令，複製到 worker node 上執行
```
sudo curl -sfL https://get.k3s.io | K3S_URL=https://120.xx.xx.52:6443 K3S_TOKEN=K1087512b0eeb30b8a9ba451215c7a7768d1716d3522a519494e1245d2695320cd3::server:8bb8fcf365043724f8b6f9f4b154c0ee K3S_KUBECONFIG_MODE='644' sh - &&sudo reboot
```

---
<h2 id="k3s-worker-lable">設定 k3s worker 標籤</h2>

### 在 master 主機操作

- ### 在 master node 執行命令，查看 worker 是否加入叢集裡
> kubectl get nodes
```
lcs51   Ready      master   36m   v1.19.5+k3s2
lcs52   Ready      master   40m   v1.19.5+k3s2
lcs53   Ready      master   37m   v1.19.5+k3s2
lcs54   Ready      <none>   30s   v1.19.5+k3s2
lcs55   Ready      <none>   40s   v1.19.5+k3s2
lcs56   Ready      <none>   8s    v1.19.5+k3s2
```

- ### 貼 worker 標籤
> sudo kubectl label node lcs54 node-role.kubernetes.io/worker=lcs54

> sudo kubectl label node lcs55 node-role.kubernetes.io/worker=lcs55

> sudo kubectl label node lcs56 node-role.kubernetes.io/worker=lcs56

- ### 在 master node 執行命令，查看 worker 標籤是否加入叢集裡
> kubectl get nodes
```
lcs51   Ready      master   36m   v1.19.5+k3s2
lcs52   Ready      master   40m   v1.19.5+k3s2
lcs53   Ready      master   37m   v1.19.5+k3s2
lcs54   Ready      worker   30s   v1.19.5+k3s2
lcs55   Ready      worker   40s   v1.19.5+k3s2
lcs56   Ready      worker   8s    v1.19.5+k3s2
```

---
<h2 id="check-database">查看資料庫</h2>

- ### 登入
> mysql -ulcs52 -plcs52 -h 120.xx.xx.56

- 120.xx.xx.56: 為 admin 管理著電腦, 需安裝 MariaDB.

**MariaDB [(none)]>**

> use kubernetes;

**MariaDB [kubernetes]>**

> show tables;
```
+------------------------------+
| Tables_in_kubernetes         |
+------------------------------+
| kine                         |
+------------------------------+
1 row in set (0.001 sec)
```

- ### K3s 會自己建一個 kine 資料表，存放 k3s 的 metadata

---
<h2 id="mariadb-pod">建置 Pod</h2>

### 在 master 主機操作

> kubectl run t1 --restart=Never --image=alpine -- sleep 30
```
pod/t1 created
```

> kubectl get pods --watch
```
NAME   READY      STATUS       	    	 RESTARTS      AGE
t1     0/1    	  ContainerCreating    	 0            	2s
t1     1/1    	  Running    	      	      	 0          	10s
t1     0/1    	  Completed    	         0         	40s
``` 

> kubectl delete pods t1
```
pod "t1" deleted
```

---
<h1 id="references">參考文件</h1> 

- https://wiki.alpinelinux.org/wiki/MariaDB

---
**[上一頁 - 介紹 系統架構圖](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Architecture.md)**

**[下一頁 - 部署 images 到 k3s 叢集](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/K3S_Cluster.md)**