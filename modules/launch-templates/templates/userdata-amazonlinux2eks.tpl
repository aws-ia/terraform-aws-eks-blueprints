MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

# User-supplied pre userdata code
${pre_userdata}

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_ca_base64}' --apiserver-endpoint '${cluster_endpoint}' ${bootstrap_extra_args} --kubelet-extra-args "${kubelet_extra_args}" '${eks_cluster_id}'

# User-supplied post userdata code
${post_userdata}

--//--
