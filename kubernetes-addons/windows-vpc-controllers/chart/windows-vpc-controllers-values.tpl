resourceController:
  # name of most K8s resources - container, service account etc.
  name: windows-vpc-resource-controller
  image:
    repository: ${resource_controller_image_repo}
    tag: ${resource_controller_image_tag}
    pullPolicy: Always
  livenessProbe:
    failureThreshold: 5
    initialDelaySeconds: 30
    periodSeconds: 30
    timeoutSeconds: 5
  containerCommand:
    args:
      - -stderrthreshold=info

admissionWebhook:
  # name of most K8s resources - container, service, mutating webhook etc.
  name: windows-vpc-admission-webhook
  image:
    repository: ${admission_webhook_image_repo}
    tag: ${admission_webhook_image_tag}
    pullPolicy: Always
  containerCommand:
    args:
      - -tlsCertFile=/etc/webhook/tls/tls.crt
      - -tlsKeyFile=/etc/webhook/tls/tls.key
      - -OSLabelSelectorOverride=windows
      - -alsologtostderr
      - -v=5
      - 2>&1
  secret:
    name: windows-vpc-admission-webhook-tls
  # cert-manager certificate parameters
  certificate:
    duration: 8760h # 1 yr
    renewBefore: 360h # 15d
    subject:
      orgName: sampleorg
    key:
      algorithm: ECDSA
      size: 256
      rotationPolicy: Always
    usages:
      - server auth
      - key encipherment
      - digital signature
    issuer:
      name: cert-manager-ca-issuer
      kind: ClusterIssuer
