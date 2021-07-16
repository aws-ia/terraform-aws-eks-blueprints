${pre_userdata}
[settings.kubernetes]
api-server = "${endpoint}"
cluster-certificate = "${cluster_auth_base64}"
cluster-name = "${cluster_name}"
${additional_userdata}