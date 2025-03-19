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