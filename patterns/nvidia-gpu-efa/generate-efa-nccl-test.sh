#!/bin/bash

export MPI_JOB_NAME=efa-nccl-test
export IMAGE_URI=public.ecr.aws/hpc-cloud/nccl-tests:latest
export INSTANCE_TYPE=p5e.48xlarge
export NUM_WORKERS=2
export GPU_PER_WORKER=8
export EFA_PER_WORKER=32
export TOTAL_GPUS=$((${NUM_WORKERS}*${GPU_PER_WORKER}))

export FI_PROVIDER=efa
export FI_EFA_USE_DEVICE_RDMA=1
export FI_EFA_FORK_SAFE=1

export NCCL_DEBUG=WARN
export NCCL_BUFFSIZE=8388608
export NCCL_P2P_NET_CHUNKSIZE=524288

export HUGEPAGES_2MI=5120Mi
export MEMORY=32000Mi

export DOLLAR='$'


cat <<EOF >> efa-nccl-test.yaml
apiVersion: kubeflow.org/v2beta1
kind: MPIJob
metadata:
  name: ${MPI_JOB_NAME}
spec:
  runPolicy:
    cleanPodPolicy: Running
    backoffLimit: 20
  slotsPerWorker: ${GPU_PER_WORKER}
  mpiReplicaSpecs:
    Launcher:
      replicas: 1
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - image: ${IMAGE_URI}
            name: ${MPI_JOB_NAME}-launcher
            imagePullPolicy: Always
            env:
             - name: LD_LIBRARY_PATH
               value: "/opt/amazon/openmpi/lib:/opt/nccl/build/lib:/opt/amazon/efa/lib:/opt/aws-ofi-nccl/install/lib:/usr/local/nvidia/lib:${DOLLAR}LD_LIBRARY_PATH"
             - name: PATH
               value: "${DOLLAR}PATH:/opt/amazon/efa/bin:/usr/bin"
            command:
            - /opt/amazon/openmpi/bin/mpirun
            - --allow-run-as-root
            - --tag-output
            - -N
            - "${GPU_PER_WORKER}"
            - -np
            - "${TOTAL_GPUS}"
            - -bind-to
            - none
            - -x
            - PATH
            - -x
            - LD_LIBRARY_PATH
            - -x
            - FI_PROVIDER=${FI_PROVIDER}
            - -x
            - FI_EFA_USE_DEVICE_RDMA=${FI_EFA_USE_DEVICE_RDMA}
            - -x
            - FI_EFA_FORK_SAFE=${FI_EFA_FORK_SAFE}
            - -x
            - NCCL_DEBUG=${NCCL_DEBUG}
            - -x
            - NCCL_BUFFSIZE=${NCCL_BUFFSIZE}
            - -x
            - NCCL_P2P_NET_CHUNKSIZE=${NCCL_P2P_NET_CHUNKSIZE}
            - --mca
            - pml
            - ^cm,ucx
            - --mca
            - btl
            - tcp,self
            - --mca
            - btl_tcp_if_exclude
            - lo,docker0,veth_def_agent
            - --mca
            - plm_rsh_agent
            - ssh
            - /opt/nccl-tests/build/all_reduce_perf
            - -b
            - "8"
            - -e
            - "16G"
            - -f
            - "2"
            - -g
            - "1"
            - -c
            - "1"
            - -n
            - "100"
    Worker:
      replicas: ${NUM_WORKERS}
      template:
        spec:
          nodeSelector:
            node.kubernetes.io/instance-type: "${INSTANCE_TYPE}"
          containers:
          - image: ${IMAGE_URI}
            name: ${MPI_JOB_NAME}-worker
            imagePullPolicy: Always
            volumeMounts:
            - name: shmem
              mountPath: /dev/shm
            resources:
              limits:
                nvidia.com/gpu: ${GPU_PER_WORKER}
                hugepages-2Mi: ${HUGEPAGES_2MI}
                vpc.amazonaws.com/efa: ${EFA_PER_WORKER}
                memory: ${MEMORY}
              requests:
                nvidia.com/gpu: ${GPU_PER_WORKER}
                hugepages-2Mi: ${HUGEPAGES_2MI}
                vpc.amazonaws.com/efa: ${EFA_PER_WORKER}
                memory: ${MEMORY}
          volumes:
          - name: shmem
            hostPath:
              path: /dev/shm
EOF
