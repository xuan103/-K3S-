---
tags: k3s-Enterprise-Application-System

picture: https://docs.google.com/presentation/d/1ozkKTuMUiGRjkFJA8ywXyR60uVFIO38GSHLa_Tud0vQ/edit?usp=sharing

ppt: https://docs.google.com/presentation/d/12C4x0h0EyveVT4NpMaVzkDDvPlRcoU3jXwT7IgFecr0/edit?usp=sharing
---

# Use K3S to Deploy High Reliability Enterprise Application System

---

## 目錄

*   [建置 K3S](#build-k3s)
    *   [介紹](#present)
    *   [系統架構圖](#Architecture)
    *   [安裝 mariaDB](#install-mariadb)
    *   [設定 mariaDB](#system-mariaDB)
    *   [mariaDB 帳號授權](#mariadb-useradd)
    *   [測試連線 mariaDB](#test-mariadb)
    *   [建立 K3s Master](#make-k3s-marter)
    *   [加入 k3s node](#add-k3s-node)
    *   [設定 k3s worker 標籤](#k3s-worker-lable)
    *   [查看資料庫](#check-database)
    *   [建置 Pod](#mariadb-pod)


*   [前期部署](#Early-deployment)
    *   [製作 alpine.base images](#make-alpine.base)
        *   [建立 alpine.base images](#build-alpine.base)
        *   [測試 alpine.base images](#test-alpine.base)
    *   [建立 database](#build-database)
    *   [測試 httpd](#test-httpd)
    *   [匯出 alpine.base.tar 檔](#save-tar)


*   [部署 images 到 k3s 叢集](#images-inpose)
    *   [將 alpine.base.tar 複製到 k3s 叢集](#scp-tar)
    *   [在 k3s 撰寫 yml 檔](#nano-k3s)
    *   [佈署 k3s Service](#k3s-Service)
    *   [檢查 yml 檔是否成功啟動](#cheak-yml)
    *   [啟動 port-forward](#port-forward)
    *   [啟動瀏覽器](#open-chrome)

*   [參考文件](#references)

------------------------------------------

<h1 id="build-k3s">建置 K3S</h1> 
<h2 id="present">叢集介紹</h2> 

以 7 台實體電腦為例, 如何分配各個電腦 ?

- 一台 admin: 放 **metadata** 
- 三台 master:  **接受並執行命令, 分配管理 pod** 
- 三台 worker: **執行 pod** 

以上所有電腦, 作業系統皆為 alpine. 

- [alpine](https://github.com/xuan103/Alpine/wiki/Chapter-1.-Install-On-Disk) 安裝參考

<h2 id="Architecture">系統架構圖</h2> 

![](https://i.imgur.com/OlFbCyV.png)

- 開啟 admin 電腦以及 3 台 master 電腦, 依據以下操做, 完成安裝.

<h2 id="install-mariadb">安裝 mariaDB</h2>

- ## 安裝套件清單
**[admin]$**
> sudo apk update

- ## 安裝 mariadb-client
**[admin]$**
> sudo apk add mariadb mariadb-client

- ## 設定 MariaDB Default 設定
**[admin]$**
> sudo /etc/init.d/mariadb setup

![mariadb-setup](https://i.imgur.com/zflI0wW.png)

- ## 設定 root 帳號

- ## 啟動 mariadb 服務

**[admin]$**
> sudo rc-service mariadb start

![mariadb-start](https://i.imgur.com/lIwSGg4.png)


<h2 id="system-mariaDB">設定 mariaDB</h2>

- ## 設定 mariaDB

> sudo mysql_secure_installation

![system-mariaDB](https://i.imgur.com/Eq61BhX.png)

- ## 將 mariadb 設為開機時，自動啟動
**[admin]$**

> sudo rc-update add mariadb default

- ## 檢查是否設定成功
**[admin]$**

> rc-status default

![rc-status](https://i.imgur.com/H4uQNn2.png)

- ## 進入並且修改 /etc/my.cnf.d/mariadb-server.cnf
**[admin]$**
> sudo nano /etc/my.cnf.d/mariadb-server.cnf

- ## 將 skip-networking 加上註解，MariaDB Client 才可連進去
```bash=
# skip-networking
```

- ## 重新開機
**[admin]$**
> sudo reboot

- ## 查看 MariaDB 狀態
> sudo rc-service mariadb status
```
status: started
```

<h2 id="mariadb-useradd">mariaDB 帳號授權</h2>

- ## 登入 mariadb
**[admin]$**

> mysql -uroot

- ## 建立使用者和權限
**MariaDB [(none)]>** 

> `grant all on *.* to 'k3s'@'120.xx.xx.50' identified by 'k3s' with grant option;`

> `grant all on *.* to 'k3s'@'120.xx.xx.52' identified by 'k3s' with grant option;`

> `grant all on *.* to 'k3s'@'120.xx.xx.53' identified by 'k3s' with grant option;`

- ## 刷新 MariaDB 的系統權限相關表
> FLUSH PRIVILEGES;

- `'k3s'@'120.xx.xx.50': `
    - 'k3s'

<h2 id="test-mariadb">測試連線 mariaDB</h2>

**MariaDB [(none)]>**

- ## 查看使用者
> select host,user from mysql.user;

![test-mariadb](https://i.imgur.com/9YqtXoe.png)

> quit;

<h2 id="make-k3s-marter">建立 K3s Master</h2>

- ## 3 台 master 執行以下命令
**[master]$**

> curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 \
--datastore-endpoint mysql://lcs:lcs@tcp(120.96.143.56:3306)/kubernetes \
--cluster-cidr=10.20.0.0/16 \
--service-cidr=172.30.0.0/24 \
--cluster-domain=dt.io" sh - && sudo reboot

- ## 查看 master 是否有加入叢集裡
> kubectl get nodes

![get-nodes](https://i.imgur.com/mPAtoeh.png)


<h2 id="add-k3s-node">加入 k3s node</h2>

- ## 在 master 執行
**[master]$** 

```bash=
clear; echo " sudo curl -sfL https://get.k3s.io | K3S_URL=https://master_ip:6443 K3S_TOKEN=`sudo cat /var/lib/rancher/k3s/server/node-token` K3S_KUBECONFIG_MODE='644' sh - &&sudo reboot "
```

- ## 將顯示的指令，複製到 worker node 上執行

![add-k3s-node](https://i.imgur.com/2A4U32U.png)

<h2 id="k3s-worker-lable">設定 k3s worker 標籤</h2>

- ## 在 master node 執行命令，查看 worker 是否加入叢集裡
**[master]$**

> kubectl get nodes

![k3s-worker-lable](https://i.imgur.com/IGF0cga.png)

- ## 貼 worker 標籤
**[master]$**

> sudo kubectl label node lcs54 node-role.kubernetes.io/worker=lcs54

> sudo kubectl label node lcs55 node-role.kubernetes.io/worker=lcs55


<h2 id="check-database">查看資料庫</h2>

- ## 登入
**[master]$**

> mysql -ulcs52 -plcs52 -h 120.xx.xx.56

- 120.xx.xx.56: 為 admin 管理著電腦, 需安裝 MariaDB.

**MariaDB [(none)]>**

> use kubernetes;

**MariaDB [kubernetes]> **

> show tables;

![show-tables](https://i.imgur.com/DUx7VF4.png)


- ## K3s 會自己建一個 kine 資料表，存放 k3s 的 metadata


<h2 id="mariadb-pod">建置 Pod</h2>

**[master]$**

> kubectl run t1 --restart=Never --image=alpine -- sleep 30
```
pod/t1 created
```

> kubectl get pods --watch
```
NAME   READY      STATUS       	RESTARTS   AGE
t1          	0/1 	ContainerCreating   0            	2s
t1          	1/1        	Running          	0          	10s
t1          	0/1    	Completed          	0         	40s
```

> kubectl delete pods t1
```
pod "t1" deleted
```

---

<h1 id="Early-deployment">前期部署</h1> 


<h2 id="make-alpine.base">製作 alpine.base images</h2>

- ## 在 ddg52 終端機執行以下命令 

> mkdir wulin; cd ~/wulin

- ## 提前部署 CGI 程式

> nano kungfu
```
#!/bin/bash
echo "Content-type: text/html; charset=utf-8"
parm=$(echo $QUERY_STRING | tr '&' ' ')
table=$(echo ${parm}|cut -d " " -f1)
column=$(echo ${parm}|cut -d " " -f2)
echo ""
echo $(mysql -uroot -proot -h service "use test; select ${column} from ${table};")
echo ""
```
- service: 名稱解析

- ## 撰寫 alpine.base Dockerfile

> nano Dockerfile
```yaml=
FROM alpine:3.12.1
RUN apk update && apk upgrade && apk add --no-cache mariadb-client nano sudo wget curl \
	tree elinks bash shadow procps util-linux coreutils binutils findutils grep && \
	wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64 && \
	chmod +x busybox-x86_64 && mv busybox-x86_64 bin/busybox1.28 && \
	mkdir -p /opt/www/cgi-bin                                                                                    
COPY kungfu /opt/www/cgi-bin/
CMD ["/bin/bash","-c","busybox1.28 httpd -f -p 8888 -h /opt/www "]
```

<h3 id="build-alpine.base">建立 alpine.base images</h3>

- ## 建立 alpine.base image
> docker build -t alpine.base .

- ## 查看 images
> docker images
```
REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
alpine.base   latest    ff61db169094   46 minutes ago   80.5MB
mariadb       10.5.8    3a348a04a815   3 weeks ago      407MB
alpine        3.12.1    d6e46aa2470d   8 weeks ago      5.57MB
```

<h3 id="test-alpine.base">測試 alpine.base images</h3>

- ## 修改 docker-compose.yml
> nano docker-compose.yml
```yaml=
version: '3.7'
services:
  service:
    image: mariadb
    container_name: service
    hostname: sqldb
    environment:
      MYSQL_DATABASE: "sqldb"
      MYSQL_ROOT_PASSWORD: "root"
  httpd:
    image: alpine.base
    container_name: httpd
    ports:
    - "80:8888"
```

- ## 啟動 docker-compose.yml
> docker-compose -f docker-compose.yml up -d
```
Creating httpd ... done
Creating service ... done
```

<h2 id="build-database">建立 database</h2>

- ## 進入 service pod
> docker exec -it service -- bash

**root@sqldb:/#** 

- ## 進入 mysql
> mysql -uroot -proot

**MariaDB [(none)]>** 

- ## 建立 database test
> create database test;

- ## 進入 database test
> use test;

- ## 查看所有的 table
> show tables;


**MariaDB [(test)]>** 

- ## 建立 table test
> create table projects(
    a int,
    b int,
    c int
);

- ## 查看 table test 所有資料
> SELECT * FROM test;

- ## 新增資料到 table test 裡面去
> INSERT INTO test (a int, b int, c int) VALUES (1,2,3);

- ## 查看 table test 所有資料
> SELECT * FROM test;
```
+------+------+------+
| a	| b	| c	|
+------+------+------+
|	1 |	2 |	3 |
+------+------+------+
1 row in set (0.001 sec)
```

> exit;


<h2 id="test-httpd">測試 httpd</h2>

> docker exec httpd hostname -i
```
172.23.0.2
```

> curl 'http://172.23.0.2:8888/cgi-bin/kungfu?test&a'
```
a 1
```

<h2 id="save-tar">匯出 alpine.base.tar 檔</h2>

> docker save alpine.base > alpine.base.tar

---

<h1 id="images-inpose">部署 images 到 k3s 叢集</h1>

<h2 id="scp-tar">將 alpine.base.tar 複製到 k3s 叢集</h2>

- ## 方法 1：

- ### 在 ddg52 終端機執行以下命令 

    - #### 將 alpine.base.tar 複製到 k3s 叢集（5 台叢集）

> sudo scp alpine.base1.tar bigred@120.xx.xx.51:/home/bigred
```
The authenticity of host '120.xx.xx.51 (120.xx.xx.51)' can't be established.
ECDSA key fingerprint is SHA256:Ket7vrjo+Qclg7y4qqI3/saqht8hhu3use4DxHV3v3uU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '120.xx.xx.51' (ECDSA) to the list of known hosts.
bigred@120.xx.xx.51's password: bigred
```
- ## 方法 2：

- ### ddg52 將 .tar 複製到 cvn71, 再處存到隨身碟後, 複製到其他 6 台的 k3s 叢集

- bigred@ddg52:~/wulin$ 

> sudo scp alpine.base.tar bigred@172.29.0.254:/home/bigred/wk

- #### 驗證：

- bigred@cvn71:~/wk$ 

> ls -akh
```
total 78M
drwxrwxr-x 3 bigred bigred 4.0K 12月 19 20:13 .
drwxr-xr-x 9 bigred bigred 4.0K 12月 19 21:07 ..
-rw-rw-r-- 1 bigred bigred  78M 12月 19 21:06 alpine.base.tar
```

- ### k3s 叢集執行以下命令 

- #### 製作 image

> sudo ctr images import alpine.base.tar

- #### 檢查 image

> sudo crictl images
```
IMAGE                           TAG                 IMAGE ID            SIZE
docker.io/library/alpine.base   latest              ff61db1690949       81.7MB
```

<h2 id="nano-k3s">在 k3s 撰寫 yml 檔</h2>

- ### 製作 網頁

> nano alpine.base.yml
```yaml=
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd
  labels:
    app:  httpd
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: dafu/alpine.derby
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: 50m
        stdin: true
        tty: true
        ports:
        - name: http
          containerPort: 8888
```
- ### 製作 資料庫

> nano mariadb.yml
```yaml=
apiVersion: v1
kind: Pod
metadata:
  name: sqldb
  labels:
    app: sql
spec:
  containers:
  - name: sqldb
    image: mariadb
    imagePullPolicy: IfNotPresent
    env:
      - name: LANG
        value: C.UTF-8
      - name: MYSQL_DATABASE
        value: sqldb
      - name: MYSQL_ROOT_PASSWORD
        value: root
    volumeMounts:
      - name: mariadb-dir
        mountPath: /var/lib/mysql
  volumes:
    - name: mariadb-dir
      hostPath:
        path: /opt/pv/mariadb
  nodeSelector:
    kubernetes.io/hostname: lcsxx
  restartPolicy: Always
```

- lcsxx: 要在哪一台機器執行


<h2 id="k3s-Service">佈署 k3s Service</h2>

<h2 id="cheak-yml">檢查 yml 檔是否成功啟動</h2>

<h2 id="port-forward">啟動 port-forward</h2>

<h2 id="open-chrome">啟動瀏覽器</h2>

---

<h1 id=""></h1>

<h2 id=""></h2>

<h2 id=""></h2>

<h2 id=""></h2>

<h2 id=""></h2>

<h2 id=""></h2>

<h2 id=""></h2>

<h2 id=""></h2>


<h2 id=""></h2>

<h2 id=""></h2>





























---

<h1 id="references">參考文件</h1> 

- https://wiki.alpinelinux.org/wiki/MariaDB


