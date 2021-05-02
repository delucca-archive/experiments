#!/bin/bash

set -o nounset
set -o pipefail

GIT_HEAD_REVISION=$(git rev-parse HEAD)

function log_basic_settings {
  log_hardware_details
  log_env_variables
  log_setting "Git HEAD revision" "${GIT_HEAD_REVISION}"
}

function log_hardware_details {
  log_setting "Hardware details"

  inxi -Fxz 2> /dev/null
}

function log_env_variables {
  log_setting "Environment variables"

  env_variable_keys=$(env -v0 | cut -z -f1 -d= | tr '\0' '\n' | sort)
  variables_to_hide="_ GITHUB_CODESPACE_TOKEN GITHUB_TOKEN GIT_COMMITTER_EMAIL GIT_COMMITTER_NAME"

  for env_var in $env_variable_keys; do
    [[ ${variables_to_hide} != *"${env_var}"* ]] && eval "echo \">    ${env_var}=\$${env_var}\""
  done
}

function log_setting {
  label=$1
  setting=${2:-""}

  echo "> ${TEXT_BOLD}${label}:${TEXT_RESET} ${setting}"
}