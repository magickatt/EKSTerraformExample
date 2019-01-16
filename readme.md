# EKS Terraform example

## Prerequisites

* [ Create an AWS account](https://aws.amazon.com/resources/create-account/)
* [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

## Build the EKS cluster

### AWS access credentials

Firstly you'll need to supply your [AWS access credentials](https://console.aws.amazon.com/iam/home?#/security_credential) for Terraform to use

    export AWS_SECRET_ACCESS_KEY=""
    export AWS_ACCESS_KEY_ID=""

### AWS IAM Authenticator

In order to authenticate against the EKS cluster you'll need to install the AWS IAM Authenticator.

Please note this step should be modified based on your workstation use-case (this is not ideal but should work in most cases) based on your binary $PATH layout and the latest stable version of the authenticator.

    curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/darwin/amd64/aws-iam-authenticator
    chmod +x ./aws-iam-authenticator
    mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

### Terraform

Then you'll need to use Terraform to create a test environment

    cd terraform/environments/test
    terraform init
    terraform plan
    terraform apply

To get the kubectl configuration you'll need to output information from the module used in this example environment

    terraform output -module=eks-terraform-example kubeconfig > ~/.kube/config
    
To allow the worker nodes to be able to join the cluster you will need to apply a ConfigMap that facilitates AWS IAM Role authentication

    terraform output -module=eks-terraform-example config_map_aws_auth | kubectl apply -f -

To check that everything is working as expected, check the cluster information

    kubectl cluster-info

If everything is setup correctly you should see output similar to the following...

    Kubernetes master is running at https://abc.edf.us-east-1.eks.amazonaws.com
    CoreDNS is running at https://abc.edf.us-east-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    

    

    
# Deploy application to EKS

To ensure that the cluster is functional you will need to deploy the application plus a corresponding service and ingress routing to it

    kubectl apply -f kubernetes/deployment.yml
    kubectl apply -f kubernetes/service.yml
    kubectl apply -f kubernetes/ingress.yml
