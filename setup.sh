#!/bin/bash
# shellcheck disable=SC1091

chmod +x scripts/setup-main.sh &&
timestamp=$(date '+%Y-%m-%d-%H:%M:%S') &&
. scripts/setup-main.sh 2>&1 | tee setup-"$timestamp".log 
