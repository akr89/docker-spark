FROM azul/zulu-openjdk-alpine:8

LABEL maintainer="Akrom Khasani <akrom@kofera.com>"

# Set JAVA_HOME
RUN ln -sf /usr/lib/jvm/zulu* /usr/lib/jvm/jdk
ENV JAVA_HOME=/usr/lib/jvm/jdk

# Software version to install
ARG MINICONDA_VERSION=latest
ARG PYTHON_VERSION=3.7
ARG GOSU_VERSION=1.10

# Install additional packages
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \ 
    apk add --no-cache bash bzip2 curl shadow@community

# Create users
ENV DEFAULT_USER=user
RUN useradd -mU -d /home/${DEFAULT_USER} ${DEFAULT_USER} && passwd -d ${DEFAULT_USER}

# Install python
ENV MINICONDA_HOME=/usr/local/miniconda
ENV PATH=${MINICONDA_HOME}/bin:${PATH}
RUN curl -skSL -O https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p ${MINICONDA_HOME} && \
    rm -f Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    ${MINICONDA_HOME}/bin/conda install -y -q --name base python=${PYTHON_VERSION} nomkl && \
    ${MINICONDA_HOME}/bin/conda update -y -q --all && \
    ${MINICONDA_HOME}/bin/conda clean -y -q --all && \
    rm -rf ${MINICONDA_HOME}/pkgs/ && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} ${MINICONDA_HOME} && \
    \
    ln -sf ${MINICONDA_HOME}/bin/python /usr/local/bin/python && \
    ln -sf ${MINICONDA_HOME}/bin/conda /usr/local/bin/conda && \
    ln -sf ${MINICONDA_HOME}/bin/pip /usr/local/bin/pip && \
    \
    ln -sf ${MINICONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". ${MINICONDA_HOME}/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    echo ". ${MINICONDA_HOME}/etc/profile.d/conda.sh" >> /home/${DEFAULT_USER}/.bashrc && \
    echo "conda activate base" >> /home/${DEFAULT_USER}/.bashrc

# Install gosu
RUN curl -skSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 \
        -o /usr/local/bin/gosu && \
    chmod a+x /usr/local/bin/gosu
