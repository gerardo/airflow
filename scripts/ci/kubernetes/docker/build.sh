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

set -ex

# Using the docker daemon running in the kubernetes cluster
export DOCKER_HOST=tcp://kubernetes:2375

IMAGE=${IMAGE:-airflow}
TAG=${TAG:-latest}
DIRNAME=$(cd "$(dirname "$0")"; pwd)
AIRFLOW_ROOT="$DIRNAME/../../../.."

echo "Airflow directory $AIRFLOW_ROOT"
echo "Airflow Docker directory $DIRNAME"

cd $AIRFLOW_ROOT

python setup.py compile_assets sdist -q
sudo rm -rf ${AIRFLOW_ROOT}/airflow/www/node_modules

echo "Copy distro $AIRFLOW_ROOT/dist/*.tar.gz ${DIRNAME}/airflow.tar.gz"
cp $AIRFLOW_ROOT/dist/*.tar.gz ${DIRNAME}/airflow.tar.gz
cd $DIRNAME && docker build --pull $DIRNAME --tag=${IMAGE}:${TAG}
rm $DIRNAME/airflow.tar.gz
