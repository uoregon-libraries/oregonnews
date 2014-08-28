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
      $SOURCE/ $DESTORUPATH"
  echo $CMD
  $CMD
}

usage() {
  echo "Usage: $0 -s <source directory> [OPTION]..."
  echo "Ingest a batch of newspaper assets into chronam."
  echo
  echo "Syncs all non-TIFF files from the source directory, creates the oru/ symlink"
  echo "magic, and runs the django ingest process"
  echo
  echo "Mandatory arguments:"
  echo "  -s <source directory>     Specifies current archive of newspaper images"
  echo
  echo "Optional arguments:"
  echo "  -d <destination>          Uses custom destination directory instead of the"
  echo "                            default (/opt/chronam/data/batches)."
  echo "  -x <suffix>               Indicates destination suffix, usually ver01,"
  echo "                            ver02, or similar.  Defaults to 'ver01'."
  echo "  -l                        Runs live - for safety, running without -l will"
  echo "                            do a dry run"
  echo "  -f                        Forces syncing and ingesting even if the"
  echo "                            destination directory and/or symlink exist"
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
    echo "Suffix not specified, defaulting to 'ver01'"
    SUFFIX=ver01
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
}

check_destination_directories() {
  # -f flag allows directories to exist without being a fatal error
  EXITCMD="echo ABORTING; exit 1"
  if [[ "$FORCE" == 1 ]]; then
    EXITCMD="echo FORCE (-f) specified, continuing"
  fi

  if [[ -e $DESTORUPATH ]]; then
    echo "Destination batch path ($DESTORUPATH) already exists"
    $EXITCMD
  fi
  if [[ -e $DESTSYMPATH || -h $DESTSYMPATH ]]; then
    echo "Destination symlink path ($DESTSYMPATH) already exists"
    $EXITCMD
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
    echo "*** Dry run!  Specify -l to do a real sync and ingest."
  fi
}

create_oru_symlink() {
  CMDRM="rm -f $DESTSYMPATH"
  CMDLINK="ln -s ${DESTORUPATH%/} $DESTSYMPATH"
  echo $CMDRM
  echo $CMDLINK

  if [[ "$LIVE" != 1 ]]; then
    return
  fi

  $CMDRM
  $CMDLINK
}

ingest_into_chronam() {
  CMD="source /opt/chronam/ENV/bin/activate"
  echo $CMD

  # Allow unset vars, as the virtualenv script uses them heavily
  set +o nounset
  $CMD
  set -o nounset

  CMD="django-admin.py load_batch $DESTORUPATH --settings=chronam.settings"
  echo $CMD

  if [[ "$LIVE" == 1 ]]; then
    $CMD
  fi
}

main() {
  # Get vars set up, let user know about various defaults being used
  setup_live_run
  check_vars
  check_destination_directories

  # Run actual commands - add a blank line for easier reading
  echo
  make_destination_dir
  copy_files
  ingest_into_chronam
  create_oru_symlink
}

# Param-getting has to happen outside functions :(
SOURCE=
SUFFIX=
DEST=
VERBOSE=0
LIVE=0
FORCE=0

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

    f)
      FORCE=1
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
