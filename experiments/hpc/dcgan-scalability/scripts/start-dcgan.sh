#!/bin/bash

set -o nounset
set -o pipefail

function main {
  prepare
  execute
  clean_up
}

# PREPARE
# -------------------------------------------------------------------------------------------------
function prepare {
  echo "Prepare"
}

# EXECUTE
# -------------------------------------------------------------------------------------------------
function execute {
  echo "Execute"
}

# CLEAN UP
# -------------------------------------------------------------------------------------------------
function clean_up {
  echo "Clean up"
}

main "${@}"