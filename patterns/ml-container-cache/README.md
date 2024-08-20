# EKS Cluster w/ Cached ML Images

TODO

The following components are demonstrated in this pattern:

### Cached

<p align="center">
  <img src="assets/cached.svg" alt="cached image startup time">
</p>

### Uncached

<p align="center">
  <img src="assets/uncached.svg" alt="uncached image startup time">
</p>

## Code

```terraform hl_lines="24-26 32-67"
{% include  "../../patterns/ml-container-cache/eks.tf" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

TODO

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
