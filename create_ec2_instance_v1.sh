#!/bin/bash

generate_sg_yaml(){
cat <<EOF
apiVersion: ec2.aws.crossplane.io/v1beta1
kind: SecurityGroup
metadata:
  name: $sgCrossPlaneName
spec:
  forProvider:
    region: ap-south-1
      #vpcIdRef:
      #name: Default-VPC
    groupName: $sgName
    description: "Security Group for Access"
    ingress:
      - fromPort: 22
        toPort: 22
        ipProtocol: tcp
        ipRanges:
          - cidrIp: 0.0.0.0/0
    egress:
      - fromPort: 0
        toPort: 0
        ipProtocol: "-1"
        ipRanges:
          - cidrIp: 0.0.0.0/0
  providerConfigRef:
    name: crossplane-provider-config
EOF
}

# Function to generate YAML content
generate_yaml() {
cat <<EOF
apiVersion: ec2.aws.crossplane.io/v1alpha1
kind: Instance
metadata:
  name: $resourceName
  labels:
    instanceName: $vmName
    sgName: $sgName
spec:
  forProvider:
    region: $region
    imageId: $imageID
    instanceType: $instanceType
    keyName: $keyName
    securityGroupRefs:
      - name: $sgCrossPlaneName
    tags:
      - key: Name
        value: $vmName
  providerConfigRef:
    name: crossplane-provider-config
EOF
}

# Check if all required arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <imageID> <instanceType> <region> <keyName> <vmName>"
    exit 1
fi

# Assign command-line arguments to variables
imageID=$1
instanceType=$2
region=$3
keyName=$4
vmName=$5
resourceName="backstage-ec2-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

sgCrossPlaneName="backstage-sg-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"
sgName="aws-ec2-sg-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

# Call function to generate YAML
generate_sg_yaml > ec2-sg.yaml

generate_yaml > ec2-instance.yaml

echo "YAML file ec2-instance.yaml has been generated."

sudo microk8s kubectl create -f ec2-sg.yaml

# Wait for the security group to be synced
sudo microk8s kubectl wait --timeout=5m --for=condition=Synced securitygroup.ec2.aws.crossplane.io/$sgCrossPlaneName

sudo microk8s kubectl create -f ec2-instance.yaml

# Wait for the EC2 Instance to be ready
sudo microk8s kubectl wait --timeout=5m --for=condition=Ready instance.ec2.aws.crossplane.io/$resourceName

# sudo microk8s kubectl get securitygroups.ec2.aws.crossplane.io -A
# sudo microk8s kubectl get instances.ec2.aws.crossplane.io -A

sudo mkdir -p artifacts

# cd artifacts && sudo touch instanceInfo.txt

sudo microk8s kubectl describe instances.ec2.aws.crossplane.io -l "instanceName=$vmName" | sudo bash -c 'cat > artifacts/instanceInfo.txt'
# sudo microk8s kubectl get instances -o=jsonpath='{range .items[?(@.spec.forProvider.tags[0].value==<instanceName>)]}{.metadata.name}{"\n"}{.spec.forProvider.imageId}{"\n"}{.spec.forProvider.instanceType}{"\n"}{.spec.forProvider.region}{"\n"}{.status.atProvider.state}{"\n"}{.status.atProvider.publicDnsName}{"\n"}{end}'

ls -la artifacts

echo 'instance information is saved in a text file.'
