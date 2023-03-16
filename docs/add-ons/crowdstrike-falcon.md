# CrowdStrike Falcon

[`terraform-kubectl-falcon`](https://github.com/CrowdStrike/terraform-kubectl-falcon) is a Terraform module that can automate the deployment of CrowdStrike Falcon Sensor and the Kubernetes Protection Agent on a Kubernetes cluster.

## Falcon Operator

Falcon Operator is a Kubernetes operator that manages the deployment of the CrowdStrike Falcon Sensor on a Kubernetes cluster. The CrowdStrike Falcon Sensor provides runtime protection for workloads running on a Kubernetes cluster.

More information can be found in the [Operator submodule](https://github.com/CrowdStrike/terraform-kubectl-falcon/blob/main/modules/operator/README.md).

## Kubernetes Protection Agent (KPA)

The Kubernetes Protection Agent provides visibility into the cluster by collecting event information from the Kubernetes layer. These events are correlated to sensor events and cloud events to provide complete cluster visibility.

More information can be found in the [KPA sub-module](https://github.com/CrowdStrike/terraform-kubectl-falcon/blob/main/modules/k8s-protection-agent/README.md).

## Usage

Refer to the [`terraform-kubectl-falcon`](https://github.com/CrowdStrike/terraform-kubectl-falcon) documentation for the most up-to-date information on inputs and outputs.

## Example

A full end to end example of using the `terraform-kubectl-falcon` module with `eks_blueprints` can be found in the [examples](https://github.com/CrowdStrike/terraform-kubectl-falcon/tree/v0.1.0/examples/aws-eks-blueprint-example) directory of the `terraform-kubectl-falcon` module.
