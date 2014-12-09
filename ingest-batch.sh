#!/bin/bash

# Runs ingest (and "reload" via purge + ingest) operations the "oregonnews
# way".  This script is very specific to our process:
#
# - We don't need TIFFs exposed to the web app, so before ingesting we rsync
#   all files except TIFFs from a network mount
# - We don't store our JP2s or other files in /opt/chronam/data/batches
#   directly; we instead store them on another network mount and symlink so
#   chronam can access them as needed
# - We use a version of chronam which seems to require a special subdirectory,
#   so we end up with two symlinks that may seem a little confusing:
#   - /opt/chronam/data/batches/[code]/[full batch name]/data, which symlinks
#     to the rsynced destination directory
#   - /opt/chronam/data/batches/[full batch name], which symlinks to
#     /opt/chronam/data/batches/[code]/[full batch name]
#   - ([code] is the institutional code, such as "oru")
#   - ([full batch name] is the full name of a batch with the suffix appended,
#     such as "batch_oru_foo_ver01")
# - We always purge the cache after ingest instead of letting it expire on its
#   own, preferring to have live data immediately
#
# That said, this could easily be tweaked for other use cases, and is
# especially useful for keeping the size of the web-mounted discs at a minimum
# by skipping TIFFs.
#
# This script defaults to a dry run for safety (because, yes, I don't trust
# myself).  This script uses rsync to copy all files except TIFFs, creates
# necessary directories / symlinks in /opt/chronam, and runs the django
# administration task(s) for ingest, purge, and cache purge.

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
  echo "  -p                        Purge the batch before reloading it"
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
  local batchnoprefix=${BATCHNAME#*_}
  local batch_data_dir_name=${batchnoprefix%_*}

  # Figure out chronam paths for creating symlinks and dirs
  DEST=$DEST/$BATCHNAME
  BATCHSUBDIRPATH="$BATCHPATH/$batch_data_dir_name/${BATCHNAME}_$SUFFIX"
  BATCHSYMLINK=$BATCHPATH/${BATCHNAME}_$SUFFIX
  BATCHDATAPATH=$BATCHSUBDIRPATH/data
}

# Deletes symlinks and empty directory, and runs django purge task
purge_batch_dirs_and_data() {
  # Throw errors if destination *doesn't* exist
  if [[ ! -e $DEST ]]; then
    echo "FATAL: rsync destination ($DEST) doesn't exist!  Nothing to purge!"
    exit 1
  fi

  # If any of these don't exist, we just ignore it - a batch may need to be
  # purged due to a bad load that didn't get around to dirs/symlinks
  if_live rm -f $BATCHSYMLINK
  if_live rm -f $BATCHDATAPATH
  if_live rmdir $BATCHSUBDIRPATH || true

  # Run the purge script to clean up solr/mysql
  if_live django-admin.py purge_batch ${BATCHNAME}_$SUFFIX --settings=chronam.settings
}

check_destination_paths() {
  local errors=0

  if [[ -e $DEST ]]; then
    echo "WARNING: rsync destination ($DEST) already exists"
  fi

  if [[ -e $BATCHSUBDIRPATH ]]; then
    echo "FATAL: Batch path ($BATCHSUBDIRPATH) already exists"
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

make_batch_subdirectory() {
  if_live mkdir -p $BATCHSUBDIRPATH
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
  if_live ln -s $BATCHSUBDIRPATH $BATCHSYMLINK
}

ingest_into_chronam() {
  if_live django-admin.py load_batch $BATCHSUBDIRPATH --settings=chronam.settings
}

move_logs() {
  if_live mv *.log /var/log/chronam/
}

expire_cache() {
  if_live django-admin.py purge_django_cache --settings=chronam.settings
}

main() {
  # Allow unset vars, as the virtualenv script uses them heavily
  set +o nounset
  if_live source /opt/chronam/ENV/bin/activate
  set -o nounset

  setup_live_run
  check_required_vars
  setup_path_vars

  # Run the purge before the path verification so we only have to branch once
  if [[ "$PURGE_RELOAD" == 1 ]]; then
    purge_batch_dirs_and_data
  fi

  check_destination_paths

  # Run actual commands - add a blank line for easier reading
  echo

  copy_files
  make_batch_subdirectory
  create_symlinks
  ingest_into_chronam
  move_logs
  expire_cache
}

# Param-getting has to happen outside functions :(
SOURCE=
SUFFIX=
DEST=
VERBOSE=0
LIVE=0
PURGE_RELOAD=0

# Default locations for symlinking the batch after rsync
BATCHPATH=/opt/chronam/data/batches

while getopts ":s:x:d:plhv" opt; do
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

    p)
      PURGE_RELOAD=1
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
