#!/usr/bin/env bash
#
#  Licensed to the Apache Software Foundation (ASF) under one   *
#  or more contributor license agreements.  See the NOTICE file *
#  distributed with this work for additional information        *
#  regarding copyright ownership.  The ASF licenses this file   *
#  to you under the Apache License, Version 2.0 (the            *
#  "License"); you may not use this file except in compliance   *
#  with the License.  You may obtain a copy of the License at   *
#                                                               *
#    http://www.apache.org/licenses/LICENSE-2.0                 *
#                                                               *
#  Unless required by applicable law or agreed to in writing,   *
#  software distributed under the License is distributed on an  *
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY       *
#  KIND, either express or implied.  See the License for the    *
#  specific language governing permissions and limitations      *
#  under the License.                                           *
set -x

echo "This script sets up kubernetes for testing purposes, builds the airflow \
source and docker image, and then deploys airflow onto kubernetes"

DIRNAME=$(cd "$(dirname "$0")"; pwd)

sudo apt-get update
sudo apt-get install --no-install-recommends -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce-cli

# Install kubectl
if [[ ! -x /usr/local/bin/kubectl ]]; then
  echo "Downloading kubectl, which is a requirement for Kubernetes."
  curl -Lo kubectl  \
    "https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/kubectl
fi

mkdir -p "$HOME/.kube/"

until curl -s --fail http://kubernetes:10080/kubernetes-ready; do
      sleep 1;
    done
echo "Kubernetes ready - run tests!"

curl http://kubernetes:10080/config > "$HOME/.kube/config"
kubectl config set clusters.kind.server https://kubernetes:8443

kubectl get nodes
echo "Showing storageClass"
kubectl get storageclass
echo "Showing kube-system pods"
kubectl get -n kube-system pods

"$DIRNAME/docker/build.sh"

echo "Airflow environment on kubernetes is good to go!"
