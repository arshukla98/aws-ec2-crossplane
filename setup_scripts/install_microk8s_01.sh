# Install MicroK8s

sudo apt update

sudo apt install snapd

sudo snap install core

sudo snap refresh core

sudo snap install microk8s --classic

echo 'Setting Permissions'
sudo usermod -a -G microk8s ubuntu
sudo grep microk8s /etc/group
sudo groups ubuntu
sudo mkdir -p ~/.kube
sudo chown -R ubuntu ~/.kube
