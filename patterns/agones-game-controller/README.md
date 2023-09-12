# Amazon EKS Deployment with Agones Gaming Kubernetes Controller

This pattern shows how to deploy and run gaming applications on Amazon EKS using the Agones Kubernetes Controller

Agones is an open source Kubernetes controller that provisions and manages dedicated game server
processes within Kubernetes clusters using standard Kubernetes tooling and APIs.
This model also allows any matchmaker to interact directly with Agones via the Kubernetes API to provision a dedicated game server

Amazon GameLift enables developers to deploy, operate, and scale dedicated, low-cost servers in the cloud for session-based, multiplayer games.
Built on AWS global computing infrastructure, GameLift helps deliver high-performance, high-reliability,
low-cost game servers while dynamically scaling your resource usage to meet worldwide player demand. See below
for more information on how GameLift FleetIQ can be integrated with Agones deployed on Amazon EKS.

Amazon GameLift FleetIQ optimizes the use of low-cost Spot Instances for cloud-based game hosting with Amazon EC2.
With GameLift FleetIQ, you can work directly with your hosting resources in Amazon EC2 and Auto Scaling while
taking advantage of GameLift optimizations to deliver inexpensive, resilient game hosting for your players
and makes the use of low-cost Spot Instances viable for game hosting

This [blog](https://aws.amazon.com/blogs/gametech/introducing-the-gamelift-fleetiq-adapter-for-agones/) walks
through the details of deploying EKS Cluster using eksctl and deploy Agones with GameLift FleetIQ.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites required to deploy this pattern and steps to deploy.

## Validate

1. Deploy the sample game server

    ```sh
    kubectl create -f https://raw.githubusercontent.com/googleforgames/agones/release-1.32.0/examples/simple-game-server/gameserver.yaml
    kubectl get gs

    NAME                       STATE   ADDRESS         PORT   NODE                                        AGE
    simple-game-server-7r6jr   Ready   34.243.345.22   7902   ip-10-1-23-233.eu-west-1.compute.internal   11h
    ```

2. Test the sample game server using [`netcat`](https://netcat.sourceforge.net/)

    ```sh
    echo -n "UDP test - Hello EKS Blueprints!" | nc -u 34.243.345.22 7902
    Hello EKS Blueprints!
    ACK: Hello EKS Blueprints!
    EXIT
    ACK: EXIT
    ```

## Destroy

First, delete the resources created by the sample game server:

```sh
kubectl -n default delete gs --all || true
```

Finally, see [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for steps to clean up the resources created.
