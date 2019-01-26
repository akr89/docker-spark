#!/bin/bash
set -e

case $1 in
bash)
    shift
    echo "==> bash invocation arguments: $@"
    exec bash $@
  ;;
python)
    shift
    echo "==> python invocation arguments: $@"
    exec python $@
  ;;
*)
    cmdline="$@"
    exec gosu $DEFAULT_USER ${cmdline:-"ptipython"}
  ;;
esac

# vim:set ft=sh ff=unix:
