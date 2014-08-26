#!/bin/bash
set -eu

copy_files() {
  # Remove trailing slashes because I like rsyncing with explicit full paths
  SOURCE=${SOURCE%/}
  DEST=${DEST%/}

  echo "rsyncing from '$SOURCE' to '$DEST'"

  rsync -av --delete \
      --exclude=*.tif \
      --exclude=*.tiff \
      --exclude=*.TIF \
      --exclude=*.TIFF \
      $SOURCE $DEST
}

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

copy_files
