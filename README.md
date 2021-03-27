# Simple Application Infrastructure

Terraform is an perfect way to create and manage the infrastructure of your products. It have a declarative way to create an template, so you just have to declare how you want your application to be, and terraform will find out the steps that needs to be done to the infrastructure be exacly how you want to.

This template will create a simple infrastructure to an application.

## How the infrastructure will be:

First of all, it will create a virtual private cloud (VPC) to host our application. The VPC allow you to provision an isolated, fully manageble cloud enviroment.

This VPC will be conected to a Internet Gateway, that allow the VPC to recieve requests for all the internet.

The created VPC is divided in two subnets:

- The public subnet, that can be access by the whole internet. It could be used to host frontend's aplications. 
- The private subnet, that only recieve requests of the applications hosted on our public subnet. It could host our backend and database aplications using a cluster kubernetes, increasing the security of our application.

Each subnet have the routing table configured and a instance deployed with security groups already defined.

## How to use

### To run terraform and create this infrastructure on your AWS is just run the commands below:

This command will check the terraform template and show you everything that terraform will create when you apply the template.
```
terraform plan -var="aws_access_key=YourAccessKey" -var="aws_secret_access_key=YourSecretAccessKey"
```

This command will create the infrastructure on your AWS.
```
terraform apply -var="aws_access_key=YourAccessKey" -var="aws_secret_access_key=YourSecretAccessKey"
```

If you want just to test the template and see in the console everything that this template creates, you can destroy everythin simply running this command.
```
terraform destroy
```