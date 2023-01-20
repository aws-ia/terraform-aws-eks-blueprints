# Trino

Trino is a distributed SQL query engine designed to query large data sets distributed over one or more heterogeneous data sources.

For complete project documentation, please visit the [Trino documentation site](https://trino.io/docs/current/overview.html).

## Usage

[Trino](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/trino) can be deployed by enabling the add-on via the following.

```hcl
enable_trino = true
```

## How to test Trino Web UI

Once the Trino deployment is successful, run the following command from your a local machine which have access to an EKS cluster using kubectl.

```
$ kubectl port-forward svc/trino -n kube-system 8080:8080
```

Now open the browser from your machine and enter the below URL to access Trino Web UI.

```
http://127.0.0.1:8080
```

Usage any username and leave the password field empty to login.

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
trino = {
  enable = true
}
```
