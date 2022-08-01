+++
title = "Amazon EKS and Kubeflow Compatibility"
description = "Check compatibility between Amazon EKS and Kubeflow versions"
weight = 30
+++

## Compatibility

Amazon EKS maintains end-to-end testing between EKS Kubernetes versions and Kubeflow versions. The following table relates compatibility between Kubernetes versions on Amazon EKS and Kubeflow v1.5.

<div class="table-responsive">
  <table class="table table-bordered">
    <thead class="thead-light">
      <tr>
        <th>EKS Versions</th>
        <th>Kubeflow v1.5</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1.22</td>
        <td><b>Incompatible</b></td>
      </tr>
      <tr>
        <td>1.21</td>
        <td><b>Compatible</b></td>
      </tr>
      <tr>
        <td>1.20</td>
        <td><b>Compatible</b></td>
      </tr>
      <tr>
        <td>1.19</td>
        <td><b>Compatible</b></td>
      </tr>
    </tbody>
  </table>
</div>

- **Incompatible**: the combination is not known to work together
- **Compatible**: all Kubeflow features have been tested and verified for the EKS Kubernetes version

