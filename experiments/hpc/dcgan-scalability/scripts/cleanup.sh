#!/bin/bash

set -o nounset
set -o pipefail

TEXT_BOLD=$(tput bold)
TEXT_COLORIZED=$(tput setaf 3) # Yellow
TEXT_RESET=$(tput sgr0)

function main {
  log_in_category "Cleanup" "Cleaning up experiment"

  stop_running_containers
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

function stop_running_containers {
  log_in_category "Cleanup" "Stopping running containers"

  docker kill $(docker ps -q)
}

main "${@}"