<h1 align="center">Iac-aws-terraform</h1>

<h2 align="left">Prerequisites</h2>

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

* [Docker runtime](https://docs.docker.com/engine/install/)

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-instal-instructions)

* [JQ in linux](https://stedolan.github.io/jq/download/)

<h2 align="left">To deploy</h2>

* It is necessary to install all the dependencies mentioned above;

* After all the dependencies installed, configure the aws cli the credentials of the account in which you want to create the resources;

* After that, create an s3 bucket or use an existing one to save the state of the infrastructure that terraform will use to manage the state of the resources, this configuration is in the provider.tf file, this bucket must be in the account that the resources will be implanted;

* Analyze the **terraform.tfvars** file, this file is where we define some global scope variables, look at the variables and configure according to your use;

    <h3 align="left">some variables</h1>
        
     * region: AWS Region to create the resources
     * docker_image_local: Name of the local image that will be deployed
     * docker_image_tag: Tag of the local image that will be deployed
     * dns_hosted_zone: The DNS zone that will be used, the account must have a hosted zone already created
        

* After all this previously configured, run the **deploy.sh** script that will create the infrastructure, if there is an error, the resources that were created up to the time of the error will be deleted from the account.


<h2 align="left">Some resources</h2>

Some resources created are:

* A VPC network with two public and two private subnets to keep anything private safe from public access

* One queue in AWS SQS

* One application-type load balancer for each service

* An ECS Cluster for each service, a repository is created in AWS ECR for the docker images, after the creation of AWS ECR the local image is pushed to the ECR

* A Repository in AWS CodeCommit, where the necessary files are also automatically uploaded for AWS Code Deploy to work well with the Blue/Green type
