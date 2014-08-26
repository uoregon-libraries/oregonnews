#!/bin/bash
set -eu

copy_files() {
  # Remove trailing slashes because I like rsyncing with explicit full paths
  SOURCE=${SOURCE%/}
  DEST=${DEST%/}

  if [[ "$LIVE" == 1 ]]; then
    local rsyncargs="-va"
  else
    local rsyncargs="-van"
  fi

  echo "rsyncing from '$SOURCE' to '$DEST'"

  rsync $rsyncargs --delete \
      --exclude=*.tif \
      --exclude=*.tiff \
      --exclude=*.TIF \
      --exclude=*.TIFF \
      $SOURCE $DEST
}

check_vars() {
  # Can't run without a source dir
  if [[ -z "$SOURCE" ]]; then
    echo "SOURCE must be specified"
    exit 1
  fi

  # Without destination, we assume the standard chronam batch dir
  if [[ -z ${DEST+1} ]]; then
    DEST=/opt/chronam/data/batches
    echo "Defaulting destination to '$DEST'"
  fi
}

setup_live_run() {
  if [[ -z ${LIVE+1} ]]; then
    LIVE=0
  fi

  if [[ "$LIVE" != 1 ]]; then
    LIVE=0
    echo "Dry run!  Specify LIVE=1 to do a real sync and ingest."
    echo
  fi
}

setup_live_run
check_vars
copy_files
