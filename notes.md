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

## Gateways, gateways, gateways

A Kubernetes Ingress Resources exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.