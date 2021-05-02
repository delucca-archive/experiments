#!/bin/bash

set -o nounset
set -o pipefail

source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/feedback.sh")

SCRIPTS_DIR_PATH=$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || throw_error "It was not possible to find scripts dir" ; pwd -P)
EXPERIMENT_DIR_PATH=$(dirname "${SCRIPTS_DIR_PATH}")

TEXT_BOLD=$(tput bold)
TEXT_COLORIZED=$(tput setaf 5) # Magenta
TEXT_RESET=$(tput sgr0)

function main {
  log_in_category "Prepare" "Preparing experiment"

  get_input_data
  get_source_code
  refresh_docker_image
}

function log_in_category {
  category=$1
  text=$2

  echo "$(highlight "${category}:") ${text}"
}

function highlight {
  text=$1

  echo "${TEXT_BOLD}${TEXT_COLORIZED}${text}${TEXT_RESET}"
}

function get_input_data {
  log_in_category "Prepare" "Getting input data"

  data_dir_path="${EXPERIMENT_DIR_PATH}/data"
  rm -rf "${data_dir_path}" && mkdir -p "${data_dir_path}" || throw_error "Cannot create data dir"
  wget --no-check-certificate https://www.cs.toronto.edu/~kriz/cifar-10-python.tar.gz -O - \
    | tar -xvz -C "${EXPERIMENT_DIR_PATH}/data" --strip-components=1 \
    || throw_error "Cannot fetch CIFAR-10 dataset"
}

function get_source_code {
  log_in_category "Prepare" "Getting DCGAN source code"

  src_dir_path="src"
  if [ ! -d "${src_dir_path}"]; then
    git clone git@github.com:otavioon/Distributed-DCGAN.git "${data_dir_path}" || throw_error "Cannot clone de DCGAN repository"
  else
    pushd "${src_dir_path}"
    git pull
    popd
  fi
}

function refresh_docker_image {
  log_in_category "Prepare" "Refreshing experiment Docker image"
}

main "${@}"