#!/bin/bash
set -eu

usage() {
  echo "Usage: $0 -s <source directory> -d <destination directory> [OPTION]..."
  echo "Ingest a batch of newspaper assets into chronam."
  echo
  echo "Syncs all non-TIFF files from the source directory and ingests into chronam"
  echo
  echo "Mandatory arguments:"
  echo "  -s <source directory>     Specifies the source batch directory"
  echo "  -d <destination>          Specifies destination directory to rsync non-tiff"
  echo "                            files (batch name isn't specified here)"
  echo
  echo "Optional arguments:"
  echo "  -x <suffix>               Indicates destination suffix, usually ver01,"
  echo "                            ver02, or similar.  Defaults to 'ver01'."
  echo "  -l                        Runs live - for safety, running without -l will"
  echo "                            do a dry run"
  echo "  -v                        Extra verbosity"
  echo "  -h                        Show this help"
}

setup_live_run() {
  if [[ -z ${LIVE:-} ]]; then
    LIVE=0
  fi

  if [[ "$LIVE" != 1 ]]; then
    LIVE=0
    echo "*** Dry run!  Specify -l to do a real sync and ingest."
  fi
}

check_required_vars() {
  local errors=0

  # Can't run without a source dir
  if [[ -z ${SOURCE:-} ]]; then
    echo "Source directory not specified!"
    let errors=errors+1
  fi

  # Can't run without a destination dir
  if [[ -z ${DEST:-} ]]; then
    echo "Destination directory not specified!"
    let errors=errors+1
  fi

  # If suffix isn't specified, we have to set a default
  if [[ -z ${SUFFIX:-} ]]; then
    echo "Suffix not specified, defaulting to 'ver01'"
    SUFFIX=ver01
  fi

  if (( errors > 0 )); then
    echo
    usage
    exit 1
  fi
}

setup_path_vars() {
  # Make sure we have no trailing slashes
  SOURCE=${SOURCE%/}
  DEST=${DEST%/}

  # Extract batch name - only works if SOURCE doesn't have a trailing slash
  BATCHNAME=${SOURCE##*/}

  # Figure out chronam paths for creating symlinks and dirs
  DEST=$DEST/$BATCHNAME
  BATCHORUPATH=$ORUPATH/${BATCHNAME}_$SUFFIX
  BATCHSYMLINK=$BATCHPATH/${BATCHNAME}_$SUFFIX
  BATCHDATAPATH=$BATCHORUPATH/data
}

check_destination_paths() {
  local errors=0

  if [[ -e $DEST ]]; then
    echo "WARNING: rsync destination ($DEST) already exists"
  fi

  if [[ -e $BATCHORUPATH ]]; then
    echo "Batch path ($BATCHORUPATH) already exists"
    let errors=errors+1
  fi

  if [[ -e $BATCHSYMLINK ]]; then
    echo "Batch symlink path ($BATCHSYMLINK) already exists"
    let errors=errors+1
  fi

  if [[ -e $BATCHDATAPATH ]]; then
    echo "Batch data path ($BATCHDATAPATH) already exists"
    let errors=errors+1
  fi

  # -f flag allows directories to exist without being a fatal error
  if (( "$errors" > 0 )); then
    echo ABORTING
    exit 1
  fi
}

make_batch_oru_directory() {
  CMD="mkdir -p $BATCHORUPATH"
  echo $CMD

  if [[ "$LIVE" != 1 ]]; then
    return
  fi

  $CMD
}

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
      $SOURCE/ $DEST"
  echo $CMD
  $CMD
}

create_symlinks() {
  CMD="ln -s $DEST $BATCHDATAPATH"
  echo $CMD
  if [[ "$LIVE" == 1 ]]; then
    $CMD
  fi

  CMD="ln -s $BATCHORUPATH $BATCHSYMLINK"
  echo $CMD
  if [[ "$LIVE" == 1 ]]; then
    $CMD
  fi
}

ingest_into_chronam() {
  CMD="source /opt/chronam/ENV/bin/activate"
  echo $CMD

  # Allow unset vars, as the virtualenv script uses them heavily
  set +o nounset
  $CMD
  set -o nounset

  CMD="django-admin.py load_batch $BATCHORUPATH --settings=chronam.settings"
  echo $CMD

  if [[ "$LIVE" == 1 ]]; then
    $CMD
  fi
}

main() {
  setup_live_run
  check_required_vars
  setup_path_vars
  check_destination_paths

  # Run actual commands - add a blank line for easier reading
  echo

  make_batch_oru_directory
  copy_files
  create_symlinks
  ingest_into_chronam
}

# Param-getting has to happen outside functions :(
SOURCE=
SUFFIX=
DEST=
VERBOSE=0
LIVE=0

# Default locations for symlinking the batch after rsync
BATCHPATH=/opt/chronam/data/batches
ORUPATH=$BATCHPATH/oru

while getopts ":s:x:d:lfhv" opt; do
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
