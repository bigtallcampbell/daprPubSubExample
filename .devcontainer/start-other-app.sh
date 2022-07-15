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


start_other_app_if_not_started(){
  container_exists=$(docker container ls -a --format="{{json .}}" | jq 'select( (.Names=="other-app"))')

  if [ -n "${container_exists}" ]; then
    info_log -n "Stopping old other-app instance..."
    docker container rm other-app --force
    info_log "Old other-app instance stopped"
  fi

  container_exists=$(docker container ls -a --format="{{json .}}" | jq 'select( (.Names=="other-app-sidecar"))')

  if [ -n "${container_exists}" ]; then
    info_log -n "Stopping old other-app instance..."
    docker container rm other-app-sidecar --force
    info_log "Old other-app instance stopped"
  fi

    info_log -n "Starting router container..."
    docker run -d -it --name other-app --network devVNet ubuntu:latest
    docker run -d -it --name other-app-sidecar --network container:other-app daprsidecar:latest -app-id other
    info_log "Router container started"

}

main() {
  info_log "start"
  start_other_app_if_not_started
  info_log "finished"
}

main