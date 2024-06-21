#!/bin/bash

export MPI_JOB_NAME=efa-nccl-test
export IMAGE_URI=public.ecr.aws/hpc-cloud/nccl-tests:latest
export INSTANCE_TYPE=p5.48xlarge
export NUM_WORKERS=2
export GPU_PER_WORKER=8
export EFA_PER_WORKER=32
export TOTAL_GPUS=$((${NUM_WORKERS}*${GPU_PER_WORKER}))

export NCCL_NVLS_ENABLE=1
export NCCL_PROTO=LL,LL128,Simple
export NCCL_ALGO=Ring
export FI_PROVIDER=efa
export FI_EFA_USE_DEVICE_RDMA=1
export RDMAV_FORK_SAFE=1
export NCCL_SHM_DISABLE=0

export HUGEPAGES_2MI=5120Mi
export MEMORY=10000Mi


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
  mpiImplementation: "OpenMPI"
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
               value: "/opt/amazon/openmpi/lib:/opt/nccl/build/lib:/opt/amazon/efa/lib:/opt/aws-ofi-nccl/install/lib:/usr/local/nvidia/lib"
             - name: PATH
               value: "/opt/amazon/efa/bin:/usr/bin"
             - name: XLA_FLAGS
               value: "--xla_gpu_cuda_data_dir=/usr/local/cuda"
             - name: TF_XLA_FLAGS
               value: "--tf_xla_cpu_global_jit"
             - name: NCCL_DEBUG
               value: INFO
            command:
            - /opt/amazon/openmpi/bin/mpirun
            - --allow-run-as-root
            - --oversubscribe
            - --tag-output
            #- -N
            #- "8"
            - -np
            - "${TOTAL_GPUS}"
            - -bind-to
            - none
            - -map-by
            - slot
            - -x
            - PATH
            - -x
            - LD_LIBRARY_PATH
            - -x
            - XLA_FLAGS
            - -x
            - TF_XLA_FLAGS
            - -x
            - NCCL_DEBUG=INFO
            #- -x
            #- NCCL_NVLS_ENABLE=${NCCL_NVLS_ENABLE}
            #- -x
            #- NCCL_PROTO=${NCCL_PROTO}
            #- -x
            #- NCCL_ALGO=${NCCL_ALGO}
            #- -x
            #- FI_PROVIDER=${FI_PROVIDER}
            #- -x
            #- FI_EFA_USE_DEVICE_RDMA=${FI_EFA_USE_DEVICE_RDMA}
            #- -x
            #- RDMAV_FORK_SAFE=${RDMAV_FORK_SAFE}
            #- -x
            #- NCCL_SHM_DISABLE=${NCCL_SHM_DISABLE}
            - --mca
            - pml
            - ^cm
            - --mca
            - plm_rsh_agent
            - ssh
            - /opt/nccl-tests/build/all_reduce_perf
            - -b
            - "1"
            - -e
            - 2G
            - -f
            - "2"
            - -t
            - "1"
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
