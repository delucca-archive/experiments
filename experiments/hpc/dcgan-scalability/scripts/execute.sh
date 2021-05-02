#!/bin/bash

set -o nounset
set -o pipefail

source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/feedback.sh")

SCRIPTS_DIR_PATH=$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || throw_error "It was not possible to find scripts dir" ; pwd -P)
EXPERIMENT_DIR_PATH=$(dirname "${SCRIPTS_DIR_PATH}")
DCGAN_DIR_PATH="${EXPERIMENT_DIR_PATH}/dcgan"
LOG_FILE_PATH="${EXPERIMENT_DIR_PATH}/execution-time-report.log"
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

  trial_number="2"
  number_of_processes="2"

  execute_trial "${trial_number}" "${number_of_processes}"
}

function execute_trial_three {
  log_in_category "Trial 3" "Starting trial"

  trial_number="3"
  number_of_processes="4"

  execute_trial "${trial_number}" "${number_of_processes}"
}

function execute_trial_four {
  log_in_category "Trial 4" "Starting trial"

  trial_number="4"
  number_of_processes="8"

  execute_trial "${trial_number}" "${number_of_processes}"
}

function execute_trial {
  trial_number=$1
  number_of_processes=$2
  batch_size=${3:-32}
  number_of_samples=${4:-3}
  number_of_epochs=${5:-1}

  cat <<EOF >> $LOG_FILE_PATH
TRIAL $trial_number
- Started at: $(date)
- Number of processes: $number_of_processes
- Batch size: $batch_size
- Number of samples: $number_of_samples
===================================================================================================
EOF

  for sample_number in $(seq 1 "${number_of_samples}"); do
    execute_trial_sample $trial_number $sample_number $number_of_processes $number_of_epochs
  done
}

function execute_trial_sample {
  trial_number=$1
  sample_number=$2
  number_of_processes=$3
  batch_size=${4:-32}
  number_of_epochs=${5:1}

  log_in_category "Trial ${trial_number}" "Executing sample ${sample_number} with ${number_of_processes} processes and batch size of ${batch_size}"
  cat <<EOF >> $LOG_FILE_PATH
SAMPLE $sample_number
- Started at: $(date)
---------------------------------------------------------------------------------------------------
EOF

  pushd "${DCGAN_DIR_PATH}"

  docker run \
    -d \
    --env OMP_NUM_THREADS=1 \
    --rm --network=host \
    -v="${DCGAN_DIR_PATH}":/root \
    "${IMAGE}" \
    python -m torch.distributed.launch \
      --nproc_per_node="${number_of_processes}" \
      --nnodes=2 \
      --node_rank=0 \
      --master_addr="172.17.0.1" \
      --master_port=1234 \
      dist_dcgan.py \
        --dataset cifar10 \
        --dataroot ./data \
        --batch_size "${batch_size}" \
	--num_epochs "${number_of_epochs}

  { time docker run \
    --env OMP_NUM_THREADS=1 \
    --rm --network=host \
    -v="${DCGAN_DIR_PATH}":/root \
    "${IMAGE}" \
    python -m torch.distributed.launch \
      --nproc_per_node="${number_of_processes}" \
      --nnodes=2 \
      --node_rank=1 \
      --master_addr="172.17.0.1" \
      --master_port=1234 \
      dist_dcgan.py \
        --dataset cifar10 \
        --dataroot ./data \
        --batch_size "${batch_size}" \
	--num_epochs "${number_of_epochs}" ; } 2>> $LOG_FILE_PATH

  popd

  cat <<EOF >> $LOG_FILE_PATH

---------------------------------------------------------------------------------------------------
EOF

  stop_running_containers
}

function stop_running_containers {
  log_in_category "Execute" "Stopping running containers"

  docker kill $(docker ps -q)
}

main "${@}"
