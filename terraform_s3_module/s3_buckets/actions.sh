#!/bin/bash

set -e 

# Define Terraform executable
TERRAFORM=terraform

# Define directory for environments
ENV_DIR="environments"

# Define backend S3 bucket name
BACKEND_BUCKET="kkris-state-bucket"

# Function to initialize Terraform for an environment
init() {
    local env=$1
    echo "Initializing Terraform for environment: $env..."
    
    $TERRAFORM init -reconfigure \
        --backend-config="bucket=$BACKEND_BUCKET" \
        --backend-config="key=$ENV_DIR/$env/terraform.tfstate"
    
    echo "Initialization complete for $env."
}

# Function to plan Terraform changes
plan() {
    local env=$1
    init "$env"
    echo "Running Terraform plan for $env..."
    
    $TERRAFORM plan -var-file="$ENV_DIR/$env.tfvars" -var="environment=$env"
    
    echo "Plan completed for $env."
}

# Function to apply Terraform changes
apply() {
    local env=$1
    init "$env"
    echo "Applying Terraform for $env..."
    
    $TERRAFORM apply -var-file="$ENV_DIR/$env.tfvars" -var="environment=$env" -auto-approve
    
    echo "Infrastructure applied for $env."
}

# Function to destroy Terraform infrastructure
destroy() {
    local env=$1
    init "$env"
    echo "Destroying infrastructure for $env..."
    
    $TERRAFORM destroy -var-file="$ENV_DIR/$env.tfvars" -var="environment=$env" -auto-approve
    
    echo "Infrastructure destroyed for $env."
}

# Check if correct number of arguments are provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 {init|plan|apply|destroy} {stg|prd}"
    exit 1
fi

# Parse command-line arguments
ACTION=$1
ENV=$2

# Validate environment input
if [[ "$ENV" != "stg" && "$ENV" != "prd" ]]; then
    echo "Invalid environment: $ENV. Allowed values are 'stg' or 'prd'."
    exit 1
fi

# Execute the corresponding function
case "$ACTION" in
    init) init "$ENV" ;;
    plan) plan "$ENV" ;;
    apply) apply "$ENV" ;;
    destroy) destroy "$ENV" ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Usage: $0 {init|plan|apply|destroy} {stg|prd}"
        exit 1
        ;;
esac