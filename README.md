# Terraform AWS Environment

A **production‑style AWS environment** built from first principles to demonstrate
**cloud infrastructure design, networking, security, and immutable provisioning**
using Terraform.

This project focuses on **intentional AWS design** rather than managed abstractions,
and avoids AWS defaults to make all networking and security decisions explicit.

---

## Architecture

The infrastructure provisions the following resources in **AWS eu-west-2**:

- Custom VPC (`10.0.0.0/16`)
- Public subnet (`10.0.1.0/24`) in a single Availability Zone
- Internet Gateway
- Security Group with ingress and egress rules attached to the EC2 instance
  - SSH ingress from only one CIDR IP defined as a Terraform variable
  - HTTP ingress from any source
  - All outbound traffic
- Route table associated with the Subnet with `0.0.0.0/0` outbound access
- EC2 instance running **Ubuntu 24.04 LTS**
- SSH access via AWS key pair
- HTTP access via port 80

**High‑level flow:**

```
Internet
   │
Internet Gateway sitting on VPC
   │
Public Subnet (10.0.1.0/24)
   │
EC2 Instance (Ubuntu + nginx)
```

A visual representation is available in Architecture.png. I drew this using [Excalidraw](https://excalidraw.com/).

## Automated Provisioning (Key Feature)

The EC2 instance is **fully bootstrapped on first launch** using Terraform
`user_data` and cloud-init:

- nginx is installed automatically
- default nginx content is removed
- a custom HTML page is written at boot
- nginx is started and enabled without manual intervention

This demonstrates **immutable infrastructure principles**:
changes to server configuration are applied by **replacing the instance**, not by
manually modifying live systems.

> Changes to user_data are applied by replacing the EC2 instance, meaning you get a clean and reproducible setup each time.
> Just run `terraform apply -replace="aws_instance.app_server"`, note the flag, and you should be good to go.

---

## Security Model

- No AWS default VPC or default security groups are used
- All ingress and egress rules are explicitly defined using:
  - `aws_vpc_security_group_ingress_rule`
  - `aws_vpc_security_group_egress_rule`
- SSH access is restricted to key‑based authentication
- HTTP access is explicitly enabled on port 80
- Terraform state is intentionally excluded from version control

---

## Technologies Used

- **AWS**: EC2, VPC, Subnets, Internet Gateway, Route Tables, Security Groups
- **Terraform**: Infrastructure as Code (HCL)
- **Linux**: Ubuntu 24.04 LTS
- **nginx**: Automated web server provisioning
- **SSH**: Secure key‑based access

---

## How to Run

### Prerequisites

- AWS credentials configured locally
- Terraform installed

### Provision Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

After apply completes, Terraform outputs the **public IP address** of the EC2 instance.

### Verify Deployment

- Open the public IP in a browser to view the automatically provisioned nginx page
- Optional SSH access for inspection/debugging:

```bash
ssh -i ~/.ssh/learn-terraform ubuntu@<PUBLIC_IP>
```

---

## What This Project Demonstrates

- Designing AWS networking without defaults
- Explicit routing and CIDR planning
- Secure access patterns using security groups
- Infrastructure‑as‑code workflows with Terraform
- Cloud‑init and `user_data` lifecycle behavior
- Immutable infrastructure and instance replacement
- Debugging real cloud provisioning issues

---

## Future Improvements

- Add HTTPS via an Application Load Balancer
- Introduce remote Terraform state (S3 + DynamoDB)
- Expand to multi‑AZ architecture

---

## References

- Terraform documentation: https://developer.hashicorp.com/terraform
- AWS EC2 and VPC documentation
- Official nginx documentation

- https://developer.hashicorp.com/terraform/language/values/variables for environment variables
- https://dev.to/drewmullen/terraform-variable-validation-with-samples-1ank for variable validation
