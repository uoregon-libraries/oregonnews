#!/bin/bash
set -eu

copy_files() {
  local rsyncargs="-a"

  if [[ "$LIVE" != 1 ]]; then
    rsyncargs="${rsyncargs}n"
  fi

  if [[ "$VERBOSE" == 1 ]]; then
    rsyncargs="${rsyncargs}v"
  fi

  echo "rsyncing from '$SOURCE' to '$ORUDIR'"

  rsync $rsyncargs --delete \
      --exclude=*.tif \
      --exclude=*.tiff \
      --exclude=*.TIF \
      --exclude=*.TIFF \
      $SOURCE $ORUDIR
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

  # Make sure we have no trailing slashes
  SOURCE=${SOURCE%/}
  DEST=${DEST%/}

  # Extract batch name - only works if SOURCE doesn't have a trailing slash
  BATCHNAME=${SOURCE##*/}

  # ORU directory is forced for now
  ORUDIR=$DEST/oru
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
    echo "Dry run!  Specify -l to do a real sync and ingest."
    echo
  fi
}

create_oru_symlink() {
  local symsource=$ORUDIR/$BATCHNAME
  local symdest=$DEST/$BATCHNAME
  CMD="ln -s $symsource $symdest"
  echo "Creating symlink: '$CMD'"

  if [[ "$LIVE" != 1 ]]; then
    return
  fi

  if [[ -e $symdest ]]; then
    echo "Can't create symlink; $symdest already exists!"
    return
  fi

  $CMD
}

main() {
  check_vars
  make_destination_dir
  setup_live_run
  copy_files
  create_oru_symlink
}

# Param-getting has to happen outside functions :(
SOURCE=
DEST=
VERBOSE=0
LIVE=0

while getopts ":s:d:lhv" opt; do
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

    v)
      VERBOSE=1
      ;;

    h)
      usage
      exit 0
  esac
done

main
