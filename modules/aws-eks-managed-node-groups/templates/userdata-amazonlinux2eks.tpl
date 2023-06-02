MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

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
%{ if length(service_ipv6_cidr) > 0 ~}
export SERVICE_IPV6_CIDR=${service_ipv6_cidr}
%{ endif ~}
%{ if length(custom_ami_id) > 0 ~}
B64_CLUSTER_CA=${cluster_ca_base64}
API_SERVER_URL=${cluster_endpoint}
/etc/eks/bootstrap.sh ${eks_cluster_id} --kubelet-extra-args "${kubelet_extra_args}" ${bootstrap_extra_args}
%{ endif ~}
%{ if length(post_userdata) > 0 ~}
# User-supplied post userdata
${post_userdata}
%{ endif ~}
--//--
