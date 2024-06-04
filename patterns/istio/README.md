# Amazon EKS Deployment Modes

Starting with Istio 1.20, Istio now offers two deployment models: traditional (called `sidecar`) and resource-savvy (called `ambient`).

You can choose your deployment mode by selecting one of the directories in the tree below. The `ambient` directory contains artifacts for deploying Istio in `Ambient` mode, while the `sidecar` directory contains artifacts for the traditional deployment mode.
# Amazon EKS Deployment Modes with Istio

As of Istio 1.20, deploying Istio on Amazon EKS introduces two distinct deployment models: the traditional approach, referred to as `sidecar`, and the newly introduced resource-optimized model, known as `ambient`.

## Understanding Deployment Modes

When deploying Istio on Amazon EKS, it's crucial to select the appropriate deployment mode that aligns with your application's requirements and operational preferences. Istio provides flexibility through these two deployment models:

### Traditional Deployment (`sidecar`)

The `sidecar` deployment mode reflects the conventional approach to Istio deployment. In this mode, each workload container is accompanied by an Istio sidecar container, facilitating the interception and management of traffic within the service mesh.

### Resource-Savvy Deployment (`ambient`)

In contrast, the `ambient` deployment mode, introduced recently, offers a resource-optimized strategy tailored for efficient utilization within Amazon EKS environments. This mode prioritizes resource efficiency while maintaining the functionalities of Istio's service mesh.

## Selecting Your Deployment Mode

To select the appropriate deployment mode for your Amazon EKS environment, navigate through the provided directory structure:

- **`sidecar` Directory:** Contains artifacts and configurations specifically tailored for the traditional `sidecar` deployment mode. If you prefer the classic Istio deployment approach, this directory is your destination.

- **`ambient` Directory:** Hosts artifacts and configurations optimized for the `ambient` deployment mode, designed to maximize resource efficiency within Amazon EKS clusters. If you aim for resource optimization while leveraging Istio's capabilities, explore the contents of this directory.

## Getting Started

To get started with deploying Istio on Amazon EKS using your preferred deployment mode, refer to the respective directories' contents. Each directory contains comprehensive instructions and configuration files to streamline the deployment process.
