# TLS with AWS PCA Issuer

This pattern demonstrates how to enable TLS with AWS PCA issuer on an Amazon EKS cluster.


## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites required to deploy this pattern and steps to deploy.

## Validate

1. List all the pods running in `aws-privateca-issuer` and `cert-manager` Namespace.

    ```sh
    kubectl get pods -n aws-privateca-issuer
    kubectl get pods -n cert-manager
    ```

2. View the `certificate` status in the `default` Namespace. It should be in `Ready` state, and be pointing to a `secret` created in the same Namespace.

    ```sh
    kubectl get certificate -o wide

    NAME      READY   SECRET                  ISSUER                    STATUS                                          AGE
    example   True    example-clusterissuer   tls-with-aws-pca-issuer   Certificate is up to date and has not expired   41m

    kubectl get secret example-clusterissuer

    NAME                    TYPE                DATA   AGE
    example-clusterissuer   kubernetes.io/tls   3      43m
    ```

## Destroy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for steps to clean up the resources created.
