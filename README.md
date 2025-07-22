# Welcome to AWS EKS(standard) IAC Infra project!

This is a project to provision AWS EKS standard into AWS cloud using Terraform.
This project consists of three repositories below.
```
(App) - https://github.com/Ufocultist/wtv-app - Application repository(Flask/Nginx/MardiaDb microservices)
Current repository (Infra) - https://github.com/Ufocultist/tf-infra-wtv - Terraform IAC repository(K8s standard mode)
(CICD) - https://github.com/Ufocultist/wtv-cicd - CI/CD repository(Python-CI, EKS-CD)
```
Project using Terraform as IAC tool.

1. Clone https://github.com/Ufocultist/tf-infra-wtv repository on your pc.
2. Go to AWS console -> IAM and generate Access keys. Save them to Notepad.
3. Open Github Actions -> Settings -> Secrets and Variables -> Actions.
4. Create two repository keys `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, copy the values from step 2.
5. Create feature/develop branch from the main branch. Checkout to feature/develop branch. 
6. Open ./dev/terraform.tfvars file and put your values there and save. See values below.

```
env                  = "dev" # Environment name.
cidr_block           = "10.200.0.0/16" # AWS VPC address space. Specify yours.
azs                  = ["us-east-1a", "us-east-1b"] # Specify two availability zones.
public_subnet_cidrs  = ["10.200.1.0/24", "10.200.2.0/24"] # Public subnets. Specify yours.
private_subnet_cidrs = ["10.200.3.0/24", "10.200.4.0/24"] # Private subnets. Specify yours.
capacity_type        = "SPOT" # Choose between SPOT(cost effective) and ON_DEMAND(resilient).
instance_types       = ["t3.small"] # Choose your instance type.
ami_type             = "AL2_x86_64" # AMI image for worker nodes.
k8s_version          = "1.29" # Kubernetes version.
aws_account_id       = "111111111111" # Your AWS account ID.
region               = "us-east-1" # AWS region.
repo_name            = "Ufocultist/wtv-app" # Paste your cloned repo address.
app_name             = "wtv_ns/wtvapp" # Specify namespace/reponame to store Docker image in ECR.
```

7. Open PR from feature/develop branch to the main branch and merge the PR.
8. Go to Actions Tab and click on IAC(1) on the left-hand side.
9. Click on `Run Workflow` button, choose feature/develop branch from the dropdown.
10. Type Database password and Root Password, only Root Password is mandatory(See notice below). You can leave other values as is or override them. Click `Run Workflow` button.
```!!! Pipeline won't run `Terraform Apply` unless `Database password` field is blank.!!!```
11. Click on `Create Terraform backend?` and choose true if it is your first EKS provisioning. The pipeline will create S3 bucket for your terraform state.
12. IAC pipeline is going to be triggered. Open Actions Tab and monitor the `Terraform Apply` log.
13. Wait Terraform apply to complete. Done!
14. Go back to https://github.com/Ufocultist/wtv-app repository for further instructions.

## Complete
You have provision EKS cluster in your AWS cloud. Enjoy!
Run `aws eks update-kubeconfig --region us-east-1 --name dev-wtv-cluster` in the console to authenticate to the cluster.
Execute some commands from the `Useful commands` list below.

**Warning**! EKS is an expensive AWS resource. It costs **$0.10** per cluster per hour.
Remember to run `terraform destroy` when EKS cluster is no longer needed.

### Useful commands:
kubectl get pods -A # Show all pods
kubectl get nodes -o wide # Show all worker nodes.

## TODO
1. Implement ECS Fargate Conditional deployment.
2. Implement Multicloud Deployment (GKE/AKS).