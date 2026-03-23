# Terraform EC2 Deployment Using Modules, Environments and Remote State

## Project Overview

This project demonstrates how to deploy EC2 instances on AWS using **Terraform modules**, **environment-based configuration**, **dynamic AMI selection using data blocks**, and **remote state management using an S3 backend**.

The goal of this project is to implement **Infrastructure as Code (IaC)** by creating reusable modules and separating configurations for different environments such as **dev**, **stage**, and **prod**.

Additionally, Terraform state is stored remotely in **Amazon S3**, ensuring safe and collaborative infrastructure management.

---

# Project Structure

```
Day-2
│
├── providers.tf
├── variables.tf
├── ec2-servers.tf
│
├── environments
│   ├── dev
│   │   └── terraform.tfvars
│   ├── stage
│   └── prod
│
└── localmodules
    └── ec2
        ├── data.tf
        ├── servers.tf
        └── variables.tf
```

---

# 1. Provider and Terraform Configuration

**File:** `providers.tf`

This file configures the AWS provider, Terraform version, and remote backend.

```hcl
provider "aws" {
  region = "us-east-1"

  # Optional: Assume Role Configuration
  # assume_role {
  #   role_arn     = "arn:aws:iam::808512682402:role/TF-role"
  #   session_name = "TF-access"
  # }
}

terraform {
  required_version = "1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.35.1"
    }
  }
}

terraform {
  backend "s3" {
    bucket       = "the-stringer-things-terraform-state"
    key          = "envs/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Explanation

| Setting            | Purpose                                                     |
| ------------------ | ----------------------------------------------------------- |
| provider "aws"     | Connects Terraform to AWS                                   |
| required_version   | Ensures correct Terraform version                           |
| required_providers | Defines AWS provider plugin                                 |
| backend "s3"       | Stores Terraform state remotely                             |
| bucket             | S3 bucket where Terraform state is stored                   |
| key                | Path of the state file in S3                                |
| encrypt            | Encrypts the state file                                     |
| use_lockfile       | Prevents multiple users from modifying state simultaneously |

---

# 2. Root Variables

**File:** `variables.tf`

These variables make the Terraform configuration flexible.

```hcl
variable "instance_type" {
  type = string
}

variable "no_of_ec2" {
  type = number
}
```

---

# 3. Calling the EC2 Module

**File:** `ec2-servers.tf`

This file calls the local EC2 module and passes variables.

```hcl
module "servers" {

  source = "./localmodules/ec2"

  instance_type = var.instance_type
  no_of_ec2     = var.no_of_ec2

}
```

---

# 4. Environment Configuration

**File:** `environments/dev/terraform.tfvars`

This file defines configuration for the **development environment**.

```hcl
instance_type = "t2.micro"
no_of_ec2     = 2
```

Example **production configuration**

```
instance_type = "t3.medium"
no_of_ec2 = 5
```

---

# 5. Module Variables

**File:** `localmodules/ec2/variables.tf`

```hcl
variable "instance_type" {
  type = string
}

variable "no_of_ec2" {
  type = number
}
```

---

# 6. Fetch Latest AMI Using Data Block

**File:** `localmodules/ec2/data.tf`

```hcl
data "aws_ami" "amazon_linux" {

  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}
```

### Purpose

• Automatically fetch the **latest Amazon Linux AMI**
• Avoid hardcoding AMI IDs
• Keep infrastructure updated

---

# 7. EC2 Instance Resource

**File:** `localmodules/ec2/servers.tf`

```hcl
resource "aws_instance" "servers" {

  count = var.no_of_ec2

  ami = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  tags = {
    Name = "Terraform-Server-${count.index}"
  }

}
```

### Explanation

• `count` creates multiple EC2 instances
• AMI fetched dynamically from data block
• Instance type passed through variables

---

# 8. Terraform State Management

Terraform stores infrastructure information in a **state file**.

This state file tracks:

* created resources
* infrastructure changes
* dependency relationships

Instead of storing the state locally, this project stores it in **Amazon S3**.

### Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket       = "the-stringer-things-terraform-state"
    key          = "envs/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Benefits of Remote State

• Centralized state storage
• Safe collaboration for teams
• Prevents accidental state loss
• State file encryption
• State locking to avoid concurrent updates

---

# 9. Terraform Workflow

### Step 1 – Initialize Terraform

```bash
terraform init
```

This step:

* downloads providers
* configures S3 backend
* prepares Terraform workspace

---

### Step 2 – Preview Infrastructure Changes

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
```

Shows the execution plan before applying infrastructure.

---

### Step 3 – Apply Infrastructure

```bash
terraform apply -var-file=environments/dev/terraform.tfvars
```

Creates EC2 instances in AWS.

---

# Infrastructure Flow

```
terraform.tfvars
        ↓
variables.tf
        ↓
module call
        ↓
localmodules/ec2
        ↓
data.tf (fetch AMI)
        ↓
servers.tf (create EC2)
        ↓
AWS EC2 Instances Created
        ↓
Terraform State Stored in S3
```

---

# Key Terraform Concepts Used

* Infrastructure as Code (IaC)
* Terraform Modules
* Environment based configuration
* Data blocks
* Variables and tfvars
* Dynamic resource creation (`count`)
* Remote state using S3
* State locking

---

# Outcome

Using this Terraform configuration:

* Infrastructure becomes reusable
* Multiple environments can be managed easily
* Latest AMI is selected automatically
* Multiple EC2 instances can be created with a single command
* Terraform state is securely stored in S3
