sudo microk8s enable dns storage

sudo helm repo add crossplane-stable https://charts.crossplane.io/stable

sudo helm repo update

sudo helm install crossplane --namespace crossplane-system --create-namespace crossplane-stable/crossplane --kubeconfig /var/snap/microk8s/current/credentials/kubelet.config

sudo microk8s kubectl get all -n crossplane-system
