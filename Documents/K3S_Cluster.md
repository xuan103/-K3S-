# K3S Cluster

## 目錄

*   [部署 images 到 k3s 叢集](#images-inpose)
    *   [將 alpine.base.tar 複製到 k3s 叢集](#scp-tar)
    *   [在 k3s 撰寫 yml 檔](#nano-k3s)
    *   [部署應用系統](#system) 
    *   [檢查是否成功啟動](#cheak-yml)
    
---
<h1 id="images-inpose">部署 images 到 k3s 叢集</h1>

<h2 id="scp-tar">將 alpine.base.tar 複製到 k3s 叢集</h2>

- ### 方法 1：

- #### 在 ddg52 終端機執行以下命令 

    - #### 將 alpine.base.tar 複製到 k3s 叢集（5 台叢集）

> sudo scp alpine.base1.tar bigred@120.xx.xx.51:/home/bigred
```
The authenticity of host '120.xx.xx.51 (120.xx.xx.51)' can't be established.
ECDSA key fingerprint is SHA256:Ket7vrjo+Qclg7y4qqI3/saqht8hhu3use4DxHV3v3uU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '120.xx.xx.51' (ECDSA) to the list of known hosts.
bigred@120.xx.xx.51's password: bigred
```
- ### 方法 2：

- #### ddg52 將 .tar 複製到 cvn71, 再處存到隨身碟後, 複製到其他 6 台的 k3s 叢集

- bigred@ddg52:~/wulin$ 

> sudo scp alpine.base.tar bigred@172.29.0.254:/home/bigred/wk

- #### 驗證：

- bigred@cvn71:~/wk$ 

> ls -alh
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

### 建造專案資料夾, 在 K3S master 執行

> mkdir project; cd project

- ### 製作 網頁

> nano alpine.base.yml
```yaml=
apiVersion: apps/v1
kind: Deployment  		      #提供replicaset功能，管理監控應用系統(pod) r
metadata:
  name: httpd
  labels:
    app:  httpd  		      #Deployment的標籤
spec:
  replicas: 2   		      #提供自動維護的功能，讓應用系統(pod)可以一直維持我們設定的數量。
  selector:
    matchLabels:
      app: httpd 	              #replicaset會搜尋有 httpd 這個標籤的 應用系統(pod)  
  template:
    metadata:
      labels:
        app: httpd 	               #應用系統(pod)的標籤
    spec:
      containers:
      - name: httpd
        image: dafu/alpine.derby
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: 50m            	#設定應用系統(pod)可以使用的運算資源
        stdin: true
        tty: true
        ports:
        - name: http
          containerPort: 8888
#       readinessProbe:               #提供readiness探測功能
#        exec:
#           command:
#           - /bin/bash
#           - -c
#           - ls /
#         initialDelaySeconds: 20     #系統啟動20秒後開始探測
#         periodSeconds: 5            #每5秒探測一次
```
- ### 製作 自動擴充功能設定檔
> nano hpa-sp.yml
```yaml=
apapiVersion: autoscaling/v1 
kind: HorizontalPodAutoscaler 	               #提供應用系統的自動擴充簡稱 (HPA)
metadata:
  name: hpa-sp
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: httpd   	 	               #HPA 會搜尋有 httpd 標籤的 Deployment
  minReplicas: 2  		               #最小的應用系統數量(pod)
  maxReplicas: 6  	                       #最大的應用系統數量(pod)
  targetCPUUtilizationPercentage: 30 		#應用系統 (pod) 運算資源使用百分比，當超過這個百分比即會自動擴展
```

- ### 製作 網站資料庫設定檔

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
      - name: MYSQL_DATABASE 	 #在資料庫裡，創造名為sql的database
        value: sqldb
      - name: MYSQL_ROOT_PASSWORD	 #設定 root 的密碼 密碼為root
        value: root
    volumeMounts:
      - name: mariadb-dir
        mountPath: /var/lib/mysql		  #資料庫存放所以紀錄的資料夾
  volumes:
    - name: mariadb-dir
      hostPath:
        path: /opt/pv/mariadb 	 #設定 pv(persistent volume)，讓資料庫裡的資永久保存在本機
  nodeSelector:
    kubernetes.io/hostname: lcsxx	  #指定在哪台機器執行，讓資料庫的資料能夠保持同步 
    ## lcsxx: 要在哪一台機器執行

  restartPolicy: Always
```

- ### 製作 service 的 yml 檔案, 讓企業應用系統對外提供服務
> nano hpa-svc.yml
```yaml=
apiVersion: v1
kind: Service
metadata:
  name: svc-sp
spec:
  selector:
    app: httpd
  externalIPs:
    - 120.96.143.50
  ports:
  - name: http
    port: 8080  		#開在120.96.143.50這IP以及service上的port號
    targetPort: 8888 		#企業網站應用系統的port號


```
- ### 讓資料庫能夠對內提供名稱解析
> nano service.yml
```yaml=
kind: Service
apiVersion: v1
metadata:
  name: service
spec:
  selector:
    app: sql
  ports:
  - protocol: TCP
    port: 3306	#開在service上的port號
    targetPort: 3306  	#資料庫的port號預設是3306
```
---
<h2 id="system">部署應用系統</h2>
### 一鍵部屬
> kubectl apply -f .

---
<h2 id="cheak-ym">檢查是否成功啟動</h2>

> kubectl get all

```
NAME                                     READY            STATUS      RESTARTS      AGE
pod/ sqldb                                1/1     Running       0         7m29s
pod/httpd-5fd6d6d694-8rdvx   1/1     Running       0        7m29s
pod/httpd-5fd6d6d694-fjp8l   1/1     Running       0           7m29s
 
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE     SELECTOR
service/kubernetes   ClusterIP   172.30.0.1     <none>        443/TCP    2d9h    <none>
service/service      ClusterIP   172.30.0.181   <none>        3306/TCP   6m44s   app=sql
service/svc-sp       ClusterIP   172.30.0.180   120.96.143.50   8080/TCP   7m29s
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/httpd   2/2     2            2           7m29s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/httpd-5fd6d6d694   2         2         2       7m29s

NAME                                         REFERENCE          TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hpa-sp   Deployment/httpd   3%/30%    2         6         2          7m29s
```
---
**[上一頁 - 製作 & 測試 images](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Images.md)**

**[下一頁 - 高效能](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Load_balancing.md)**