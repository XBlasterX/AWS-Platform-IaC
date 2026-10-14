# Architecture Decision Records (ADR)

This log documents the key architectural choices, alternatives considered, and trade-offs accepted across the lifecycle of this infrastructure.

---

## ADR-001: AWS Systems Manager Session Manager over SSH Bastion Host

- **Status**: Accepted
- **Deciders**: Infrastructure Engineer
- **Date**: 2026-10-10

### Context

Administrative access to EC2 instances in private subnets is required for troubleshooting and maintenance. The traditional pattern involves deploying a Bastion host (jump box) in a public subnet, maintaining SSH key pairs, and exposing TCP port 22.

### Decision

Omit the Bastion host entirely. Use AWS Systems Manager (SSM) Session Manager combined with VPC Interface Endpoints (`ssm`, `ssmmessages`) deployed directly into the private subnets.

### Alternatives Considered

1. **Public Bastion Host**: Exposes port 22 to the internet, requires EC2 compute cost, SSH key rotation, and maintenance of bastion OS hardening.
2. **VPN Gateway / Client VPN**: Significant recurring hourly costs; disproportionate for a lightweight lab environment.

### Consequences

- **Positive**:
  - No public SSH ingress or bastion host; the application ALB still exposes HTTP port 80.
  - No SSH key management or distribution overhead.
  - IAM policies can scope administrative access to instances using project and environment tags.
  - Zero compute cost for an extra bastion EC2 instance.
- **Negative / Trade-offs**:
  - Requires deploying AWS Interface VPC Endpoints into the VPC (incurring per-endpoint hourly charges).
  - Access requires the AWS CLI and Session Manager plugin installed locally.
  - Session command/output logging requires additional configuration and is not configured in this repository. See [AWS session logging documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-logging.html).

---

## ADR-002: Private Subnet Isolation Without NAT Gateway

- **Status**: Accepted
- **Deciders**: Infrastructure Engineer
- **Date**: 2026-10-10

### Context

Workload instances run in private subnets across two Availability Zones. In standard AWS reference architectures, private subnets route outbound internet traffic through one or two NAT Gateways to fetch packages, security updates, and reach AWS public endpoints.

### Decision

Deploy no NAT Gateway. Route tables in private subnets have no default route (`0.0.0.0/0`). Outbound traffic is restricted to internal AWS services via VPC Interface Endpoints.

### Alternatives Considered

1. **Single NAT Gateway**: Adds hourly and data processing charges and an AZ dependency for egress. Estimate costs for the deployment region and expected traffic.
2. **Dual NAT Gateway (Multi-AZ HA)**: Adds two sets of hourly charges; a higher recurring cost for this lab.
3. **NAT Instance on t4g.nano**: Cheaper, but requires custom routing, script maintenance, failover management, and OS patching.

### Consequences

- **Positive**:
  - No NAT Gateway charges; interface endpoints still incur recurring charges in both AZs.
  - No direct internet egress from EC2. The absence of a default route limits outbound destinations but does not make the environment air-gapped or prevent every possible data exfiltration path.
- **Negative / Trade-offs**:
  - Instances cannot fetch public package repositories or external dependencies directly. The user-data script relies on Python being present in the AMI; a controlled AMI refresh and security patching process is still required.

---

## ADR-003: Chained Security Group References over CIDR Ingress

- **Status**: Accepted
- **Deciders**: Infrastructure Engineer
- **Date**: 2026-10-11

### Context

Traffic flows between the Application Load Balancer (public subnets), EC2 instances (private subnets), and VPC Endpoints (private subnets). Firewall rules must restrict communication to required ports only.

### Decision

Use `referenced_security_group_id` via modern separate rule resources (`aws_vpc_security_group_ingress_rule` / `aws_vpc_security_group_egress_rule`) instead of CIDR-based firewall rules:
- ALB egress points to EC2 Security Group ID on port 80.
- EC2 ingress permits only ALB Security Group ID on port 80.
- EC2 egress points only to VPC Endpoints Security Group ID on port 443.

### Alternatives Considered

1. **Subnet CIDR filtering**: Using the public subnet ranges (`10.40.10.0/24` and `10.40.20.0/24`) would allow any source in those ranges rather than only members of the ALB SG, and would require updates if addressing changes.
2. **Monolithic security groups**: Defining inline `ingress` and `egress` blocks inside `aws_security_group`. Causes cyclic dependency errors in Terraform when two groups reference each other.

### Consequences

- **Positive**:
  - Principle of least privilege: only resources explicitly attached to the referenced security group can exchange traffic.
  - Decoupled from IP allocations and future subnet expansions.
  - Prevents cyclic dependency deadlock during Terraform provisioning.
- **Negative / Trade-offs**:
  - Requires maintaining discrete rule resources for every direction and port combination.

---

## ADR-004: Native S3 State Locking (`use_lockfile = true`)

- **Status**: Accepted
- **Deciders**: Infrastructure Engineer
- **Date**: 2026-10-11

### Context

Terraform requires a locking mechanism to prevent simultaneous executions from corrupting remote state stored in Amazon S3. Historically, this required provisioning and maintaining an AWS DynamoDB table with a `LockID` primary key.

### Decision

Leverage the native S3 lockfile mechanism introduced in Terraform 1.10+ by setting `use_lockfile = true` in the backend block.

### Alternatives Considered

1. **DynamoDB State Locking**: Proven legacy approach. Requires extra Terraform code, IAM permissions, and an additional AWS resource in `bootstrap/`.
2. **No State Locking**: High risk of state corruption when team members or CI pipelines run concurrent applies.

### Consequences

- **Positive**:
  - Eliminates the DynamoDB table from the bootstrap phase.
  - Simplifies the backend configuration and minimizes required AWS IAM permissions.
  - Native atomic lockfile created directly inside the S3 bucket alongside the `.tfstate` file.
- **Negative / Trade-offs**:
  - Requires Terraform CLI version >= 1.10.0 (CI is pinned to 1.16.x).

---

## ADR-005: Checkov Baseline for CI Security Scanning

- **Status**: Accepted
- **Deciders**: Infrastructure Engineer
- **Date**: 2026-10-12

### Context

Static security scanning (SAST) is essential to catch misconfigurations (e.g., unencrypted disks, open security groups) before deployment. Running Checkov against a lab configuration generates alerts for intentional trade-offs (e.g., HTTP listener without ACM, no AWS WAF).

### Decision

Commit `.checkov.baseline` and document its entries in [SECURITY.md](../SECURITY.md#static-security-analysis--checkov-baseline). Checkov runs in GitHub Actions using `--baseline .checkov.baseline --output-baseline-as-skipped`. The current inventory includes intentional lab exceptions, cleanup items, and scanner findings requiring revalidation; baseline presence alone does not establish that an exception is justified.

### Alternatives Considered

1. **Inline `#checkov:skip` annotations**: Clutters HCL code with comments; difficult to audit in one centralized location.
2. **Ignoring Checkov in CI (`continue-on-error: true`)**: Defeats the purpose of the security gate; real regressions would go unnoticed.

### Consequences

- **Positive**:
  - Findings listed in the baseline are reported as skipped.
  - CI fails on Checkov findings not covered by the baseline.
  - Exception addresses and check IDs are centralized, with rationale and follow-up recorded in SECURITY.md.
- **Negative / Trade-offs**:
  - A regression matching an existing resource/check exception can remain suppressed. Changes affecting accepted exceptions require manual review.
  - Checkov only detects issues covered by its checks; passing CI is not proof of runtime security.
  - Run scans without the baseline when reviewing exceptions. Remove resolved entries and assess new findings individually before updating it. See [Checkov baseline options](https://www.checkov.io/2.Basics/CLI%20Command%20Reference.html).

---

## ADR-006: Target Tracking Auto Scaling Policy Based on CPU Utilization

- **Status**: Accepted
- **Deciders**: Infrastructure Engineer
- **Date**: 2026-10-12

### Context

The compute layer needs automated scaling to respond to fluctuating traffic while maintaining high availability across two Availability Zones.

### Decision

Configure an Auto Scaling Group with `desired_capacity = 2`, `min_size = 2`, and `max_size = 3`, managed by a `TargetTrackingScaling` policy targeting 60% `ASGAverageCPUUtilization`.

### Alternatives Considered

1. **Static EC2 instances**: No automatic recovery if an instance terminates or becomes unhealthy.
2. **Step Scaling Policies**: Requires defining multiple manual CloudWatch alarms and step adjustments (complex for a baseline web application).

### Consequences

- **Positive**:
  - CloudWatch and AWS Auto Scaling handle alarm creation and capacity calculation automatically.
  - Configures a minimum capacity of two instances across two AZs. Auto Scaling attempts to balance placement; one healthy instance per AZ is not guaranteed during capacity shortages or failures.
- **Negative / Trade-offs**:
  - Target tracking policies can be sensitive to brief CPU spikes if warm-up intervals are not tuned properly.
