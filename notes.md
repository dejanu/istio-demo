# I was today years old when I found out about Kubernetes Native Sidecars in Istio


## What are sidecars?

A Pod can have one or more containers. So your app runs in a container, but what happens if you would like to add new capabilities like logging, monitoring, security without altering the application code and consequently the main app image, container?

The answer: sidecar containers, they run concurrently with the main application container within the same Pod, and share the same network and storage namespace with the primary container. This coupling allows sidecar containers to easily interact and share resources with the main app container.

## When to use sidecars?

Whenever you want log collection in your pods, or network proxies. One of the best example is Istio, in which a proxy server is deployed as a sidecar container alongside your application container.

## Istio and sidecar?

Istio service mesh, leverages the sidecar pattern, by deploying a proxy container (to intercept all your network traffic) next to your application container. But the proxy container has no value without the primary (app) container.

## Important Notes

Technically Kubernetes implements sidecar containers as a special case of init containers (check Kubernetes v1.28: Introducing native sidecar containers)

## Gateways: k8s API objects vs Istio gateway

K8S Ingress Resource exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.

K8S Gateway is the successor to the Ingress API (it represents the next generation of Kubernetes ingress, load balancing, and service mesh APIs). However, it does not include the Ingress resource (the closest parallel is the HTTPRoute).

You use a gateway to manage inbound and outbound traffic for your mesh, letting you specify which traffic you want to enter or leave the mesh

Istio provides some preconfigured gateway proxy deployments (`istio-ingressgateway` and `istio-egressgateway`) that you can use. 

Istio defines its own [Gateway resource](https://istio.io/latest/docs/reference/glossary/#gateway)
```bash
# k8s ingress API object
kubectl get ingresses.networking.k8s.io -A

# check if Gateway API CRD are present
kubectl get crd gateways.gateway.networking.k8s.io
kubectl get gateways.gateway.networking.k8s.io -A

# istio 
kubectl get gateways.networking.istio.io -A 
```

## Istio CRDs

VirtualService = extension of the service object (allows for routing decisions). Define a list of routes where you match on the content in the requests (i.e. headers, method, path) and  make routing decision based on those (service version routing)
DestinationRule = policies applied to traffic after routing has occured (lood balancing, pool size). Destination rules configure what happens to traffic for a destination defined in a virtual service.

Main takeaways are:

A virtual services hosts field is a user addressable destination and can be virtual.

A virtual services destination must exist. In Kubernetes this will be a Kubernetes Service.

A destination rule defines traffic policies that apply for the intended service after routing has occurred with a virtual service. E.g. route all traffic to v1, different load balancing modes for v1 and v2, etc.