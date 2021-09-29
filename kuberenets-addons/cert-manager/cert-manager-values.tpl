extraArgs:
  - --enable-certificate-owner-ref=true

image:
  repository: ${image}
  tag: ${tag}

installCRDs: ${installCRDs}

nodeSelector:
  kubernetes.io/os: linux

cainjector:
  nodeSelector:
    kubernetes.io/os: linux

startupapicheck:
  nodeSelector:
    kubernetes.io/os: linux

webhook:
  nodeSelector:
    kubernetes.io/os: linux
