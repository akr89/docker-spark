FROM akr89/spark:none

LABEL version_tags="[\"2.3-hadoop2.6\",\"2.3.1-hadoop2.6\"]"

# Install spark
ARG SPARK_VERSION=2.3.1
ARG SPARK_HADOOP=hadoop2.6
ENV SPARK_HOME=/usr/local/spark
RUN curl -skSL -O https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-${SPARK_HADOOP}.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-${SPARK_HADOOP}.tgz -C /usr/local && \
    rm -f spark-${SPARK_VERSION}-bin-${SPARK_HADOOP}.tgz && \
    ln -sf /usr/local/spark-${SPARK_VERSION}-bin-${SPARK_HADOOP} ${SPARK_HOME} && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} ${SPARK_HOME}

# Scratch directories
# ${SPARK_HOME}/work - directory used on worker for scratch space and job output logs.
# /tmp - directory to use for "scratch" space in Spark, including map output files and RDDs that get stored on disk.
VOLUME ${SPARK_HOME}/work

# Add default config and entypoint
ADD ./entrypoint.sh ./spark-defaults.conf /usr/local/
RUN chmod a+x /usr/local/entrypoint.sh

# Expose ports
EXPOSE 8080 8081 6066 7077
EXPOSE 7001 7002 7003 7004 7005 7006
EXPOSE 4040

ENTRYPOINT [ "/usr/local/entrypoint.sh" ]

# vim:set ft=dockerfile:
