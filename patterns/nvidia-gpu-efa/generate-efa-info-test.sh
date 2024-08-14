#!/bin/bash

export MPI_JOB_NAME=efa-info-test
export IMAGE_URI=public.ecr.aws/hpc-cloud/nccl-tests:latest
export NUM_WORKERS=2
export GPU_PER_WORKER=8
export EFA_PER_WORKER=32
export TOTAL_GPUS=$((${NUM_WORKERS}*${GPU_PER_WORKER}))

cat <<EOF >> efa-info-test.yaml
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
          tolerations:
          - key: "nvidia.com/gpu"
            operator: "Equal"
            value: "true"
            effect: "NoSchedule"
          containers:
          - image: ${IMAGE_URI}
            name: ${MPI_JOB_NAME}-launcher
            imagePullPolicy: IfNotPresent
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
            - --tag-output
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
            - --mca
            - pml
            - ^cm
            - --mca
            - pml_rsh_agent=ssh
            - --oversubscribe
            - /opt/amazon/efa/bin/fi_info
            - -p
            - "efa"
            - -t
            - "FI_EP_RDM"
    Worker:
      replicas: ${NUM_WORKERS}
      template:
        spec:
          containers:
          - image: ${IMAGE_URI}
            name: ${MPI_JOB_NAME}-worker
            imagePullPolicy: IfNotPresent
            resources:
              limits:
                nvidia.com/gpu: ${GPU_PER_WORKER}
                vpc.amazonaws.com/efa: ${EFA_PER_WORKER}
              requests:
                nvidia.com/gpu: ${GPU_PER_WORKER}
                vpc.amazonaws.com/efa: ${EFA_PER_WORKER}
EOF
