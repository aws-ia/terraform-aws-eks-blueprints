MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

# User-supplied pre userdata code
${pre_userdata}

if [ ${format_mount_nvme_disk} = true ];then
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
fi

if [ ${service_ipv4_cidr} ];then
echo "Setting custom IPV4 CIDR"
export SERVICE_IPV4_CIDR=${service_ipv4_cidr}
fi

if [ ${service_ipv6_cidr} ];then
echo "Setting custom IPV6 CIDR"
export SERVICE_IPV6_CIDR=${service_ipv6_cidr}
fi

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_ca_base64}' --apiserver-endpoint '${cluster_endpoint}' ${bootstrap_extra_args} --kubelet-extra-args "${kubelet_extra_args}" '${eks_cluster_id}'

# User-supplied post userdata code
${post_userdata}

--//--
