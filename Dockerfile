FROM akr89/python:3.7

# Install java
ARG ZULU_ARCH=zulu8.31.0.1-jdk8.0.181-linux_x64
ARG JVM_DIR=/usr/local/lib/jvm
ENV JAVA_HOME=${JVM_DIR}/jdk
RUN curl -skSL -O http://cdn.azul.com/zulu/bin/${ZULU_ARCH}.tar.gz && \
    mkdir -p ${JVM_DIR} && \
    tar -xzf ${ZULU_ARCH}.tar.gz -C ${JVM_DIR} && \
    rm -f ${ZULU_ARCH}.tar.gz && \
    ln -sf ${JVM_DIR}/${ZULU_ARCH} ${JAVA_HOME} && \
    find ${JAVA_HOME}/bin -type f -perm -a=x -exec ln -sf {} /usr/local/bin/ \;

# vim:set ft=dockerfile:
