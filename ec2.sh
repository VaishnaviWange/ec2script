#!/bin/bash 

# Variables
AMI_ID="ami-0e2c8caa4b6378d8c" # Replace with the AMI ID of your choice
INSTANCE_TYPE="t2.micro"       # Instance type (e.g., t2.micro for free tier)
KEY_NAME="influxdb"         # Replace with your key pair name
SECURITY_GROUP_ID="sg-0499710745ba35afb" # Replace with your security group ID
SUBNET_ID="subnet-08ad4d68839d69c62"     # Replace with your subnet ID
TAG_NAME="MyEC2Instance"       # Tag name for the instance

# Launch EC2 Instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

# Check if the instance was successfully launched
if [ -z "$INSTANCE_ID" ]; then
    echo "Failed to launch EC2 instance."
    exit 1
fi

echo "Instance launched successfully! Instance ID: $INSTANCE_ID"

# Wait for the instance to be in a running state
echo "Waiting for the instance to reach the 'running' state..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is now running!"

# Retrieve and display the public IP address
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

if [ -n "$PUBLIC_IP" ]; then
    echo "Instance Public IP: $PUBLIC_IP"
else
    echo "Unable to retrieve the public IP address."
fi

echo "EC2 instance launch automation complete."