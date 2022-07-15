#!/bin/bash



info_log() {
  # log informational messages to stdout
  echo "Info: ${BASH_SOURCE[0]} ${1}"
}

error_log() {
  # log error messages to stderr
  echo "Error: ${BASH_SOURCE[0]} ${1}" 1>&2
}

exit_with_error() {
  # log a message to stderr and exit 1
  error_log "${1}"
  exit 1
}

# input where to source the environment variables from
env_file=${1}

source_env_variables() {
  if [[ -f "${env_file}" ]]; then
    source $env_file
  else
    exit_with_error "Unable to source .env. See .env.sample for how to create this."
  fi
}

ensure_vars_are_set() {
  local var_names=("$@")
  local any_required_var_unset=false

  for var_name in "${var_names[@]}"; do
    if [[ -z "${!var_name}" ]]; then
      error_log "ERROR: ${var_name} is required but is not set"
      any_required_var_unset=true
    fi
  done

  if [[ "$any_required_var_unset" == true ]]; then
    exit_with_error "required environment variables were not set"
  fi

  network_name=$DEV_NETWORK_NAME
}


create_network_if_not_exists() {
  network_exists=$(docker network ls | grep "${network_name}")

  if [ -z "${network_exists}" ]; then
    info_log -n "Creating network ${network_name}..."
    docker network create "${network_name}" &>/dev/null
    info_log "Created network ${network_name}"
  fi
}


main() {
  info_log "start"
  source_env_variables
  ensure_vars_are_set DEV_NETWORK_NAME
  create_network_if_not_exists
  info_log "finished"
}

main