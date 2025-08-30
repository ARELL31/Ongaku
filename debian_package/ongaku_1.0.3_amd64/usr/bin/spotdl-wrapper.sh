#!/bin/bash

DATADIR="/usr/local/share"
SPOTDL_DIR="$DATADIR/ongaku/spotdl-custom"

if [ ! -d "$SPOTDL_DIR" ]; then
    echo "Error: SpotDL custom installation not found at $SPOTDL_DIR"
    exit 1
fi

export PATH="$SPOTDL_DIR/bin:$PATH"
export PYTHONPATH="$SPOTDL_DIR/lib/python3.13/site-packages:$PYTHONPATH"
export LD_LIBRARY_PATH="$SPOTDL_DIR/lib:$LD_LIBRARY_PATH"

exec "$SPOTDL_DIR/bin/python3" "$SPOTDL_DIR/bin/spotdl" "$@"
