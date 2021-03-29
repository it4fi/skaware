#!/usr/bin/env bash

set -e

HASHES_DIR="$PWD/hashes"
[ -d $HASHES_DIR ] || { echo "WRONG PWD $PWD"; exit 1; }
echo "- HASHES_DIR $HASHES_DIR"

DL_DIR=${1:-"$HOME/Downloads"}
[ -d $DL_DIR ] || { echo "WRONG DL_DIR $DL_DIR"; exit 1; }
echo "- DL_DIR $DL_DIR"

cd $DL_DIR
for a in *.tar.gz; do
  ARCHIVES="$ARCHIVES $a"
done
echo "- ARCHIVES '$ARCHIVES'"

REMOTE_ACCOUNT=${2:-'ubuntu@ubuntu'}
ssh $REMOTE_ACCOUNT '{ rm -rf tmp; mkdir tmp; }'
scp $ARCHIVES $REMOTE_ACCOUNT:tmp/
ssh $REMOTE_ACCOUNT '{ cd tmp;for a in *; do sha1sum -b $a > $a.sha1;done; }'
scp $REMOTE_ACCOUNT:tmp/*.sha1 $HASHES_DIR/
