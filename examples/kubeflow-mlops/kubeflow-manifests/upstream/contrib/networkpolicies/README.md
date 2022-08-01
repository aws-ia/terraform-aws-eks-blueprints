### 1. Why would a user apply the extra policies?
It is a second line of defence after Istio autorization policies and it protects pods and services that are not protected by Istio

### 2. Effects they will have in the cluster
Please consult the name of and comments in each networkpolicy for further information.

### 3. We should achieve the same with AuthorizationPolicies
But there are components, e.g. Katib that are not secured by istio
