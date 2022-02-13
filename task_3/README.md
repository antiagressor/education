###################
# My Homework Task_3

1. Для публикации Minio через ingress, создал соответствующий ingress yaml. По пути http://masterNode_IP:port доступен Minio, по пути http://masterNode_IP:port/web доступно приложение, которое отдаёт текст Nginx_v1 (приложение из предыдущего таска самостоятельной работы). 

```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minio-nginx
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host:
    http:
      paths:
      - backend:
          service:
            name: nginx-v1
            port:
              number: 80
        path: /web
        pathType: Prefix
  - host:
    http:
      paths:
      - backend:
          service:
            name: minio-svc
            port:
              number: 9001
        path: /
        pathType: Prefix
status:
  loadBalancer: {}
```

2. Создан deployment с EmptyDir, создал внутри пода файл textfile в папке /data, после этого удалил pod, kubernetes создал новый. Т.к используется тип storage EmptyDir, то данные удаляются.

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myvolumes-deploy
  labels:
    app: alpine
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alpine
  template:
    metadata:
      labels:
        app: alpine
    spec:
      containers:
        - image: alpine
          name: myvolumes-container
          command: ['sh', '-c', 'echo The Bench Container 1 is Running ; sleep 3600']
          volumeMounts:
            - mountPath: /demo
              name: demo-volume
      volumes:
        - name: demo-volume
          emptyDir: {}
```
Ссылка на youtube видео с демонстрацией работы, описанной выше: https://youtu.be/I0R_STfj-mQ

###################

<details>
<summary>Description the task_3, created by original author.</summary>

# Task 3
### [Read more about CSI](https://habr.com/ru/company/flant/blog/424211/)
### Create pv in kubernetes
```bash
kubectl apply -f pv.yaml
```
### Check our pv
```bash
kubectl get pv
```
### Sample output
```bash
NAME                  CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
minio-deployment-pv   5Gi        RWO            Retain           Available                                   5s
```
### Create pvc
```bash
kubectl apply -f pvc.yaml
```
### Check our output in pv 
```bash
kubectl get pv
NAME                  CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                            STORAGECLASS   REASON   AGE
minio-deployment-pv   5Gi        RWO            Retain           Bound    default/minio-deployment-claim                           94s
```
Output is change. PV get status bound.
### Check pvc
```bash
kubectl get pvc
NAME                     STATUS   VOLUME                CAPACITY   ACCESS MODES   STORAGECLASS   AGE
minio-deployment-claim   Bound    minio-deployment-pv   5Gi        RWO                           79s
```
### Apply deployment minio
```bash
kubectl apply -f deployment.yaml
```
### Apply svc nodeport
```bash
kubectl apply -f minio-nodeport.yaml
```
Open minikup_ip:node_port in you browser
### Apply statefulset
```bash
kubectl apply -f statefulset.yaml
```
### Check pod and statefulset
```bash
kubectl get pod
kubectl get sts
```

### Homework
* We published minio "outside" using nodePort. Do the same but using ingress.
* Publish minio via ingress so that minio by ip_minikube and nginx returning hostname (previous job) by path ip_minikube/web are available at the same time.
* Create deploy with emptyDir save data to mountPoint emptyDir, delete pods, check data.
* Optional. Raise an nfs share on a remote machine. Create a pv using this share, create a pvc for it, create a deployment. Save data to the share, delete the deployment, delete the pv/pvc, check that the data is safe.
</details>
