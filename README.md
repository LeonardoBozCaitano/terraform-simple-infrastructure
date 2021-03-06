# Simple Application Infrastructure

Terraform is a perfect language to create and manage products infrastructure. It has a declarative way to create templates, so you just have to describe how you want your application to be, and terraform will find out the steps that needs to be done to the infrastructure be exacly how you want to.

This template will create a simple infrastructure to an application.

## How the infrastructure will be:

First of all, it will create a virtual private cloud (VPC) to provision an isolated, fully manageable cloud environment.

This VPC will be connected to an Internet Gateway, that allow the VPC to receive requests from the internet.

The created VPC is divided in two subnets:

- The public subnet can be access by the whole internet. It could be used to host frontend's applications. 
- The private subnet only receive requests of the applications hosted on our public subnet, increasing the security of our application. It could host our backend and database aplications using a cluster kubernetes.

Each subnet has the routing table configured, and an instance deployed with security groups already defined.

The private subnet have an NAT gateway attached to make possible the instance reach the internet when needs to download or update the softwares

## How to use

### To run terraform and create this infrastructure on your AWS is just run the commands below:

First of all you need to init terraform using the command below, this will download the requirements to communicate with the providers, in this case, AWS.
```
terraform init
```

This command will check the terraform template and show you everything that will be created when you apply the template.
```
terraform plan -var="aws_access_key=YourAccessKey" -var="aws_secret_access_key=YourSecretAccessKey"
```

This command will create the infrastructure on your AWS.
```
terraform apply -var="aws_access_key=YourAccessKey" -var="aws_secret_access_key=YourSecretAccessKey"
```

If you want just to test the template and see in the AWS Console everything that this template creates, after this you can destroy everything simply running this command.
```
terraform destroy
```

## To do's
- Set AutoScaling to the instances.
- To the application have more availability, create the application in more availability zones.
