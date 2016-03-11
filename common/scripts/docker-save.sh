#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2005-2015 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}/base.sh"

function showUsageAndExit () {
    echoError "Insufficient or invalid options provided!"
    echoBold "Usage: ./save.sh -v [product-version] -i [docker-image-version] [OPTIONAL] -l [product_profile_list]"
    echo "eg: ./save.sh -v 1.9.1 -i 1.0.0 -l 'default|worker|manager'"
    exit 1
}

while getopts :n:v:i:l: FLAG; do
    case $FLAG in
        n)
            product_name=$OPTARG
            ;;
        v)
            product_version=$OPTARG
            ;;
        i)
            image_version=$OPTARG
            ;;
        l)
            product_profiles=$OPTARG
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

# Validate mandatory args
if [ -z "$product_version" ]
  then
    showUsageAndExit
fi

if [ -z "$image_version" ]
  then
    showUsageAndExit
fi

if [ -z "$product_profiles" ]
  then
    product_profiles='default'
fi

IFS='|' read -r -a array <<< "${product_profiles}"
for profile in "${array[@]}"
do
    if [[ $profile = "default" ]]; then
        image_id="wso2/${product_name}-${product_version}:${image_version}"
        tar_file="wso2${product_name}-${product_version}-${image_version}.tar"
    else
        image_id="wso2/${product_name}-${profile}-${product_version}:${image_version}"
        tar_file="wso2${product_name}-${profile}-${product_version}-${image_version}.tar"
    fi

    echo "Saving docker image ${image_id} to ${HOME}/docker/images/${tar_file}"
    mkdir -p "${HOME}/docker/images/"
    docker save "${image_id}" > "${HOME}/docker/images/${tar_file}"

    echoSuccess "Docker image ${image_id} saved to ${HOME}/docker/images/${tar_file}."
done
