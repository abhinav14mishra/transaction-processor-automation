---
# 🚀 Automated Transaction Processing System
### Enterprise Event-Driven Architecture (AWS)

This repository contains the complete **Infrastructure as Code (IaC)** and orchestration logic for an automated transaction processing platform. Engineered for high-scale environments, the system leverages an **ephemeral infrastructure** strategy to ensure maximum cost-efficiency, scalability, and security.
---

## 🏛️ System Architecture

The system utilizes an **event-driven state machine** to manage the entire lifecycle of the processing environment. Infrastructure is provisioned on-demand upon file upload and decommissioned immediately after execution.

```text
[ GitHub ]
    |
    | (OIDC Authentication)
    v
[ GitHub Actions ]
    |
    | (Terraform)
    v
[ AWS Environment ]
    |
    +------------------------------------------------------------------------------+
    | AWS VPC (Virtual Private Cloud)                                              |
    |                                                                              |
    |   [ S3 Bucket ] --> [ EventBridge ] --> [ Step Functions ]                   |
    |  (Trigger Input)      (Event Bus)         (Orchestrator)                    |
    |                                              |                               |
    |          +-------------------------+---------+---------+-----------+         |
    |          |                         |                   |           |         |
    |   (Step 1: Spawn)          (Step 2: Wait)      (Step 3: Run)  (Step 4: Kill) |
    |          |                         |                   |           |         |
    |          v                         v                   v           v         |
    |   [ EC2 Instance ]         [ Boot sequence ]   [ ECS Fargate ] [ Terminate ] |
    |    (Ephemeral)               (30s Delay)        (Batch Logic)   (Cleanup)    |
    |                                                                              |
    +------------------------------------------------------------------------------+
```

---

## 🔧 Technical Component Deep-Dive

### 1. Orchestration Layer (`stepfunctions.tf`)

The **AWS Step Functions** state machine acts as the system "brain," managing the full CRUD lifecycle of the compute resources.

- **Dynamic Provisioning:** Uses `aws-sdk:ec2:runInstances` to spawn a pre-processing node only when needed.
- **Error Handling:** Implements `Catch` blocks across all states to ensure that the **TerminateEC2** step runs even if the batch processing fails, preventing "zombie" resource costs.
- **Stateful Mapping:** Utilizes JSONPath (`$.ec2_details.Instances[*].InstanceId`) to pass dynamic metadata between the creation and termination stages.

### 2. Compute Strategy (`ecs.tf`)

- **Batch Processor (ECS Fargate):**
  - **Resource Allocation:** Optimized at **256 CPU units** and **512MB RAM** for maximum cost-efficiency.
  - **Isolation:** Runs in a dedicated `awsvpc` network mode, ensuring no shared resources between processing tasks.
  - **Synchronous Monitoring:** The workflow uses the `.sync` pattern to track the container exit code before proceeding to cleanup.

### 3. Event-Driven Trigger (`s3.tf`)

The system eliminates manual intervention:

- **S3 Notifications:** The bucket (`2472737-transaction-input-bucket`) is configured with `eventbridge = true`.
- **EventBridge Rule:** Specifically filters for `Object Created` events to initiate the state machine.

### 4. Networking & Security (`network.tf` & `iam.tf`)

- **Ephemeral Identity:** An IAM Instance Profile is dynamically attached to the temporary EC2 instances to grant necessary permissions during their short lifespan.
- **VPC Design:** A secure VPC with an Internet Gateway ensures the system has the necessary outbound paths for AWS SDK communication and image pulls.

---

## 🚀 DevOps & Deployment

### Infrastructure as Code

- **Terraform Backend:** State is managed remotely in an S3 bucket (`2472737-terraform-state-storage`) with **native state locking** (`use_lockfile = true`).
- **Project Naming:** Standardized under the `transaction-processor` prefix for unified tagging and resource discovery.

### CI/CD Pipelines (GitHub Actions)

The repository includes two manually triggered workflows:

1.  **🚀 Deploy:** Runs `terraform init` and `terraform apply` to provision the orchestrator and networking.
2.  **💣 Destroy:** A fail-safe to decommission all permanent orchestration resources.

---

## 📊 Operational Visibility

| Metric                   | Source of Truth                                                |
| :----------------------- | :------------------------------------------------------------- |
| **Workflow Progress**    | Step Functions Visual Workflow Graph                           |
| **Infrastructure State** | Terraform S3 State File (`.tfstate`)                           |
| **Cleanup Status**       | EC2 Dashboard (All ephemeral instances should be `Terminated`) |
| **Deployment Logs**      | GitHub Actions Console                                         |

---

## 📖 Execution Guide

1.  **Infrastructure Setup:** Trigger the **Deploy** workflow in GitHub Actions.
2.  **Data Ingestion:** Upload a transaction file to the S3 bucket: `2472737-transaction-input-bucket`.
3.  **Monitor:** Open the **Step Functions Console** to watch the instance spawn, the ECS task execute, and the instance automatically terminate.
4.  **Verify Cleanup:** Check the EC2 console to confirm the temporary instance has been shut down.

---

## 📝 Conclusion

This system provides a professional, auditable, and highly cost-optimized processing pipeline. By moving from a persistent to an **ephemeral architecture**, the platform eliminates idle resource costs while maintaining a rigid, IaC-driven security posture.
