FROM akr89/python:3.7-java8

# Software version to install
ARG SPARK_VERSION=2.3.2
ARG SPARK_HADOOP=without-hadoop
ARG HADOOP_VERSION=2.6.5

# Install Spark
ENV SPARK_HOME=/usr/local/spark
RUN curl -skSL -O https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-${SPARK_HADOOP}.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-${SPARK_HADOOP}.tgz -C /usr/local && \
    rm -f spark-${SPARK_VERSION}-bin-${SPARK_HADOOP}.tgz && \
    ln -sf /usr/local/spark-${SPARK_VERSION}-bin-${SPARK_HADOOP} ${SPARK_HOME} && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} ${SPARK_HOME} && \
    pip install -e ${SPARK_HOME}/python

# Install Hadoop
ENV HADOOP_HOME=/usr/local/hadoop
RUN curl -skSL -O https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /usr/local && \
    rm -f hadoop-${HADOOP_VERSION}.tar.gz && \
    ln -sf /usr/local/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} ${HADOOP_HOME}
ENV SPARK_DIST_CLASSPATH=${HADOOP_HOME}/etc/hadoop:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/contrib/capacity-scheduler/*.jar

# Install additional pakcages
ADD ./requirements.txt /usr/local/
RUN pip install -r /usr/local/requirements.txt

# Add entrypoint
ADD ./entrypoint.sh /usr/local/
RUN chmod a+x /usr/local/entrypoint.sh

ENTRYPOINT [ "/usr/local/entrypoint.sh" ]

# vim:set ft=dockerfile sw=4 ts=4:
