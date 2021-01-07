# Load_balancing


## 目錄

- 建置 K3S
    - [高效能](#load-balancing)

---
<h2 id="load-balancing">高效能</h2>

- ### 兩個一樣的應用系統可以自動提供平衡負載

> kubectl get pod
```
NAME                                     READY            STATUS      RESTARTS      AGE
pod/httpd-5fd6d6d694-8rdvx   1/1     Running       0        7m29s
pod/httpd-5fd6d6d694-fjp8l   1/1     Running       0           7m29s
```

- ### 會發現連到不同的應用系統
> curl '120.96.143.59:8080/hostname'
8rdvx 

> curl '120.96.143.59:8080/hostname'
8rdvx 

> curl '120.96.143.59:8080/hostname'
fjp8l 
---
**[上一頁 - 部署 images 到 k3s 叢集](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/K3S_Cluster.md)**

**[下一頁 - 一鍵部署 - 進退版](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/One_step_deployment.md)**