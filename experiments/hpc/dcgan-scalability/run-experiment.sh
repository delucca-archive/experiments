#!/bin/bash

set -o nounset
set -o pipefail

function main {
  echo "Running experiment"

  scripts/prepare.sh
  scripts/execute.sh
  scripts/cleanup.sh
}

main "${@}"