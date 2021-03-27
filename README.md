# Simple aplication infrastructure

Terraform is an perfect way to create and manage the infrastructure of your products. It have a declarative way to create an template, so you just have to declare how you want your application to be, and terraform will find out the steps that needs to be done to the infrastructure be exacly how you want to.

This template will create a simple infrastructure to an application.

## How the template will be:

It creates a virtual private cloud (VPC) to host our application. This VPC have a internet gateway, that means that it can recieve requests for all internet.
And this VPC is divided in two subnets.

The public subnet, that can be access by the whole internet. It could be used to host frontend's aplications. 
And the private subnet, that only recieve requests of our public subnet IPs. It could host our backend and database aplications, increasing the security of our data.

Each subnet have the routing table configured and a instance deployed.

## How to use

To run terraform and create this infrastructure on your AWS is just run the commands below:

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