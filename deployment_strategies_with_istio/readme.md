
# Create setup

These exercises will introduce you to the match, weight and mirror fields of the HTTPRoute. These fields and their combinations can be used to enable several useful deployment patterns like blue/green deployments, canary deployments and shadow deployments.

Deploy workloads vs and dr:

```bash
# deploy only v1 for age and sentence workloads
kubectl apply -f deployment_strategies_with_istio

# deploy 2 versions for name workload
kubectl apply -f name_versions

# we're levreaging version label
kubectl  get po -L version

# age-v1-6bcd598594-dstq2         2/2     Running   0          51m   v1
# name-v1-ccb8cbc4f-4l9n7         2/2     Running   0          49m   v1
# name-v2-569fffb445-x4qnl        2/2     Running   0          49m   v2
# sentences-v1-76cbf4f647-zd27h   2/2     Running   0          51m   v1

# we have 1 vanilla vs and dr
kubectl get virtualservices.networking.istio.io
kubectl get destinationrules.networking.istio.io
```

Forward sentence svc before generating traffic

```bash
kubectl port-forward svc/sentences 5000:5000
```

Generate traffic 

```bash
# simple
./traffic_gen.sh

# with the x-test header
./traffic_gen.sh 'x-test: use-v2'
```

### Vanilla

Vanilla Istio provides the least requests [load balancing policy](https://istio.io/latest/docs/concepts/traffic-management/#load-balancing-options), where requests are distributed among the instances with the least number of requests

So the `vs.yaml` will be vanilla.  
Warning: virtualService rule #1 not used (only the last rule can have no matches)

In both cases of generating traffic, you should see the traffic being routed to the `name-v1` workload because of the precedence of the routes in the name virtual service.


### Blue/Green

We want to implement a blue/green deployment pattern which allows the client to actively select a version of the name service it will hit.

In the example above we define a HTTPMatchRequest with the field match. The headers field declares that we want to match on request headers. The HTTPRoute match field in a virtual service. 

The exact field declares that the header must match exactly use-v2.

Istio allows to use other parts of incoming requests and match them to values you define
To redirect traffic we need to update virtual service with match block [with header condition](https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPMatchRequest). 

To redirect ONLY to name v2 we're going to us `kubectl apply -f enable_bg_deployment/vs_with_block_header.yaml`

Don't forget to check Display Idle Edges in Kiali, Traffic Graph

You should see all traffic being generated with `./traffic_gen.sh 'x-test: use-v2'` directed to `name-v2` of the name workload. That is because the match evaluated to true and the route under the match block is used.

Whereas `./traffic_gen.sh` will go to `name-v1`. You should now see all traffic being routed to v1 of the name workload. This is because when the match did not evaluate to true the default route was used.

Notice the indentation for the route to name-v1, which is our default route. E.g the route to name-v2 is nested under the match block. That is a different route...

### Canary

Canary deployment is a pattern for rolling out releases to a subset of users/clients. The idea is to test and gather feedback from this subset and reduce risk by gradually introducing a new release. (using HTTPRoute weight field in a virtual service)

We want to implement a canary deployment pattern to the name service's `v1` and `v2` workloads and header based blue/green deployment to a `v3` workload

Deploy v3 of name service `kubectl apply -f name_versions/name-v3.yaml`

Uncomment in `name-dr` to include the 3rd version and uncomment `name-vs` for enable B/G for v3

`./traffic_gen.sh` traffic should still be routed to the v1 workload as the match condition did not evaluate to true and order of precedence dictates the first destination which will direct traffic to v1 workload.

Apply new vs `kubectl apply -f enable_canary_deployment/vs_with_weight.yaml` you should see 90% to v1 and 10% to v2.

Generate traffic to v3 `./traffic_gen.sh 'x-test: use-v3'`

### Forward stuff

```bash
# run from local
kubectl port-forward svc/kiali 20001:20001 -n istio-system
kubectl port-forward svc/prometheus 9090:9090 -n istio-system
kubectl port-forward svc/grafana 3000:3000 -n istio-system
```
