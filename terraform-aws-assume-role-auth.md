# Terraform Authentication using IAM AssumeRole on AWS

---

## 🎯 Goal

Authenticate Terraform using the following secure flow:

    IAM User (access key)
            ↓
        AssumeRole
            ↓
        IAM Role
            ↓
        Terraform

> ❗ You **cannot authenticate using only a role ARN**.  
> You **must start with an IAM user or AWS SSO session**.

---

##  Architecture Overview

    tf-user (access key in ~/.aws/credentials)
            ↓
        AssumeRole permission
            ↓
        tf-role (trusts tf-user)
            ↓
        Terraform

This is the correct and secure pattern for Terraform role-based authentication.

---

#  Step 1 — Create IAM User (Programmatic Access)

Navigate to:

    IAM → Users → Create user

**Name:**

    TF-user

After creation:

    👉 Go to Security credentials  
    👉 Create Access Key  
    👉 Copy:

    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY

⚠️ **Save them securely. You won’t see the secret again.**

---

#  Step 2 — Create IAM Role

Navigate to:

    IAM → Roles → Create role

Select:

    AWS account

Attach policy:

    AdministratorAccess

(or any scoped policy you actually need)

**Name:**

    TF-role

---

#  Step 3 — Configure Trust Policy (VERY IMPORTANT)

Navigate to:

    IAM → Roles → TF-role → Trust relationships → Edit trust policy

Replace with:

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::875778602097:user/TF-user"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }

✔ Save

This allows **TF-user** to assume **TF-role**.

---

#  Step 4 — Give User Permission to Assume Role

Navigate to:

    IAM → Users → TF-user → Add permissions → Create inline policy

Paste:

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Resource": "arn:aws:iam::875778602097:role/TF-role"
        }
      ]
    }

✔ Save

Now:

- ✅ The role **trusts** the user  
- ✅ The user has permission to **assume the role**

Both sides must match.

---

#  Step 5 — Configure AWS Credentials Locally

Run:

    aws configure

Enter:

    Access Key ID:     (paste key)
    Secret Access Key: (paste secret)
    Region:            us-east-1
    Output:            json

Test authentication:

    aws sts get-caller-identity

You should see:

    arn:aws:iam::875778602097:user/TF-user

If this works → your base authentication is correct.

---

#  Step 6 — Configure Terraform Provider

Create `provider.tf`:

    provider "aws" {
      region = "us-east-1"

      assume_role {
        role_arn     = "arn:aws:iam::875778602097:role/TF-role"
        session_name = "TF-session"
      }
    }

---

#  Step 7 — Run Terraform

    terraform init
    terraform plan
    terraform apply

Terraform will:

1. Authenticate using user access key  
2. Call STS AssumeRole  
3. Switch to TF-role  
4. Execute with role permissions  

---

# 🔎 Verify Terraform Is Using the Role

Add this data block:

    data "aws_caller_identity" "current" {}

Run:

    terraform apply

You should see:

    arn:aws:sts::875778602097:assumed-role/TF-role/...

That confirms Terraform is executing as the role.

---

# 🚨 Common Mistakes

❌ Using role ARN without credentials  
❌ Wrong trust policy  
❌ Using AIDA instead of full ARN  
❌ Not granting `sts:AssumeRole` to user  
❌ Not running `aws configure`  

---

# 🧠 Important Rule — Terraform Credential Order

Terraform checks credentials in this order:

1. Environment variables  
2. `~/.aws/credentials`  
3. EC2 instance metadata  

If none exist, you’ll get:

    No valid credential sources found

---

# ❓ Common Confusion: “Why Use IAM Role If We Still Need Access Keys?”

Many students ask:

“If we still run aws configure and provide access keys…  
then what is the point of using an IAM Role?”

This is an excellent and very important question.

---

# 🔐 Authentication vs Authorization (The Key Concept)

There are two different things happening:

1️⃣ Authentication → Who are you?  
2️⃣ Authorization → What are you allowed to do?  

In this setup:

| Component | Purpose |
|------------|----------|
| IAM User (access key) | Authentication |
| IAM Role | Authorization |

The IAM user proves identity.  
The IAM role defines permissions.

---

## 🔄 What Actually Happens

When Terraform runs:

1. Terraform first uses the IAM user's access key to log in to AWS.
2. Then it calls `sts:AssumeRole`.
3. AWS checks two things:
   - The IAM role **trusts the user**
   - The user **has permission to assume the role**
4. AWS provides **temporary credentials** for the role.
5. Terraform performs all actions using the **role’s permissions**, not the user's permissions.

After the role is assumed, the IAM user's permissions are no longer used.

---

## 🔥 Why Not Just Give Permissions to the User?

You could attach `AdministratorAccess` directly to the IAM user.

But this is **not recommended** because:

❌ Access keys stay active for a long time  
❌ It becomes difficult to rotate credentials  
❌ Hard to manage different environments  
❌ Higher security risk if keys are leaked  
❌ Harder to track actions in audits  

---

## ✅ Why IAM Roles Are Better

Using an IAM role provides several advantages:

✔ Temporary credentials that expire automatically  
✔ Clear separation of responsibilities *(User = identity, Role = permissions)*  
✔ Better environment management  

Example roles:


dev-role
staging-role
prod-role


The **same user can switch between different roles** depending on the environment.

This is the **standard pattern used in real production systems**.

In most companies:

- Very few IAM users
- Many IAM roles

---

## 🧠 Important Clarification

The IAM user is mainly used as a **starting identity**.

Its purpose is to:

- Authenticate with AWS
- Call STS
- Assume an IAM role

The **IAM role** is the one that actually performs infrastructure operations.

---

## 🚀 Real-World Analogy


Access Key = Passport
IAM Role = Work Visa


You use your **passport** to get a **visa**.  
After that, you work using the **visa**, not the passport.

---

## 🔐 Advanced Note (Production Systems)

In mature cloud environments, companies often remove IAM users completely.

Instead they use methods like:

- EC2 Instance Roles
- GitHub OIDC → AssumeRole
- AWS SSO
- IRSA (EKS)

In these setups:

✔ No long-term access keys are stored locally  
✔ Only temporary credentials are used  

---

## ✅ Final Understanding

We still configure access keys because Terraform needs an **initial identity** to connect with AWS.

But IAM roles are used because:

**Authentication and authorization should be separate.**

This separation makes the system **more secure, scalable, and suitable for production environments**.