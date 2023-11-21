
# Namada Full Node Provision with Terraform

> This repository assists the community in provisioning Namada full nodes using Terraform.

## Features

- Automates VPC provisioning.
- Automates the provisioning of public subnets.
- Automates NAT gateway provisioning.
- Automates security group (firewall) provisioning.
- Automates application load balancer provisioning.
- Automates AWS EC2 instance provisioning.
- Automates the deployment of **Namada** full nodes.
- Supports autoscaling (scaling up/down) of instances.

## Guidelines

1. Install AWS CLI on your machine and generate credentials from your AWS account.
2. Install Terraform on your machine.
3. Update configurations in the `variables.tf` file.
4. Validate your Terraform code using `terraform validate`. You should receive a `Success! The configuration is valid.` message.
5. Provision the **Namada full node** using `terraform apply`.
6. Verify the results in your AWS console.

## TODO
- Implement automatic deployment with snapshot files.
- Set up Monitoring (Grafana/Zabbix) and Alert systems.

## Who We Are
ContributionDAO - We are a top-tier validator node service provider, offering blockchain infrastructure solutions and a community platform called ProofSquare ([proofsquare.xyz](https://proofsquare.xyz/)). Over the past few years, we have assisted more than 45 projects, establishing long-term partnerships.

## Follow Us
- Website: [contributiondao.com](https://contributiondao.com)
- Twitter: [twitter.com/contributedao](https://twitter.com/contributedao)
- YouTube: [youtube.com/@contributiondao](https://www.youtube.com/@contributiondao)
- Facebook: [facebook.com/contributiondao](https://www.facebook.com/contributiondao)
- Mirror: [mirror.xyz/contributiondaoblog.eth](https://mirror.xyz/contributiondaoblog.eth)

## Author
- POR | ContributionDAO
- pongchai#2968 | [twitter/llPorZall](https://twitter.com/llPorZall)
- NodeOps from the ContributionDAO team
