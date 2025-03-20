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

# install it
kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.2.1" | kubectl apply -f -
```


```bash
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/grpcroutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/referencegrants.gateway.networking.k8s.io created
```

Add namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later:

```bash
kubectl label namespace default istio-injection=enabled
```

### Links

* https://istio.io/latest/docs/setup/getting-started/#download