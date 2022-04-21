# Traefik

Traefik is an open-source Edge Router that makes publishing your services a fun and easy experience. It receives requests on behalf of your system and finds out which components are responsible for handling them.

For complete project documentation, please visit the [Traefik documentation site](https://doc.traefik.io/traefik/).

## Usage

[Traefik](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/traefik) can be deployed by enabling the add-on via the following.

```hcl
enable_traefik = true
```

## How to test Traefik Web UI

Once the Traefik deployment is successful, run the following command from your a local machine which have access to an EKS cluster using kubectl.

```
$ kubectl port-forward svc/traefik -n kube-system 9000:9000
```

Now open the browser from your machine and enter the below URL to access Traefik Web UI.

```
http://127.0.0.1:9000/dashboard/
```

![alt text](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/a8ceac6c977a3ccbcb95ef7fb21fff0daf0b7081/images/traefik_web_ui.png "Traefik Dashboard")

#### AWS Service annotations for Traefik Ingress Controller

Here is the link to get the AWS ELB [service annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/) for Traefik Ingress controller

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
traefik = {
  enable = true
}
```
