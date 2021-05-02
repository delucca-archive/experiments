#!/bin/bash

set -o nounset
set -o pipefail

source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/feedback.sh")

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

main "${@}"