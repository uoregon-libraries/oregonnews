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
  echo
  echo
  echo "Examples:"
  echo
  echo "    ./ingest-batch.sh -l -s /mnt/newsarchive/batch_oru_xxx -d /mnt/destination"
  echo
  echo "This would take a batch called 'xxx', rsync it to /mnt/destination/ (in the"
  echo "'batch_oru_xxx' sub-directory), and then ingest it into chronam."
  echo
  echo
  echo "    ./ingest-batch.sh -s /mnt/newsarchive/batch_oru_xxx -d /mnt/destination"
  echo
  echo "Dry run of the above command (note the lack of a '-l' option)"
  echo
  echo
  echo "    ./ingest-batch.sh -l -s /mnt/newsarchive/batch_oru_xxx -d /mnt/destination -x ver02"
  echo
  echo "Same as above, but the internal sub-directory for chronam will have _ver02 for"
  echo "a suffix, i.e., '/opt/chronam/data/batches/batch_oru_xxx_ver02'."
}

if_live() {
  # Grab all args as a single command
  local cmd="$@"

  echo $cmd
  if [[ "$LIVE" == 1 ]]; then
    $cmd
  fi
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
    echo "FATAL: Batch path ($BATCHORUPATH) already exists"
    let errors=errors+1
  fi

  if [[ -e $BATCHSYMLINK ]]; then
    echo "FATAL: Batch symlink path ($BATCHSYMLINK) already exists"
    let errors=errors+1
  fi

  if [[ -e $BATCHDATAPATH ]]; then
    echo "FATAL: Batch data path ($BATCHDATAPATH) already exists"
    let errors=errors+1
  fi

  # -f flag allows directories to exist without being a fatal error
  if (( "$errors" > 0 )); then
    echo ABORTING
    exit 1
  fi
}

make_batch_oru_directory() {
  if_live mkdir -p $BATCHORUPATH
}

copy_files() {
  local rsyncargs="-a"

  # rsync has its own cool dry-run stuff, so we don't use if_live here
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
  if_live ln -s $DEST $BATCHDATAPATH
  if_live ln -s $BATCHORUPATH $BATCHSYMLINK
}

ingest_into_chronam() {
  if_live django-admin.py load_batch $BATCHORUPATH --settings=chronam.settings
}

move_logs() {
  if_live mv *.log /var/log/chronam/
}

main() {
  # Allow unset vars, as the virtualenv script uses them heavily
  set +o nounset
  if_live source /opt/chronam/ENV/bin/activate
  set -o nounset

  setup_live_run
  check_required_vars
  setup_path_vars
  check_destination_paths

  # Run actual commands - add a blank line for easier reading
  echo

  copy_files
  make_batch_oru_directory
  create_symlinks
  ingest_into_chronam
  move_logs
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
