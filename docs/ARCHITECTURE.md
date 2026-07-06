# Architecture (fill this in)

## 1. Topology diagram
> Draw it (ASCII, Excalidraw, draw.io — anything). Show: your nodes, where each TaskApp
> tier runs, the ingress controller, and the request path.

```
                          Internet
                              │
                              ▼
                     DNS (5fty3.name.ng)
                              │
                              ▼
                  Traefik Ingress Controller
                              │
                 HTTPS (TLS via cert-manager)
                              │
          ┌───────────────────┴───────────────────┐
          ▼                                       ▼
   Frontend Service                        Backend Service
          │                                       │
   frontend Pod 1                         backend Pod 1
   (Control Plane)                        (Control Plane)
          │                                       │
   frontend Pod 2                         backend Pod 2
   (Worker Node)                          (Worker Node)
          │                                       │
          └─────────────── /api ──────────────────┘
                              │
                              ▼
                      PostgreSQL Service
                              │
                        postgres-0 Pod
                        Persistent Volume Claim

## 2. Node & network
- Nodes (role, size, AZ/region): …
Control Plane
• t3.small
• eu-north-1
• Runs Kubernetes control plane, one frontend Pod, one backend Pod and PostgreSQL

Worker 1
• t3.small
• eu-north-1

Worker 2
• t3.small
• eu-north-1
• Runs frontend and backend workloads

- CIDR / subnet choices and why: 
The cluster was deployed inside a VPC using private networking between nodes. Kubernetes assigned Pod IPs using the K3s default Pod CIDR, allowing Pods on different nodes to communicate without exposing them publicly.

- Firewall: what's open to the world, what's internal, and why `6443` is closed: …
Only HTTP (80), HTTPS (443), and SSH (22) are exposed to the internet. Internal Kubernetes communication occurs over the private VPC network. Port 6443, used by the Kubernetes API server, is not publicly accessible to reduce the attack surface.

## 3. Request flow (one paragraph)
A client accesses https://5fty3.name.ng, which resolves through DNS to the cluster's public endpoint. Traefik receives the HTTPS request and terminates TLS using certificates issued by cert-manager and Let's Encrypt. Requests for the frontend are forwarded to the frontend Service, which load balances traffic across frontend Pods. API requests are proxied from the frontend to the backend Service. The backend communicates with PostgreSQL through the postgres Service, which routes traffic to the PostgreSQL StatefulSet using a Persistent Volume Claim for durable storage.

## 4. The single-server assumptions you fixed  
| Single server assumption                          | Why it breaks at scale                                                     | How you fixed it                                                                            |
| ------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Database migrations executed on container startup | Multiple backend replicas could execute migrations simultaneously          | Database migrations were separated from normal application startup to avoid race conditions |
| Local Docker volume                               | Data would be lost if the Pod moved to another node                        | Used a StatefulSet with a Persistent Volume Claim                                           |
| Exposing application ports directly on the host   | Multiple Pods across multiple nodes cannot all bind to the same host ports | Used Kubernetes Services and Traefik Ingress                                                |
| One application instance                          | Failure causes downtime                                                    | Deployed multiple frontend and backend replicas with Kubernetes self healing                |
| Manual restarts during deployment                 | Causes service interruption                                                | Used RollingUpdate deployments with readiness probes for zero downtime updates              |
| Secrets stored in configuration files             | Sensitive values become exposed                                            | Stored credentials in Kubernetes Secrets                                                    |




## 5. Choices & trade-offs
Raw YAML vs Helm vs Kustomize

Raw Kubernetes YAML was used because it provides full control over every resource and makes it easier to understand the underlying Kubernetes objects during learning.

Traefik vs ingress-nginx

Traefik was chosen because it is bundled with K3s, reducing installation complexity while providing full Ingress functionality.

CNI / NetworkPolicy

The default K3s networking stack was used. NetworkPolicies were not required for this project because the focus was application deployment and high availability rather than network isolation.

Secrets

Kubernetes Secrets were used to store database credentials separately from application manifests. This keeps sensitive information out of the deployment configuration.