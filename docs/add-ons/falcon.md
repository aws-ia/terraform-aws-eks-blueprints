# CrowdStrike Falcon Operator

The [Falcon Operator](https://github.com/crowdstrike/falcon-operator) is a Kubernetes add-on that can automate the deployment of CrowdStrike Falcon Node Sensor and/or CrowdStrike Falcon Container sensor on a Kubernetes cluster.

Falcon Node Sensor and Falcon Container Sensor are CrowdStrike products that provide runtime protection to the nodes and pods.

If you choose to install Falcon Node Sensor the operator will manage Kubernetes DaemonSet for you to deploy the Node Sensor onto each node of your kubernetes cluster. Alternatively, if you choose to install Falcon Container Sensor the operator will set-up deployment hook on your cluster so every new deployment will get Falcon Container inserted in each pod.

> Note: Falcon Node Sensor is the recommend approach on AWS EKS unless you are using EKS Fargate in that case please use Falcon Container Sensor.

Detailed documentation for [FalconNodeSensor](https://github.com/CrowdStrike/falcon-operator/tree/main/docs/node) and [FalconContainer](https://github.com/CrowdStrike/falcon-operator/tree/main/docs/container) can be found in the [falcon-operator](https://github.com/CrowdStrike/falcon-operator) repository.

## Pre-requisites

You will need to provide CrowdStrike API Keys and CrowdStrike cloud region for the installation. It is recommended to establish new API credentials for the installation at https://falcon.crowdstrike.com/support/api-clients-and-keys, minimal required permissions are:

 - Falcon Images Download: **Read**
 - Sensor Download: **Read**

Credentials (`client_id` and `client_secret`) from this step will be used in deployment.

## Usage

The Falcon Operator and Falcon Sensors can be deployed by enabling the add-on via the following.

```hcl
enable_falcon_operator = true
```

You will be required to provide Falcon sensor type that you request to install. Either FalconNodeSensor or FalconContainer
```
falcon_sensor_type = FalconNodeSensor # or FalconContainer
```

The sensor will be downloaded directly from CrowdStrike using your API credentials obtained in the previous step.
```
falcon_client_id =
falcon_client_secret =
```
