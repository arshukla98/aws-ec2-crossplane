echo 'Check microk8s status'
sudo microk8s status --wait-ready

sleep 10

echo 'which microk8s -> ' which microk8s

echo 'PATH -> ' $PATH

sudo microk8s kubectl get nodes
