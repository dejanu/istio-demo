# istio-demo

A service mesh or simply mesh is an infrastructure layer that enables managed, observable and secure communication between workload instances.

An Istio service mesh is logically split into a data plane and a control plane.
From the data-plane perspective Istio support two modes:

* sidecar mode (an envoy proxy running concurrently with the main application container within the same Pod)
* ambient mode (all traffic is proxied through a Layer 4-only node-level ztunnel proxies deployed as a DaemonSet)

### Requirements

Istio generally [requires](https://istio.io/latest/docs/ops/deployment/platform-requirements/) Kubernetes nodes running Linux kernels with `iptables` support in order to function.


### Installation

Download [Istio guide](https://istio.io/latest/docs/setup/getting-started/#download)

```bash
# istio 1.25.0
curl -L https://istio.io/downloadIstio | sh -

# add istioctl bin to path
export PATH=$PATH:$PWD/istio-1.25.0/bin/
```

Istio configuration profiles, are configs that provide customization of the istio (control plane and data plane), deployment topologies and target platforms.

Difference between `helm` and `istioctl` install mechanisms is that istioctl configuration profiles also include a list of Istio components that will be installed automatically by istioctl.

Further the `demo` profile is going to be used which has disabled the deployment of the default Istio gateway services

```bash
istioctl install -f bookinfo/demo-profile-no-gateways.yaml -y
# Istio core installed
# Istiod installed
# istio-system ns created: kubectl -n istio-system get all
```

### Gateways

* A **gateway** is a standalone Istio proxy deployed at the edge of the mesh. Gateways are used to route traffic into or out of the mesh
* The **Kubernetes Gateway API** is a configuration API for traffic routing in Kubernetes. It represents the next generation of Kubernetes ingress, load balancing, and service mesh APIs, and is designed with learnings from Istio’s traditional APIs.

The Kubernetes Gateway API CRDs do not come installed by default on most Kubernetes clusters, so make sure they are installed before using the Gateway API.
```bash
# check if Gateway API CRD are present
kubectl get crd gateways.gateway.networking.k8s.io

# install it k8s gateway
kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.2.1" | kubectl apply -f -
....
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/grpcroutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/referencegrants.gateway.networking.k8s.io created
```

Add label to `default` namespace to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later:

```bash
kubectl label namespace default istio-injection=enabled
# check is ns was labeld
kubectl get ns -l istio-injection
```

### Deploy App

Deploy the BookInfo app:
```bash
kubectl apply -f bookinfo/platform/kube/bookinfo.yaml

# as each pod becomes read, istio sidecar will be deployed along with it
# check one of the pods
kubectl get po productpage-v1-dffc47f64-p9skv -ojsonpath=" {.s
pec.containers[*].name}"

# check if app is running, get the response (RATINGS POD)
kubectl get pod -l app=ratings -oname
kubectl exec ratings-v1-65f797b499-9zrh7  -c ratings -- curl -sS productpage:9080/productpage
```

### Expose app to outside traffic

Create k8s Gateway
```bash
kubectl apply -f bookinfo/gateway-api/bookinfo-gateway.yaml

# check if bookinfo-gateway has been created
kubectl get gateways.gateway.networking.k8s.io -A

# the gateway uses allowedRoutes: port: 80
kubectl port-forward svc/bookinfo-gateway-istio 8080:80
```

Access app product page on [your machine](http://127.0.0.1:8080/productpage)

### Understand the mesh

Install telemetry apps (Kiali,Grafana,Jaeger,Promethes) as addons
```bash
kubectl apply -f istio-1.25.0/samples/addons/
```
Acess Kiali
```bash
istioctl dashboard kiali
```
Generate traffic:
```bash
for i in $(seq 1 100); do curl -s -o /dev/null "http://localhost/productpage";done
```

## Cleanup

```bash
# delete gateway
kubectl delete -f bookinfo/gateway-api/bookinfo-gateway.yaml

# delete add onsss
kubectl delete -f istio-1.25.0/samples/addons/

# delete app 
kubectl delete -f bookinfo/platform/kube/bookinfo.yaml

# delete label
kubectl label ns default istio-injection-

# delete istio
istioctl uninstall -f bookinfo/demo-profile-no-gateways.yaml -y
```


### Istio config stuff


```bash
# Check istio sidecar containers
kubectl get pods -o=custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name

# Start a pod without envoy
kubectl run mybusyboxcurl --labels="sidecar.istio.io/inject=false" --image yauritux/busybox-curl -it -- sh
```

To remove the workload from mesh, just add annotation `sidecar.istio.io/inject: 'false'`, just try: `kubectl annotate --overwrite pods age-v1-6bcd598594-vxn5k sidecar.istio.io/inject=false` ??? To check
```yaml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sentences
      mode: age
      version: v1
  template:
    metadata:
      labels:
        app: sentences
        mode: age
        version: v1
      annotations:                          # Annotations block
        sidecar.istio.io/inject: 'false'    # True to enable or false to disable
    spec:
      containers:
      - image: praqma/istio-sentences:v1
```


### Links

* https://istio.io/latest/docs/setup/getting-started/#download