#!/bin/bash

set -e

echo "DELETING Mass Assignment BOPLA Lab project..."
# - Only deletes direct children of bopla_mass
# - Explicitly preserves your two scripts
# - Avoids dangerous dot-pattern expansion issues
# - Works consistently across shells

find . -mindepth 1 -maxdepth 1 \
  ! -name "create_project.sh" \
  ! -name "reset_project.sh" \
  -exec rm -rf {} +

# Nuclear option - use at your own risk
# rm -rf ./*
# rm -rf ./.??*