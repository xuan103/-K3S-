# Images

## 目錄

- [製作 alpine.base images](#make-alpine.base)
    - [建立 alpine.base images](#build-alpine.base)
    - [測試 alpine.base images](#test-alpine.base)
*   [在 k3s 撰寫 yml 檔](#yml)
*   [部署應用系統](#sys)
    *   [匯出 alpine.base.tar 檔](#save-tar)
---

<h2 id="make-alpine.base">製作 alpine.base images</h2>

- ### 在 ddg52 終端機執行以下命令 

> mkdir wulin; cd ~/wulin

- ### 提前部署 CGI 程式

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
>> service: 名稱解析

- ### 撰寫 alpine.base Dockerfile

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

- ### 建立 alpine.base image
> docker build -t alpine.base .

- ### 查看 images
> docker images
```
REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
alpine.base   latest    ff61db169094   46 minutes ago   80.5MB
mariadb       10.5.8    3a348a04a815   3 weeks ago      407MB
alpine        3.12.1    d6e46aa2470d   8 weeks ago      5.57MB
```

<h3 id="test-alpine.base">測試 alpine.base images</h3>

- ### 修改 docker-compose.yml
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

- ### 啟動 docker-compose.yml
> docker-compose -f docker-compose.yml up -d
```
Creating httpd ... done
Creating service ... done
```

<h2 id="build-database">建立 database</h2>

- ### 進入 service pod
> docker exec -it service -- bash
```
root@sqldb:/#
```
- ### 進入 mysql
> mysql -uroot -proot
```
MariaDB [(none)]> 
```
- ### 建立 database test
> create database test;

- ### 進入 database test
> use test;

- ### 查看所有的 table
> show tables;


**MariaDB [(test)]>** 

- ### 建立 table test
> create table projects(
    a int,
    b int,
    c int
);

- ### 查看 table test 所有資料
> SELECT * FROM test;

- ### 新增資料到 table test 裡面去
> INSERT INTO test (a int, b int, c int) VALUES (1,2,3);

- ### 查看 table test 所有資料
> SELECT * FROM test;
```
+------+------+------+
| a    | b    | c    |
+------+------+------+
| 1    | 2    | 3    |
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
**[上一頁 - Install MariaDB](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Mariadb.md)**

**[下一頁 - 部署 images 到 k3s 叢集](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/K3S_Cluster.md)**




