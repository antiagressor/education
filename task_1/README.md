###################
# My Homework Task_1
1. Поднял локально на Ubuntu Server 20.04 свежую версию Kubernetes 1.23
2. Проделал все операции описанные в рамках task_1, установка Dashboard, Metrics server и.т.п. 

Dashboard install
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
```
Metrics install
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
Для доступа с локальной машины в dashboard, пришлось отредактировать service kubernetes-dashboard, прокинуть порт tcp 32321 и поменять тип с ClusterIP на NodePort.
```bash
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"k8s-app":"kubernetes-dashboard"},"name":"kubernetes-dashboard","namespace":"kubernetes-dashboard"},"spec":{"ports":[{"port":443,"targetPort":8443}],"selector":{"k8s-app":"kubernetes-dashboard"}}}
  creationTimestamp: "2022-01-23T05:36:10Z"
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  resourceVersion: "23095"
  uid: e47e72be-2264-4652-b023-a93045b3b15c
spec:
  clusterIP: 10.109.74.122
  clusterIPs:
  - 10.109.74.122
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 32321
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```
На скрине рабочий Dashboard.
![](/task_1/img/2022-01-23_181815.png)

3. В рамках HW написал deployment с 3-мя репликами и запустил. При попытке удалить одну из реплик, k8s автоматически создаёт новую т.к кол-во реплик должно быть 3.
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_1$ cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Применение
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_1$ kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
```

Результат
```bash
k8s_adm@k8s-control:~/hw_labs/education/task_1$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
nginx                              1/1     Running   0          6h1m
nginx-deployment-8d545c96d-frx9l   1/1     Running   0          50m
nginx-deployment-8d545c96d-tt7h5   1/1     Running   0          50m
nginx-deployment-8d545c96d-v2gjw   1/1     Running   0          50m
```
![](/task_1/img/2022-01-23_181548.png)

###################

<details>
<summary>Description the task_1, created by original author the course.</summary>

# Task 1.1
Requirements:
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
## Verify kubectl installation
```bash
kubectl version --client
```
Output, that indicates that everything is working.
```bash
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"windows/amd64"}
```

## Setup autocomplete for kubectl
```bash
source <(kubectl completion bash) 
```

```bash
minikube start --driver=virtualbox
```
## Get information about cluster
```bash
$ kubectl cluster-info
```
Sample output, that indicates that everything is working.
```bash
Kubernetes master is running at https://192.168.99.107:8443
CoreDNS is running at https://192.168.99.107:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'
```
## get information about available nodes
```bash
$ kubectl get nodes
```
Sample output, that indicates that everything is working.
```bash
NAME       STATUS   ROLES                  AGE     VERSION
minikube   Ready    control-plane,master   9m52s   v1.22.2
```

# Install [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
```
# Check kubernetes-dashboard ns
```bash
 kubectl get pod -n kubernetes-dashboard
```
Sample output
```bash
NAME                                         READY   STATUS    RESTARTS   AGE
dashboard-metrics-scraper-5594697f48-ng9x6   1/1     Running   0          30m
kubernetes-dashboard-57c9bfc8c8-qjt2s        1/1     Running   0          30m
```
# Install [Metrics Server](https://github.com/kubernetes-sigs/metrics-server#deployment)
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Update deployment
```bash
kubectl edit -n kube-system deployment metrics-server
```
```bash
spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-insecure-tls
        - --kubelet-use-node-status-port
```

# Connect to Dashboard
## Get token
### Manual

```bash
kubectl describe sa -n kube-system default
# copy token name
kubectl get secrets -n kube-system
kubectl get secrets -n kube-system token_name_from_first_command -o yaml
echo -n "token_from_previous_step" | base64 -d
```
# Same thing in one command
```bash
 kubectl get secrets -n kube-system $(kubectl describe sa -n kube-system default|grep Tokens|awk '{print $2}') -o yaml|grep -E "^[[:space:]]*token:"|awk '{print $2}'|base64 -d
```

### Auto
```bash
export SECRET_NAME=$(kubectl get sa -n kube-system default -o jsonpath='{.secrets[0].name}')
export TOKEN=$(kubectl get secrets -n kube-system $SECRET_NAME -o jsonpath='{.data.token}' | base64 -d)
echo $TOKEN
```

## Connect to Dashboard
```bash
kubectl proxy
```
In browser connect to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

# Task 1.2
# Kubernetes resources introduction
```bash
kubectl run web --image=nginx:latest
```
- take a look at created resource in cmd "kubectl get pods"
- take a look at created resource in Dashboard
- take a look at created resource in cmd
```bash
minikube ssh
docker container ls
```

## [Specification](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/)
```bash
kubectl explain pods.spec
```
Apply manifests (download from repository)
```bash
kubectl apply -f pod.yaml
kubectl apply -f rs.yaml
```
Look at pod
```bash
kubectl get pod
```
# You can create simple manifest from cmd
```bash
kubectl run web --image=nginx:latest --dry-run=client -o yaml
```
### Homework
* Create a deployment nginx. Set up two replicas. Remove one of the pods, see what happens.
</details>
