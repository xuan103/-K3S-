# Automatic maintenance 

## 目錄

- 建置 K3S
    - [自動維護](#Automatic)
---
<h2 id="auto">自動維護</h2>

- ### 查看應用系統名稱
> echo $(kubectl get pod --selector=app=httpd --output=jsonpath={.items..metadata.name})
httpd-5fd6d6d694-qzns8 httpd-5fd6d6d694-pncvb

- ### 刪除其中一個應用系統的名稱
> kd pod httpd-5fd6d6d694-pncvb
pod "httpd-5fd6d6d694-pncvb" deleted
 

- ### 可以看到 應用系統即使被刪除也會馬上生出來
> echo $(kubectl get pod --selector=app=httpd --output=jsonpath={.items..metadata.name})
httpd-5fd6d6d694-qzns8 httpd-5fd6d6d694-f2swl

- ### 開啟 readiness 探測功能
> nano alpine.base.yml
```
...
       readinessProbe:  #提供readiness探測功能
        exec:
           command:
           - /bin/bash
           - -c
           - ls /
         initialDelaySeconds: 20 #系統啟動20秒後開始探測
         periodSeconds: 5 

$ kubectl get pod
httpd-6495df464c-zwjpt   0/1     Running   0          16s
httpd-6495df464c-ntds2   0/1     Running   0          16s
httpd-6495df464c-ntds2   1/1     Running   0          23s
httpd-6495df464c-zwjpt   1/1     Running   0          26s
```
---
**[上一頁 - 一鍵部署 - 進退版](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/One_step_deployment.md)**

**[下一頁 - 隨需擴充](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Autoscaling.md**