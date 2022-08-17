# Karpenter Provisioners

# Introductions

Karpenter provisioners set constraints on the nodes that can be created by Karpenter and the pods that can be run on these nodes. The Provisioner can be set to do things like:

* Define taints to limit the pods that can run on nodes Karpenter creates
* Define any startup taints to inform Karpenter that it should taint the node initially, but that the taint is temporary.
* Limit node creation to certain zones, instance types, and computer architectures
* Set defaults for node expiration

This module allows you to create Karpenter provisioners and manage them from code.
