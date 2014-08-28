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

  # There's value in running this when not live since rsync has its own dry-run
  # flag that lets you see the expected outcome
  CMD="rsync $rsyncargs --delete \
      --exclude=*.tif \
      --exclude=*.tiff \
      --exclude=*.TIF \
      --exclude=*.TIFF \
      $SOURCE $DESTORUPATH"
  echo $CMD
  $CMD
}

usage() {
  echo "Usage: $0 -s <source directory> -x <suffix> [OPTION]..."
  echo "Ingest a batch of newspaper assets into chronam."
  echo
  echo "Syncs all non-TIFF files from the source directory, creates the oru/ symlink"
  echo "magic, and runs the django ingest process"
  echo
  echo "Mandatory arguments:"
  echo "  -s <source directory>     Specifies current archive of newspaper images"
  echo "  -x <suffix>               Indicates destination suffix, usually ver_01,"
  echo "                            ver_02, or similar"
  echo
  echo "Optional arguments:"
  echo "  -d <destination>          Uses custom destination directory instead of the"
  echo "                            default (/opt/chronam/data/batches)."
  echo "  -l                        Runs live - for safety, running without -l will"
  echo "                            do a dry run"
  echo "  -v                        Extra verbosity"
  echo "  -h                        Show this help"
}

check_vars() {
  # Can't run without a source dir
  if [[ -z ${SOURCE:-} ]]; then
    echo "Source directory not specified!"
    echo
    usage
    exit 1
  fi

  # Suffix is required
  if [[ -z ${SUFFIX:-} ]]; then
    echo "Suffix not specified!"
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

  DESTORUPATH=$DEST/oru/${BATCHNAME}_$SUFFIX
  DESTSYMPATH=$DEST/${BATCHNAME}_$SUFFIX

  # Check destination directories
  if [[ -e $DESTORUPATH ]]; then
    echo "Destination batch path ($DESTORUPATH) already exists; exiting"
    exit 1
  fi
  if [[ -e $DESTSYMPATH || -h $DESTSYMPATH ]]; then
    echo "Destination symlink path ($DESTSYMPATH) already exists; exiting"
    exit 1
  fi
}

make_destination_dir() {
  CMD="mkdir -p $DESTORUPATH"
  echo $CMD

  if [[ "$LIVE" != 1 ]]; then
    return
  fi

  $CMD
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
  CMD="ln -s ${DESTORUPATH%/} $DESTSYMPATH"
  echo $CMD

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
SUFFIX=
DEST=
VERBOSE=0
LIVE=0

while getopts ":s:x:d:lhv" opt; do
  case $opt in
    s)
      SOURCE=$OPTARG
      ;;

    x)
      SUFFIX=$OPTARG
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
