#!/bin/bash
#set -e
#set -x

#export ARGOCD_PWD=$(aws secretsmanager get-secret-value --secret-id argocd-admin-secret.eks-blueprint --query SecretString --output text --region eu-west-3)
#export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
#argocd login --port-forward --username admin --password $ARGOCD_PWD --insecure


function delete_argocd_appset_except_pattern() {
  # List all your app to destroy
  # Get the list of ArgoCD applications and store them in an array
  #applicationsets=($(kubectl get applicationset -A -o json | jq -r '.items[] | .metadata.namespace + "/" + .metadata.name'))
  applicationsets=($(kubectl get applicationset -A -o json | jq -r '.items[] | .metadata.name'))

  # Iterate over the applications and delete them
  for app in "${applicationsets[@]}"; do
    if [[ ! "$app" =~ $1 ]]; then
      echo "Deleting applicationset: $app"
      kubectl delete ApplicationSet -n argocd $app --cascade=orphan
    else
        echo "Skipping deletion of applicationset: $app (contain '$1')"
    fi
  done

  #Wait for everything to delete
  continue_process=true
  while $continue_process; do
    # Get the list of ArgoCD applications and store them in an array
    applicationsets=($(kubectl get applicationset -A -o json | jq -r '.items[] | .metadata.name'))

    still_have_application=false
    # Iterate over the applications and delete them
    for app in "${applicationsets[@]}"; do
      if [[ ! "$app" =~ $1 ]]; then
        echo "applicationset $app still exists"
        still_have_application=true
      fi
    done
    sleep 5
    continue_process=$still_have_application
  done
  echo "No more applicationsets except $1"
}

function delete_argocd_app_except_pattern() {
  # List all your app to destroy
  # Get the list of ArgoCD applications and store them in an array
  #applications=($(argocd app list -o name))
  applications=($(kubectl get application -A -o json | jq -r '.items[] | .metadata.name'))

  # Iterate over the applications and delete them
  for app in "${applications[@]}"; do
    if [[ ! "$app" =~ $1 ]]; then
      echo "Deleting application: $app"
      kubectl -n argocd patch app $app  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
      kubectl -n argocd delete app $app
    else
      echo "Skipping deletion of application: $app (contain '$1')"
    fi
  done

  # Wait for everything to delete
  continue_process=true
  while $continue_process; do
    # Get the list of ArgoCD applications and store them in an array
    #applications=($(argocd app list -o name))
    applications=($(kubectl get application -A -o json | jq -r '.items[] | .metadata.name'))

    still_have_application=false
    # Iterate over the applications and delete them
    for app in "${applications[@]}"; do
      if [[ ! "$app" =~ $1 ]]; then
        echo "application $app still exists"
        still_have_application=true
      fi
    done
    sleep 5
    continue_process=$still_have_application
  done
  echo "No more applications except $1"
}

function wait_for_deletion() {
  # Loop until all Ingress resources are deleted
  while true; do
  # Get the list of Ingress resources in the specified namespace
  ingress_list=$(kubectl get ingress -A -o json)

  # Check if there are no Ingress resources left
  if [[ "$(echo "$ingress_list" | jq -r '.items | length')" -eq 0 ]]; then
    echo "All Ingress resources have been deleted."
    break
  fi
  echo "waiting for deletion"
  # Wait for a while before checking again (adjust the sleep duration as needed)
  sleep 5
done
}

echo "#1. First, we deactivate application sets"
delete_argocd_appset_except_pattern "^nomatch"

echo "#2. No we delete all app except addons"
delete_argocd_app_except_pattern "^.*addon-|^.*argo-cd|^bootstrap-addons|^team-platform"

echo "#3. Wait for objects to be deleted"
wait_for_deletion


echo "#4. Then we delete all addons except LBC and external-dns"
delete_argocd_app_except_pattern "^.*load-balancer|^.*external-dns|^.*argo-cd|^bootstrap-addons"

#delete_argocd_app_except_pattern "^.*load-balancer"

echo "Tear Down Applications OK"

set +x
