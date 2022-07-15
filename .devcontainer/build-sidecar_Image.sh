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

create_sidecar_image_if_not_exists() {
  sidecar_exists=$(docker image ls --format="{{json .}}" | jq 'select( (.Repository=="daprsidecar") and (.Tag="latest"))')

  if [ -z "${sidecar_exists}" ]; then
    info_log -n "Creating sidecar image..."
    docker build --tag daprsidecar -f ./sidecar/Dockerfile.sidecar ./sidecar

    info_log "Created sidecar image"
  fi
}


main() {
  info_log "start"
  create_sidecar_image_if_not_exists
  info_log "finished"
}

main