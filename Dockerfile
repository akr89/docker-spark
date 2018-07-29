FROM azul/zulu-openjdk-alpine:8

LABEL version_tags="[\"2.3\",\"2.3.1\"]"
LABEL maintainer="Akrom Khasani <akrom@kofera.com>"

# Set JAVA_HOME
RUN ln -sf /usr/lib/jvm/zulu* /usr/lib/jvm/jdk
ENV JAVA_HOME=/usr/lib/jvm/jdk

# Software version to install
ARG SPARK_VERSION=2.3.1
ARG SPARK_HADOOP_VERSION=2.7
ARG HADOOP_LIB_VERSION=2.7.6
ARG MINICONDA_VERSION=latest
ARG PYTHON_VERSION=3.7
ARG GOSU_VERSION=1.10

# Install additional package
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \ 
    apk add --no-cache bash bzip2 curl shadow@community

# Install spark
ENV SPARK_HOME=/usr/local/spark
RUN curl -skSL -O https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz -C /usr/local && \
    rm -f spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz && \
    ln -sf /usr/local/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION} ${SPARK_HOME}

# Scratch directories can be passed as volumes
# SPARK_HOME/work - directory used on worker for scratch space and job output logs.
# /tmp - directory to use for "scratch" space in Spark, including map output files and RDDs that get stored on disk.
VOLUME ${SPARK_HOME}/work /tmp

# Install hadoop lib native
RUN curl -skSL -O https://storage.googleapis.com/ds-storage-1/hadoop-${HADOOP_LIB_VERSION}-lib-native.tar.gz && \
    tar -xzf hadoop-${HADOOP_LIB_VERSION}-lib-native.tar.gz -C /usr/local/ && \
    rm -f hadoop-${HADOOP_LIB_VERSION}-lib-native.tar.gz
ENV LD_LIBRARY_PATH=/usr/local/lib/native:${LD_LIBRARY_PATH}

# Create users
ENV GENERAL_USER=user
ENV SPARK_USER=spark
RUN useradd -mU -d /home/hadoop hadoop && passwd -d hadoop && \
    useradd -mU -d /home/${SPARK_USER} -G hadoop ${SPARK_USER} && passwd -d ${SPARK_USER} && \
    chown -R ${SPARK_USER}:hadoop ${SPARK_HOME} && \
    useradd -mU -d /home/${GENERAL_USER} ${GENERAL_USER} && passwd -d ${GENERAL_USER}

# Install python
ARG MINICONDA_HOME=/usr/local/miniconda
RUN curl -skSL -O https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p ${MINICONDA_HOME} && \
    rm -f Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    ${MINICONDA_HOME}/bin/conda install -y -q --name base python=${PYTHON_VERSION} pyspark=${SPARK_VERSION} nomkl && \
    ${MINICONDA_HOME}/bin/conda update -y -q --all && \
    ${MINICONDA_HOME}/bin/conda clean -y -q --all && \
    rm -rf ${MINICONDA_HOME}/pkgs/ && \
    chown -R ${SPARK_USER}:hadoop ${MINICONDA_HOME} && \
    \
    ln -sf ${MINICONDA_HOME}/bin/python /usr/local/bin/python && \
    ln -sf ${MINICONDA_HOME}/bin/conda /usr/local/bin/conda && \
    ln -sf ${MINICONDA_HOME}/bin/pip /usr/local/bin/pip && \
    \
    ln -sf ${MINICONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". ${MINICONDA_HOME}/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    echo ". ${MINICONDA_HOME}/etc/profile.d/conda.sh" >> /home/${GENERAL_USER}/.bashrc && \
    echo "conda activate base" >> /home/${GENERAL_USER}/.bashrc && \
    echo ". ${MINICONDA_HOME}/etc/profile.d/conda.sh" >> /home/${SPARK_USER}/.bashrc && \
    echo "conda activate base" >> /home/${SPARK_USER}/.bashrc

# Install gosu
RUN curl -skSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 \
        -o /usr/local/bin/gosu && \
    chmod a+x /usr/local/bin/gosu

ADD entrypoint.sh spark-defaults.conf /usr/local/
RUN chmod a+x /usr/local/entrypoint.sh

WORKDIR /tmp

EXPOSE 8080 8081 6066 7077
EXPOSE 4040 7001 7002 7003 7004 7005 7006

ENTRYPOINT [ "/usr/local/entrypoint.sh" ]
