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

  echo "rsyncing from '$SOURCE' to '$DESTORUPATH'"

  rsync $rsyncargs --delete \
      --exclude=*.tif \
      --exclude=*.tiff \
      --exclude=*.TIF \
      --exclude=*.TIFF \
      $SOURCE $DESTORUPATH
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

  DESTORUPATH=$DEST/oru/$BATCHNAME/
  DESTSYMPATH=$DEST/$BATCHNAME

  # Check destination directories
  if [[ -e $DESTORUPATH ]]; then
    echo "Destination batch path ($DESTORUPATH) already exists; exiting"
    exit 1
  fi
  if [[ -e $DESTSYMPATH ]]; then
    echo "Destination symlink path ($DESTSYMPATH) already exists; exiting"
    exit 1
  fi
}

make_destination_dir() {
  mkdir -p $DESTORUPATH
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
  CMD="ln -s $DESTORUPATH $DESTSYMPATH"
  echo "Creating symlink: '$CMD'"

  if [[ "$LIVE" != 1 ]]; then
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
