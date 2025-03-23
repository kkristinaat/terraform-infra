#!/bin/bash

set -e

# Define Terraform executable
TERRAFORM=terraform

# Define infrastructure directories
BACKEND_DIR="./backend"
MODULE_DIR="./modules/s3_bucket"
S3_BUCKETS_DIR="./s3_buckets"
ENV_DIR="./s3_buckets/environments"
ENVIRONMENTS=("stg" "prd")

# Define TFLint output file
TFLINT_OUTPUT="tflint_output.txt"

# Function to check installation of required tools
check_tools() {
    local tools=("terraform" "tflint")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "Error: $tool is not installed. Please install $tool."
            exit 1
        fi
    done
}

# Function to validate Terraform configuration
validate_terraform() {
    echo "Running Terraform formatting..."
    $TERRAFORM fmt -recursive
    echo "Terraform formatting completed."

    # Validate Backend Configuration
    echo "Validating Terraform backend..."
    cd "$BACKEND_DIR" || { echo "Error: Backend directory does not exist."; exit 1; }
    $TERRAFORM init -backend=false > /dev/null 2>&1
    $TERRAFORM validate
    cd - > /dev/null
    echo "Terraform remote backend validation passed."

    # Validate Terraform module
    echo "Validating Terraform module..."
    cd "$MODULE_DIR" || { echo "Error: Module directory does not exist."; exit 1; }
    $TERRAFORM init -backend=false > /dev/null 2>&1
    $TERRAFORM validate
    cd - > /dev/null
    echo "Terraform module validation passed."

    # Validate S3 Buckets Configuration
    echo "Validating S3 Buckets configuration..."
    cd "$S3_BUCKETS_DIR" || { echo "Error: S3 Buckets directory does not exist."; exit 1; }
    $TERRAFORM init -backend=false > /dev/null 2>&1
    $TERRAFORM validate
    cd - > /dev/null
    echo "Validation passed for s3_buckets."

    # Validate Terraform environments
    for env in "${ENVIRONMENTS[@]}"; do
        echo "Validating Terraform environment: $env ..."
        cd "$ENV_DIR" || { echo "Error: Environments directory does not exist."; exit 1; }
        $TERRAFORM init -backend=false > /dev/null 2>&1
        $TERRAFORM validate
        cd - > /dev/null
        echo "Validation passed for $env environment."
    done
}

# Function to run static analysis with TFLint and save output
run_tflint() {
    echo "Running TFLint static code analysis..."

    # Initialize TFLint
    tflint --init > /dev/null 2>&1

    # Empty the output file before running new checks
    > "$TFLINT_OUTPUT"

    # List of directories to check with TFLint
    TFLINT_DIRS=("$BACKEND_DIR" "$MODULE_DIR" "$S3_BUCKETS_DIR" "$ENV_DIR")

    # Run TFLint with --chdir to specify each working directory
    for dir in "${TFLINT_DIRS[@]}"; do
        echo "Running TFLint on $dir..." | tee -a "$TFLINT_OUTPUT"
        tflint --chdir="$dir" -f compact >> "$TFLINT_OUTPUT" 2>&1 || { echo "TFLint failed for $dir. Check $TFLINT_OUTPUT for details."; }
    done

    echo "TFLint analysis complete. Results saved in $TFLINT_OUTPUT."
}

# Run checks
check_tools
validate_terraform
run_tflint

echo "All Terraform validation checks completed successfully!"