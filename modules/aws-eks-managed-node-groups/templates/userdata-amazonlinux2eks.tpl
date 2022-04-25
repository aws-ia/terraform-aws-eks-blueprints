MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

echo "Running custom user data script"

# User-supplied pre userdata
${pre_userdata}

# Format and Mount NVMe Disks if available
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

if [ ${service_ipv4_cidr} ];then
echo "Setting custom IPV4 CIDR"
export SERVICE_IPV4_CIDR=${service_ipv4_cidr}
fi

if [ ${service_ipv6_cidr} ];then
echo "Setting custom IPV6 CIDR"
export SERVICE_IPV6_CIDR=${service_ipv6_cidr}
fi

# Bootstrap and join the cluster used only when custom_ami_id is specified. Otherwise, it will use the bootstrap.sh from the default managed launch template merged by EKS API
# e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
# e.g., kubelet_extra_args = "--node-labels=arch=x86,WorkerType=SPOT --max-pods=50 --register-with-taints=spot=true:NoSchedule"  # Equivalent to k8s_labels used in managed node groups

if [ ${custom_ami_id} ];then
echo "Running custom Bootstrap script"
B64_CLUSTER_CA=${cluster_ca_base64}
API_SERVER_URL=${cluster_endpoint}
/etc/eks/bootstrap.sh '${eks_cluster_id}' --kubelet-extra-args "${kubelet_extra_args}" ${bootstrap_extra_args}
fi

# User-supplied post userdata
${post_userdata}

--//--
