# Welcome to your IAC Infra project!

This is a project for WTV development with Python.

This project consists of three repositories below.

```
(App) - https://github.com/Ufocultist/wtv-app - Application repository(Flask/Nginx/MardiaDb microservices)
(Infra) - https://github.com/Ufocultist/tf-infra-wtv - Terraform IAC repository(K8s standard mode)
(CICD) - https://github.com/Ufocultist/wtv-cicd - CI/CD repository(Python-CI, EKS-CD)
```
Project using Terraform as IAC tool.

1. Clone Infra repository on your pc.
2. Go to AWS console -> IAM and generate Access keys. Save them to Notepad.
3. Open Github Actions -> Settings -> Secrets and Variables -> Actions.
4. Create two repository keys `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and copy the values from step 2.
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

7. Go to Actions Tab and click on IAC(1) at the left hand.
8. Click on `Run Workflow` button, choose feature/develop branch from the dropdown.
9. Type Database password and Root Password, only Root Password is mandatory(See notice below). You can leave other values as is or override them. Click `Run Workflow` button.
```!!! Pipeline won't do `Terraform Apply` in case if `Database password` field is blank.!!!```
10. Click on `Create Terraform backend?` and choose true if it is your first EKS provisioning. The pipeline will create S3 bucket for your terraform state.
11. IAC pipeline is going to be triggered. Open Actions Tab and monitor the `Terraform Apply` log.
12. Wait Terraform apply to complete.
13. Go back to "App" repository.


## Complete

Warning! EKS is an expensive AWS resource. It cost $0.10 per cluster per hour.
Don't forget to run `terraform destroy`.

Now you have running EKS cluster in your AWS cloud.
Run `aws eks update-kubeconfig --region us-east-1 --name dev-wtv-cluster` in the console to authenticate to the cluster

### Useful commands:
kubectl get pods -A # Show all pods
kubectl get nodes -o wide # Show all worker nodes.

Now you can go back to the App repository (https://github.com/Ufocultist/wtv-app) and complete the steps there
Enjoy!

## TODO
1. Implement ECS Fargate Conditional deployment.
2. Implement Multicloud Deployment (GKE/AKS).