#!/bin/bash

# Check if both variables are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Both AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be provided."
    exit 1
fi

# Create the file aws-creds.conf with the provided credentials
cat <<EOF > ~/aws-creds.conf
aws_access_key_id=$1
aws_secret_access_key=$2
EOF

echo "AWS credentials saved to aws-creds.conf"
