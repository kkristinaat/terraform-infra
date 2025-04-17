# Solution

## **Used Tools**

- **Terraform**: Version 4.0 or higher for managing AWS resources.
- **AWS Account**: With a free tier.
- **AWS CLI**: For interacting with AWS and configuring access keys and secrets.
- **TFLint**: To validate the Terraform code.
- **Bash Scripts**: To validate, test, and apply Terraform code.

---

## **State Management**

- **S3 Bucket**: Stores Terraform state files for persistent and centralized management.
- **DynamoDB**: Used for state locking to prevent concurrent Terraform runs.

---

## **What Was Done**

1. **IAM Role (sp-cli-access)**: 
   - Created in the AWS Free Tier account with necessary permissions to manage resources.
   
2. **AWS CLI Setup**: 
   - Created S3 bucket and DynamoDB table for backend configuration.

3. **Terraform Module**:
   - The module is designed to work for two environments: stg and prd.
   
   - Environment configurations are defined in `tfvars` files:
     - `../environments/stg.tfvars
     - `../environments/prd.tfvars
   
   *This approach guarantees implementation of GitOps.*

4. **Module Includes**:
   - **S3 Bucket Resources**: For managing data.
   - **IAM Policy & Role**: For access control to S3 resources.
   - **Lifecycle Rules**:
     - **stg**: Objects in the `data/` folder are deleted after 30 days.
     - **prd**: Objects in the `data/` folder are moved to the Standard-IA storage class after 30 days.

---

## **Validation**

To validate the Terraform code, run the `./validate.sh` script.

The script checks the following:

- Proper formatting of Terraform files.
- Valid Terraform syntax.
- Terraform code follows best practices (via TFLint).

---

## **Testing**

To test and apply the solution, use the `./actions.sh` script. Run the following commands:

```bash
cd terraform_s3_module/s3_buckets
./actions.sh init $environment
./actions.sh plan $environment
./actions.sh apply $environment
./actions.sh destroy $environment
```

Current bash script automates the initialization, planning, applying, and destruction of Terraform infrastructure for stg and prd environments.

Before running terraform plan, apply, or destroy, it initializes Terraform to ensure the correct backend configuration is used for each environment.
