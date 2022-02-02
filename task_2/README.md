###################
# My Homework Task_2
1. Если подключаться к Pod по IP адресу используя curl, то увидим содержимое, которое отдаёт Nginx, в данном случаe hostname контейнера.
2. Если подключаться изнутри другого pod, то также видим отображение страницы отдаваемой Nginx.
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS       AGE     IP           NODE            NOMINATED NODE   READINESS GATES
dnsutils               1/1     Running   44 (31m ago)   3d22h   10.44.0.3    k8s-worker-01   <none>           <none>
web-6745ffd5c8-6cm7k   1/1     Running   0              17m     10.44.0.9    k8s-worker-01   <none>           <none>
web-6745ffd5c8-bv5np   1/1     Running   0              17m     10.44.0.13   k8s-worker-01   <none>           <none>
web-6745ffd5c8-fgrpx   1/1     Running   0              17m     10.44.0.15   k8s-worker-01   <none>           <none>
web-6745ffd5c8-fmh62   1/1     Running   0              17m     10.44.0.5    k8s-worker-01   <none>           <none>
web-6745ffd5c8-gqdpm   1/1     Running   0              17m     10.44.0.12   k8s-worker-01   <none>           <none>
web-6745ffd5c8-hl8xp   1/1     Running   0              17m     10.44.0.10   k8s-worker-01   <none>           <none>
web-6745ffd5c8-mrmvc   1/1     Running   0              17m     10.44.0.11   k8s-worker-01   <none>           <none>
web-6745ffd5c8-p754q   1/1     Running   0              17m     10.44.0.14   k8s-worker-01   <none>           <none>
web-6745ffd5c8-pxqqb   1/1     Running   0              17m     10.44.0.7    k8s-worker-01   <none>           <none>
web-6745ffd5c8-r5kjb   1/1     Running   0              17m     10.44.0.8    k8s-worker-01   <none>           <none>

k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 10.44.0.15
web-6745ffd5c8-fgrpx
k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 10.44.0.5
web-6745ffd5c8-fmh62
k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 10.44.0.12
web-6745ffd5c8-gqdpm

k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl exec -it $(kubectl get pod |awk '{print $1}'|grep web-|head -n1) bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@web-6745ffd5c8-6cm7k:/# curl 10.44.0.15
web-6745ffd5c8-fgrpx
root@web-6745ffd5c8-6cm7k:/# curl 10.44.0.12
web-6745ffd5c8-gqdpm
root@web-6745ffd5c8-6cm7k:/# curl 10.44.0.14
web-6745ffd5c8-p754q#
```
3. Подключение с PC т.е снаружи, ничего не отдаёт т.к по умолчанию доступа внутрь кластера и на поды нет.

## Подключение к сервисам
1. Если подключаться к сервису, то рандомно или round-robin отвечает контейнер, на который ссылается данный сервис.
2. Подключение с PC т.е снаружи, ничего не отдаёт т.к по умолчанию доступа внутрь кластера и на сервисы нет.
3. Если подключаться к сервису изнутри pod, то также видим отображение страницы отдаваемой Nginx с разных подов (рандомно или round-robin)

```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        6d15h
web            ClusterIP   10.101.92.196   <none>        80/TCP         4d
web-headless   ClusterIP   None            <none>        80/TCP         4d
web-np         NodePort    10.111.209.14   <none>        80:31409/TCP   17h

k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 10.101.92.196
web-6745ffd5c8-pxqqb
k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 10.101.92.196
web-6745ffd5c8-fmh62

k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl exec -it $(kubectl get pod |awk '{print $1}'|grep web-|head -n1) bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@web-6745ffd5c8-6cm7k:/# curl 10.101.92.196
web-6745ffd5c8-mrmvc
root@web-6745ffd5c8-6cm7k:/# curl 10.101.92.196
web-6745ffd5c8-r5kjb
root@web-6745ffd5c8-6cm7k:/# curl 10.101.92.196
web-6745ffd5c8-gqdpm
root@web-6745ffd5c8-6cm7k:/# curl 10.101.92.196
web-6745ffd5c8-hl8xp
root@web-6745ffd5c8-6cm7k:/#
```

4. NodePort, проверка доступности


```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        6d16h
web            ClusterIP   10.101.92.196   <none>        80/TCP         4d
web-headless   ClusterIP   None            <none>        80/TCP         4d
web-np         NodePort    10.111.209.14   <none>        80:31409/TCP   17h

k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 192.168.3.172:31409
web-6745ffd5c8-pxqqb
k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 192.168.3.172:31409
web-6745ffd5c8-mrmvc
k8s_adm@k8s-control:~/hw_labs/education/task_2$ curl 127.0.0.1:31409
web-6745ffd5c8-bv5np
k8s_adm@k8s-control:~/hw_labs/education/task_2$
```

# DNS
Создал pod с dnsutils

```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl apply -f dnsutils.yaml
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl get pods
NAME                   READY   STATUS    RESTARTS       AGE
dnsutils               1/1     Running   44 (46m ago)   3d22h


```

Содержимое /etc/resolv.conf внутри POD

```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl exec -it $(kubectl get pod |awk '{print $1}'|grep web-|head -n1) bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@web-6745ffd5c8-6cm7k:/# cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
root@web-6745ffd5c8-6cm7k:/#
```

Nslookup изнутри контейнера, clusterip отдаёт один IP через который идут запросы на pod-ы, headless отдаёт рандомно или round-robin IP адрес pod-ов.

```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl get pods | grep dnsutils
dnsutils               1/1     Running   44 (56m ago)   3d22h
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        6d16h
web            ClusterIP   10.101.92.196   <none>        80/TCP         4d1h
web-headless   ClusterIP   None            <none>        80/TCP         4d
web-np         NodePort    10.111.209.14   <none>        80:31409/TCP   18h
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl exec -it dnsutils bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@dnsutils:/# nslookup web
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   web.default.svc.cluster.local
Address: 10.101.92.196

root@dnsutils:/# nslookup web-headless
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.9
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.8
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.12
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.15
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.10
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.13
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.11
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.5
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.14
Name:   web-headless.default.svc.cluster.local
Address: 10.44.0.7

root@dnsutils:/#
```
![](/task_2/img/2022-01-27_160733.png)

Определение владельцев pods в namespace kube-system. Написал небольшой скрипт.
```bash
#!/bin/bash

namespace=kube-system

for var in $(kubectl get pods --namespace=$namespace | awk '{print $1}' | sed '1d')
do
echo $var $(kubectl describe pods $var --namespace=$namespace | grep "Controlled By:")
done
```
Результат выполнения:
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ ./script.sh | column -t
coredns-64897985d-dxj8l              Controlled  By:  ReplicaSet/coredns-64897985d
coredns-64897985d-z8zz2              Controlled  By:  ReplicaSet/coredns-64897985d
etcd-k8s-control                     Controlled  By:  Node/k8s-control
kube-apiserver-k8s-control           Controlled  By:  Node/k8s-control
kube-controller-manager-k8s-control  Controlled  By:  Node/k8s-control
kube-proxy-4gn6m                     Controlled  By:  DaemonSet/kube-proxy
kube-proxy-8vjwn                     Controlled  By:  DaemonSet/kube-proxy
kube-scheduler-k8s-control           Controlled  By:  Node/k8s-control
metrics-server-6bddbb84d6-npfx2      Controlled  By:  ReplicaSet/metrics-server-6bddbb84d6
weave-net-22tdp                      Controlled  By:  DaemonSet/weave-net
weave-net-jk4tp                      Controlled  By:  DaemonSet/weave-net
```

# Canary deployment

Создано 2 Deployment, один отдаёт содержимое html странички с текстом Application_v1, второй с Application_v2

Содержимое ConfigMap
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ cat nginx-configmap.yaml
apiVersion: v1
data:
  default.conf: |-
    server {
        listen 80 default_server;
        server_name _;
        default_type text/plain;

        location / {
            return 200 'Application_v1\n';
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: nginx-configmap
k8s_adm@k8s-control:~/hw_labs/education/task_2$ cat nginx-configmap-v2.yaml
apiVersion: v1
data:
  default.conf: |-
    server {
        listen 80 default_server;
        server_name _;
        default_type text/plain;

        location / {
            return 200 'Application_v2\n';
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: nginx-configmap-v2
k8s_adm@k8s-control:~/hw_labs/education/task_2$
```

Содержимое Deployments
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ cat deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
  name: web
spec:
  replicas: 10
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        ports:
        - containerPort: 80
        volumeMounts:
          - name: config-nginx
            mountPath: /etc/nginx/conf.d
      volumes:
        - name: config-nginx
          configMap:
            name: nginx-configmap
```
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ cat deployment-v2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
  name: web-canary
spec:
  replicas: 0
  selector:
    matchLabels:
      app: web
      type: canary
  template:
    metadata:
      labels:
        app: web
        type: canary
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        ports:
        - containerPort: 80
        volumeMounts:
          - name: config-nginx
            mountPath: /etc/nginx/conf.d
      volumes:
        - name: config-nginx
          configMap:
            name: nginx-configmap-v2
```

У сервиса web в качестве selector указано app:web, оба deployment имеют label web, т.е сервис будет посылать запросы на оба Deployments. У Ingree в качестве backend указан service:web, запросы будут идти на нужный нам сервис.

```bash
k8s_adm@k8s-control:~/hw_labs/education/task_2$ kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        6d17h
web            ClusterIP   10.101.92.196   <none>        80/TCP         4d2h
web-headless   ClusterIP   None            <none>        80/TCP         4d1h
web-np         NodePort    10.111.209.14   <none>        80:31409/TCP   18h
k8s_adm@k8s-control:~/hw_labs/education/task_2$ cat service_template.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: web
  name: web
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: web
  type: ClusterIP
status:
  loadBalancer: {}
k8s_adm@k8s-control:~/hw_labs/education/task_2$ cat ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-web
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
             name: web
             port:
                number: 80
```


Ссылка на youtube видео с демонстрацией Canary Deployment:
https://youtu.be/rdPyBsMNphg


###################


<details>
<summary>Description the task_2, created by original author the course.</summary>

# Task 2
### ConfigMap & Secrets
```bash
kubectl create secret generic connection-string --from-literal=DATABASE_URL=postgres://connect --dry-run=client -o yaml > secret.yaml
kubectl create configmap user --from-literal=firstname=firstname --from-literal=lastname=lastname --dry-run=client -o yaml > cm.yaml
kubectl apply -f secret.yaml
kubectl apply -f cm.yaml
kubectl apply -f pod.yaml
```
## Check env in pod
```bash
kubectl exec -it nginx -- bash
printenv
```
### Sample output (find our env)
```bash
Unable to use a TTY - input is not a terminal or the right kind of file
printenv
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
DATABASE_URL=postgres://connect
HOSTNAME=nginx
PWD=/
PKG_RELEASE=1~buster
HOME=/root
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
NJS_VERSION=0.6.2
SHLVL=1
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
lastname=lastname
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
firstname=firstname
NGINX_VERSION=1.21.3
_=/usr/bin/printenv
```
### Create deployment with simple application
```bash
kubectl apply -f nginx-configmap.yaml
kubectl apply -f deployment.yaml
```
### Get pod ip address
```bash
kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
web-5584c6c5c6-6wmdx   1/1     Running   0          4m47s   172.17.0.11   minikube   <none>           <none>
web-5584c6c5c6-l4drg   1/1     Running   0          4m47s   172.17.0.10   minikube   <none>           <none>
web-5584c6c5c6-xn466   1/1     Running   0          4m47s   172.17.0.9    minikube   <none>           <none>
```
* Try connect to pod with curl (curl pod_ip_address). What happens?
* From you PC
* From minikube (minikube ssh)
* From another pod (kubectl exec -it $(kubectl get pod |awk '{print $1}'|grep web-|head -n1) bash)
### Create service (ClusterIP)
The command that can be used to create a manifest template
```bash
kubectl expose deployment/web --type=ClusterIP --dry-run=client -o yaml > service_template.yaml
```
Apply manifest
```bash
kubectl apply -f service_template.yaml
```
Get service CLUSTER-IP
```bash
kubectl get svc
```
### Sample output
```bash
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   20h
web          ClusterIP   10.100.170.236   <none>        80/TCP    28s
```
* Try connect to service (curl service_ip_address). What happens?

* From you PC
* From minikube (minikube ssh) (run the command several times)
* From another pod (kubectl exec -it $(kubectl get pod |awk '{print $1}'|grep web-|head -n1) bash) (run the command several times)
### NodePort
```bash
kubectl apply -f service-nodeport.yaml
kubectl get service
```
### Sample output
```bash
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        20h
web          ClusterIP   10.100.170.236   <none>        80/TCP         15m
web-np       NodePort    10.101.147.109   <none>        80:30682/TCP   8s
```
Note how port is specified for a NodePort service
### Checking the availability of the NodePort service type
```bash
minikube ip
curl <minikube_ip>:<nodeport_port>
```
### Headless service
```bash
kubectl apply -f service-headless.yaml
```
### DNS
Connect to any pod
```bash
cat /etc/resolv.conf
```
Compare the IP address of the DNS server in the pod and the DNS service of the Kubernetes cluster.
* Compare headless and clusterip
Inside the pod run nslookup to normal clusterip and headless. Compare the results.
You will need to create pod with dnsutils.
### [Ingress](https://kubernetes.github.io/ingress-nginx/deploy/#minikube)
Enable Ingress controller
```bash
minikube addons enable ingress
```
Let's see what the ingress controller creates for us
```bash
kubectl get pods -n ingress-nginx
kubectl get pod $(kubectl get pod -n ingress-nginx|grep ingress-nginx-controller|awk '{print $1}') -n ingress-nginx -o yaml
```
Create Ingress
```bash
kubectl apply -f ingress.yaml
curl $(minikube ip)
```
### Homework
* In Minikube in namespace kube-system, there are many different pods running. Your task is to figure out who creates them, and who makes sure they are running (restores them after deletion).

* Implement Canary deployment of an application via Ingress. Traffic to canary deployment should be redirected if you add "canary:always" in the header, otherwise it should go to regular deployment.
Set to redirect a percentage of traffic to canary deployment.
</details>
