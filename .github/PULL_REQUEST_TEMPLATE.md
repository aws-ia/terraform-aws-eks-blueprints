## :bangbang: PLEASE READ THIS FIRST :bangbang:

The direction for EKS Blueprints will soon shift from providing an all-encompassing, monolithic "framework" and instead focus more on how users can organize a set of modular components to create the desired solution on Amazon EKS. We have updated the [examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples) to show how we use the https://github.com/terraform-aws-modules/terraform-aws-eks for EKS cluster and node group creation. We will not be accepting any PRs that apply to EKS cluster or node group creation process. Any such PR may be closed by the maintainers.

We are hitting also the pause button on new add-on creations at this time until a future roadmap for add-ons is finalized. Please do not submit new add-on PRs. Any such PR may be closed by the maintainers.

Please track progress, learn what's new and how the migration path would look like to upgrade your current Terraform deployments. We welcome the EKS Blueprints community to continue the discussion in issue https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1421

### What does this PR do?

🛑 Please open an issue first to discuss any significant work and flesh out details/direction - we would hate for your time to be wasted.
Consult the [CONTRIBUTING](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/CONTRIBUTING.md#contributing-via-pull-requests) guide for submitting pull-requests.

<!-- A brief description of the change being made with this pull request. -->

### Motivation

<!-- What inspired you to submit this pull request? -->
- Resolves #<issue-number>

### More

- [ ] Yes, I have tested the PR using my local account setup (Provide any test evidence report under Additional Notes)
- [ ] Yes, I have updated the [docs](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/docs) for this feature
- [ ] Yes, I ran `pre-commit run -a` with this PR

### For Moderators

- [ ] E2E Test successfully complete before merge?

### Additional Notes

<!-- Anything else we should know when reviewing? -->
