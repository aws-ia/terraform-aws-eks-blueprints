MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
echo "bootstrap.sh: entered"

%{ if length(pre_userdata) > 0 ~}
# User-supplied pre userdata
${pre_userdata}
%{ endif ~}
%{ if format_mount_nvme_disk ~}
echo "Format and Mount NVMe Disks if available"
IDX=1
DEVICES=$(lsblk -o NAME,TYPE -dsn | awk '/disk/ {print $1}')

for DEV in $DEVICES
do
  mkfs.xfs /dev/$${DEV}
  mkdir -p /local$${IDX}

  echo /dev/$${DEV} /local$${IDX} xfs defaults,noatime 1 2 >> /etc/fstab

  IDX=$(($${IDX} + 1))
done
mount -a
%{ endif ~}
%{ if length(service_ipv4_cidr) > 0 ~}
export SERVICE_IPV4_CIDR=${service_ipv4_cidr}
%{ endif ~}
%{ if length(service_ipv4_cidr) > 0 ~}
export SERVICE_IPV6_CIDR=${service_ipv6_cidr}
%{ endif ~}
%{ if length(custom_ami_id) > 0 ~}
B64_CLUSTER_CA=${cluster_ca_base64}
API_SERVER_URL=${cluster_endpoint}
%{ if set_node_instance_label_to_ec2_instance_id ~}
# Fetch instance_id from metadata and insert "instance=${instance_id}" into --node-labels
EC2_METADATA_API_TOKEN=$(curl --silent -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $${EC2_METADATA_API_TOKEN}" --silent http://169.254.169.254/latest/meta-data/instance-id)
kubelet_extra_args=$${kubelet_extra_args/--node-labels=/--node-labels=instance=$${INSTANCE_ID},}
%{ endif ~}
/etc/eks/bootstrap.sh ${eks_cluster_id} --kubelet-extra-args "${kubelet_extra_args}" ${bootstrap_extra_args}
%{ endif ~}
%{ if length(post_userdata) > 0 ~}
# User-supplied post userdata
${post_userdata}
%{ endif ~}
echo "bootstrap.sh: exiting"
--//--
