# One_step_deployment


## 目錄

- 建置 K3S
    - [一鍵部署 - 進退版](#One_step_deployment)
        - [進版](#before)
        - [退版](#after)

---
<h2 id="before">進版</h2>

- ### 一鍵進版
> kubectl set image deployment.v1.apps/httpd httpd=alpine.base --record

- ### 查看目前 image
> kubectl describe pod httpd


<h2 id="after">退版</h2>

- ### 除所有物件
> kubectl delete -f .

- ### 更改設定檔
> nano alpine.base.yml

- ### 重啟所有物件並觀察 pod 的啟動時間
> kubectl appy -f
> kubectl get pod --watch

---
**[上一頁 - 高效能](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Load_balancing.md)**

**[下一頁 - 自動維護](https://github.com/xuan103/k3s-Enterprise-Application-System/blob/main/Documents/Automatic_maintenance%20.md)**

