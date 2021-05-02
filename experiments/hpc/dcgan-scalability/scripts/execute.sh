#!/bin/bash

set -o nounset
set -o pipefail

source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/feedback.sh")

SCRIPTS_DIR_PATH=$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || throw_error "It was not possible to find scripts dir" ; pwd -P)
EXPERIMENT_DIR_PATH=$(dirname "${SCRIPTS_DIR_PATH}")
IMAGE="${1:-experiment:dcgan-scalability}"

TEXT_BOLD=$(tput bold)
TEXT_COLORIZED=$(tput setaf 2) # Green
TEXT_RESET=$(tput sgr0)

function main {
  log_in_category "Execute" "Starting experiment"

  execute_trial_one
  execute_trial_two
  execute_trial_three
  execute_trial_four
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

function execute_trial_one {
  log_in_category "Trial 1" "Starting trial"

  trial_number="1"
  number_of_processes="1"

  execute_trial "${trial_number}" "${number_of_processes}"
}

function execute_trial_two {
  log_in_category "Trial 2" "Starting trial"
}

function execute_trial_three {
  log_in_category "Trial 3" "Starting trial"
}

function execute_trial_four {
  log_in_category "Trial 4" "Starting trial"
}

function execute_trial {
  trial_number=$1
  number_of_processes=$2
  batch_size=${3:-32}

  log_in_category "Trial ${trial_number}" "Executing trial with ${number_of_processes} processes and ${batch_size} samples"

  dcgan_dir_path="${EXPERIMENT_DIR_PATH}/dcgan"
  pushd "${dcgan_dir_path}"

  echo $dcgan_dir_path

  docker run \
    -d \
    --env OMP_NUM_THREADS=1 \
    --rm --network=host \
    -v="${dcgan_dir_path}":/root \
    "${IMAGE}" \
    python -m torch.distributed.launch \
      --nproc_per_node="${number_of_processes}" \
      --nnodes=2 \
      --node_rank=0 \
      --master_addr="172.17.0.1" \
      --master_port=1234 \
      dist_dcgan.py \
        --batch_size="${batch_size}" \
        --dataset cifar10 \
        --dataroot ./data

  time docker run \
    --env OMP_NUM_THREADS=1 \
    --rm --network=host \
    -v="${dcgan_dir_path}":/root \
    "${IMAGE}" \
    python -m torch.distributed.launch \
      --nproc_per_node="${number_of_processes}" \
      --nnodes=2 \
      --node_rank=1 \
      --master_addr="172.17.0.1" \
      --master_port=1234 \
      dist_dcgan.py \
        --batch_size="${batch_size}" \
        --dataset cifar10 \
        --dataroot ./data

  popd
}

main "${@}"