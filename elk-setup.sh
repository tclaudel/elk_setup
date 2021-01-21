#!/bin/bash

# minikube : minikube start --cpus 4 --memory 8192
# https://itnext.io/deploy-elastic-stack-on-kubernetes-1-15-using-helm-v3-9105653c7c8

NAME=$1
NS=default
CHART=elastic/${NAME}
VERSION=v7.6.1
VALUES=${NAME}/values.yaml
RELEASE=$(helm ls | awk '{print $1}' | grep ${NAME})

function help {
	echo -e "\nPlease run this script this 2 parameters"
	echo -e "\nUsage:\n$0 [elastisearch|kibana|metricbeat|filebeat]"
	echo -e "\n Example:\n$0 elasticsearch \n"
}

function check {
	NS_LOG=$(kubectl get namespaces | grep log)
	if [[ -z ${NS_LOG} ]]; then
		kubectl create namespace log
	fi
	HELM_VERSION=$(helm version --short)
	if [[ ${HELM_VERSION:1:1} -ne 3 ]]; then 
		curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
		chmod 700 get_helm.sh
		./get_helm.sh
	fi 
}

check
helm repo update
case $@ in
elasticsearch | kibana | metricbeat | filebeat)
  helm install ${CHART} --namespace ${NS} -f ${VALUES} --version ${VERSION} --generate-name
  echo "Installed ${NAME}"
  ;;
*)
	help
	;;
esac

