# EKS Terraform example

## Build the EKS cluster

### AWS access credentials

Firstly you'll need to supply your AWS access credentials for Terraform to use

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

    terraform output -module=eks-terraform-example > ~/.kube/config

To check that everything is working as expected, check the cluster information

    kubectl cluster-info

If everything is setup correctly you should see output similar to the following...

    Kubernetes master is running at https://abc.edf.us-east-1.eks.amazonaws.com
    CoreDNS is running at https://abc.edf.us-east-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

