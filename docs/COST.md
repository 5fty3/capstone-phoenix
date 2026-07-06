# Cost (fill this in)

This echoes the Docker lesson's "why one server" thread — except now the answer to "is the
extra cost worth it?" is yours to argue.

## Monthly itemized cost
| Item                | Spec                | Qty |     $/mo (Approx.) |
| ------------------- | ------------------- | --: | -----------------: |
| Control plane VM    | EC2 t3.small        |   1 |         **$15.18** |
| Worker VMs          | EC2 t3.small        |   2 |         **$30.36** |
| Block storage (PVC) | 5 GB gp3 EBS        |   1 |          **$0.40** |
| Elastic IP          | Public IPv4 address |   1 |          **$3.60** |
| DNS / Domain        | `.name.ng`          |   1 |          **$0.50** |
| **Total**           |                     |     | **≈ $50.04/month** |


## Compared to the single-server Compose+Portainer deploy
Approximately $15.18/month, since only one EC2 t3.small instance was required.

This Kubernetes cluster

Approximately $50.04/month, including three EC2 instances, persistent storage, one public IPv4 address, and the domain.

What the extra spend buys

The additional cost provides higher availability through multiple nodes, automatic Pod recovery, rolling updates with zero downtime, Horizontal Pod Autoscaling, and workload distribution across the cluster. These capabilities improve resilience and make the application more suitable for production environments. For small personal projects or low traffic applications, a single server deployment is usually more cost effective.

## How I'd halve this
I would reduce costs by using Spot Instances for the worker nodes, scaling the cluster down during periods of low usage, and using smaller instance types for development workloads. A single worker node would also reduce costs while still allowing Kubernetes features to be demonstrated.