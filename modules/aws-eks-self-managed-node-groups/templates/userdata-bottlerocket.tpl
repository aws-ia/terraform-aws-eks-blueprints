${pre_userdata}
[settings.kubernetes]
api-server = "${cluster_endpoint}"
cluster-certificate = "${cluster_ca_base64}"
cluster-name = "${eks_cluster_id}"
${post_userdata}
