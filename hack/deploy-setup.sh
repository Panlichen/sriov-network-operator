#!/bin/bash
# This script inits a cluster to allow sriov-network-operator
# to deploy.  It assumes it is capable of login as a
# user who has the cluster-admin role

# set -euxo pipefail
echo in deploy-setup.sh, before source "$(dirname $0)/common", repo_dir is $repo_dir
echo in deploy-setup.sh, \$0 is $0
source "$(dirname $0)/common"
echo in deploy-setup.sh, after source "$(dirname $0)/common", repo_dir is $repo_dir

echo HAHA is $HAHA

load_manifest() {
  local repo=$1
  local namespace=${2:-}
  export NAMESPACE=${namespace}
  echo $repo $namespace
  if [ -n "${namespace}" ] ; then
    namespace="-n ${namespace}"
  fi

  pushd ${repo}/deploy
    if ! ${OPERATOR_EXEC} get ns $2 > /dev/null 2>&1 && test -f namespace.yaml ; then
      
      envsubst< namespace.yaml | ${OPERATOR_EXEC} apply -f -
    fi
    files="service_account.yaml role.yaml role_binding.yaml clusterrole.yaml clusterrolebinding.yaml operator.yaml"
    for m in ${files}; do
      if [ "$(echo ${EXCLUSIONS[@]} | grep -o ${m} | wc -w | xargs)" == "0" ] ; then
        envsubst< ${m} | ${OPERATOR_EXEC} apply ${namespace:-} --validate=false -f -
      fi
    done

  popd
}

# This is required for when running the operator locally using go run
rm -rf /tmp/_working_dir
mkdir /tmp/_working_dir
source hack/env.sh

echo ${repo_dir} $1
load_manifest ${repo_dir} $1
