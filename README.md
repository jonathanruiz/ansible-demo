# Ansible Demo Environment

This repo contains the files necessary to deploy a ready-to-use sanbox environment to start learning to use Ansible. The deployent is made simple by deploying the environment on Azure using the Terraform.

## Prerequsities

### Local Machine

If you wish to set the environent from your local machine, you will need to make sure the following tools are installed:

- Azure CLI or Azure PowerShell
- Git
- Terraform

Using the Azure CLI or PowerShell, set the subscription you wish to use for your deployment.

### Azure Cloud Shell

Alternatively, you could use the Azure Cloud Shell. The Azure Cloud Share already has Azure CLI/PowerShell, Git and Terraform installed in the shell. If this is your preferred method, you can use this guide: [Azure Cloud Shell Quickstart - Bash (Start Cloud Shell)](https://learn.microsoft.com/en-us/azure/cloud-shell/quickstart#start-cloud-shell)

Once the cloud shell is created, you can proceed with the next steps.

## Getting Started

1. First, clone the files from the repository.

```
git clone https://github.com/jonathanruiz/ansible-demo.git
```

2. In the `terraform` folder, there is a file named `variables.tf`. Open the file.

3. Change the values of the `username` and `password` variables. Find the values that says `CHANGE-ME` and change them to strong username and passwords.

4. Run initialize Terraform.

```
terraform init
```

5. Deploy the resources.

```
terraform apply
```

6. Once deployed, there will be an output for the SSH command necessary to be able to SSH into the `jumpbox` virtual machine. The output should look something like:

```
ssh username@<Public-IP-Address>
```

7. Once connected, change the directory to the `ansible` folder.

```
cd ansible
```

8. You are now ready to start running Ansible Playbooks. In the `ansible` directory, you should see some playbooks to get you started.
