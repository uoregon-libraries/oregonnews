#!/bin/bash
set -eu

copy_files() {
  # Remove trailing slashes because I like rsyncing with explicit full paths
  local source=${1%/}
  local dest=${2%/}
  local live=$3

  if [[ "$live" == 1 ]]; then
    local rsyncargs="-va"
  else
    local rsyncargs="-van"
  fi

  echo "rsyncing from '$source' to '$dest'"

  rsync $rsyncargs --delete \
      --exclude=*.tif \
      --exclude=*.tiff \
      --exclude=*.TIF \
      --exclude=*.TIFF \
      $source $dest
}

usage() {
  echo "Usage: $0 -s <source directory> [-d <destination directory>] [-l]"
}

check_vars() {
  # Can't run without a source dir
  if [[ -z ${SOURCE:-} ]]; then
    echo "Source directory not specified!"
    echo
    usage
    exit 1
  fi

  # Without destination, we assume the standard chronam batch dir
  if [[ -z ${DEST:-} ]]; then
    DEST=/opt/chronam/data/batches
    echo "Defaulting destination to '$DEST'"
  fi
}

make_destination_dir() {
  mkdir -p $DEST
}

setup_live_run() {
  if [[ -z ${LIVE:-} ]]; then
    LIVE=0
  fi

  if [[ "$LIVE" != 1 ]]; then
    LIVE=0
    echo "Dry run!  Specify LIVE=1 to do a real sync and ingest."
    echo
  fi
}

main() {
  check_vars
  make_destination_dir
  setup_live_run
  copy_files $SOURCE $DEST $LIVE
}

# Param-getting has to happen outside functions :(
SOURCE=
DEST=
LIVE=0

while getopts ":s:d:lh" opt; do
  case $opt in
    s)
      SOURCE=$OPTARG
      ;;

    d)
      DEST=$OPTARG
      ;;

    l)
      LIVE=1
      ;;

    h)
      usage
      exit 0
  esac
done

main
