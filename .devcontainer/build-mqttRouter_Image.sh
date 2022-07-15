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

create_router_image_if_not_exists() {
  image_exists=$(docker image ls --format="{{json .}}" | jq 'select( (.Repository=="mqttrouter") and (.Tag="latest"))')

  if [ -z "${image_exists}" ]; then
    info_log -n "Creating sidecar image..."
    docker build --tag mqttrouter -f ./mqttRouter/Dockerfile ./mqttRouter
    info_log "Created sidecar image"
  fi
}

start_router_if_not_started(){
  container_exists=$(docker container ls -a --format="{{json .}}" | jq 'select( (.Image=="mqttrouter:latest"))')

  if [ -n "${container_exists}" ]; then
    info_log -n "Stopping old router instance..."
    docker container rm $MQTT_ROUTER_CONTAINER_NAME --force
    info_log "Old router instance stopped"
  fi

    info_log -n "Starting router container..."
    docker run -d -id -p 5672:5672 --restart=unless-stopped --name $MQTT_ROUTER_CONTAINER_NAME --network $DEV_NETWORK_NAME --network-alias $DEV_NETWORK_NAME mqttrouter:latest
    info_log "Router container started"

}


main() {
  info_log "start"
  source_env_variables
  ensure_vars_are_set DEV_NETWORK_NAME MQTT_ROUTER_CONTAINER_NAME
  create_router_image_if_not_exists
  start_router_if_not_started
  info_log "finished"
}

main