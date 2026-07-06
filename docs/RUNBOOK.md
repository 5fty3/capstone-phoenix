
Provision from zero
# 1. Provision AWS infrastructure
cd infra/terraform
terraform init
terraform apply
# 2. Configure the Kubernetes cluster
cd ../ansible
ansible-playbook -i inventory site.yml
# 3. Configure kubectl
export KUBECONFIG=./kubeconfig
kubectl get nodes
# 4. Install platform components
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl create namespace argocd

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# 5. Deploy GitOps application
kubectl apply -f gitops/

Argo CD then synchronizes the TaskApp manifests automatically.

Day-2 operations
Scale a tier

Preferred approach:

Update the Git manifest.
Commit and push the change.
Allow Argo CD to synchronize automatically.

Manual (temporary):

kubectl scale deployment frontend --replicas=3 -n taskapp
Roll back a bad deployment

Preferred:

Revert the Git commit.
Push the revert.
Argo CD synchronizes the previous version.

Manual:

kubectl rollout undo deployment/frontend -n taskapp
Run a new migration safely
Scale backend replicas to one (or use a Kubernetes Job).
Execute the database migration.
Verify success.
Scale the backend back to the desired replica count.

This prevents multiple Pods from attempting the same migration simultaneously.

Rotate a secret

Update the Kubernetes Secret manifest.

kubectl apply -f postgres-secret.yaml

Restart affected workloads if required.

Commit the updated manifest so Argo CD remains the source of truth.

Failure recovery
Worker node failure

Drain the worker node:

kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

Kubernetes automatically schedules affected Pods onto healthy nodes.

Expected recovery time:

30 to 60 seconds, depending on image pull time and readiness probes.

Backend Pod crash looping

Check the Pod:

kubectl describe pod <pod-name> -n taskapp

View logs:

kubectl logs <pod-name> -n taskapp

If the container restarted:

kubectl logs --previous <pod-name> -n taskapp

Also inspect cluster events:

kubectl get events -n taskapp --sort-by=.metadata.creationTimestamp
Bad database migration

Restore the previous database backup or roll back the migration using the migration tool.

Redeploy the corrected backend image after the database state has been restored.

PostgreSQL Pod rescheduled

Delete the PostgreSQL Pod:

kubectl delete pod postgres-0 -n taskapp

Wait for it to be recreated.

Verify that the Persistent Volume Claim has reattached:

kubectl get pvc -n taskapp

Connect to PostgreSQL:

kubectl exec -it postgres-0 -n taskapp -- sh
su - postgres
psql -U taskapp_user -d taskapp

Confirm the persistence test data still exists:

SELECT * FROM persistence_test;