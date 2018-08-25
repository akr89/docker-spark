#!/bin/bash
set -e

# Defaults
: ${SPARK_HOME:?must be set!}
default_opts="--properties-file /usr/local/spark-defaults.conf"

# Check if CLI args list containes bind address key.
cli_bind_address() {
  echo "$*" | grep -qE -- "--host\b|-h\b|--ip\b|-i\b"
}

# Configuration sourcing
. $SPARK_HOME/sbin/spark-config.sh
. $SPARK_HOME/bin/load-spark-env.sh

# Entrypoint
case $1 in
master|worker)
    instance=$1
    shift
    CLASS="org.apache.spark.deploy.$instance.${instance^}"

    # Handle custom bind address set via ENV or CLI
    eval bind_address=\$SPARK_${instance^^}_IP
    if ( ! cli_bind_address $@ ) && [ ! -z $bind_address ] ; then
      default_opts="${default_opts} --host ${bind_address}"
    fi

    echo "==> spark-class invocation arguments: $CLASS $default_opts $@"
    exec gosu $DEFAULT_USER $SPARK_HOME/bin/spark-class $CLASS $default_opts $@
  ;;
shell)
    shift
    echo "==> spark-shell invocation arguments: $default_opts $@"
    exec gosu $DEFAULT_USER $SPARK_HOME/bin/pyspark $default_opts $@
  ;;
*)
    cmdline="$@"
    exec gosu $DEFAULT_USER ${cmdline:-"bash"}
  ;;
esac
