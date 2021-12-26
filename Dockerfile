FROM centos:7

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# system setup
RUN yum -y update && yum clean all && \
    yum reinstall -y glibc-common && \
    yum install -y which unzip tar wget zip && \
    yum clean all && \
    unlink /etc/localtime && \
    ln -s /usr/share/zoneinfo/Japan /etc/localtime

# tool setup
RUN update-ca-trust && \
    #
    # setup jdk11
    #
    GITHUB_REL_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases && \
    VERSION_PATH=`curl -sL ${GITHUB_REL_URL}/latest | grep "OpenJDK11U-jdk_x64_linux_11" | grep "href" | grep -v "sign" | grep -v "debug" | sed -r "s;^.*(/download/)(.*)(\.tar\.gz).*$;\2;"` && \
    curl -sLO "${GITHUB_REL_URL}/download/${VERSION_PATH}.tar.gz" && \
    tar -xzvpf ${VERSION_PATH##*/}.tar.gz && rm -rf ${VERSION_PATH##*/}.tar.gz && \
    JDK_DIR_NAME=openjdk-`echo ${VERSION_PATH} | sed -r "s;^.*_linux_(.*)$;\1;"` && \
    mkdir -p /usr/lib/jvm && \
    mv ${JDK_DIR_NAME} /usr/lib/jvm/jdk11 && \
    cp -Lf /etc/pki/java/cacerts /usr/lib/jvm/jdk11/lib/security/cacerts && \
    ln -s /usr/lib/jvm/jdk11/bin/* /bin/ && \
    #
    # setup jdk9
    #
    curl -sLO https://download.java.net/java/GA/jdk9/9.0.4/binaries/openjdk-9.0.4_linux-x64_bin.tar.gz && \
    tar -xzvpf openjdk-9.0.4_linux-x64_bin.tar.gz && rm -rf openjdk-9.0.4_linux-x64_bin.tar.gz && \
    mv jdk-9.0.4 /usr/lib/jvm/jdk9 && \
    #
    # setup jdk8
    #
    curl -sLO https://github.com/AdoptOpenJDK/openjdk8-releases/releases/download/jdk8u172-b11/OpenJDK8_x64_Linux_jdk8u172-b11.tar.gz && \
    tar -xzvpf OpenJDK8_x64_Linux_jdk8u172-b11.tar.gz && rm -rf OpenJDK8_x64_Linux_jdk8u172-b11.tar.gz && \
    mv jdk8u172-b11 /usr/lib/jvm/jdk8 && \
    #
    # install maven
    #
    curl -O https://archive.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.zip && \
    unzip apache-maven-*-bin.zip -d /usr/share && \
    rm apache-maven-*-bin.zip && \
    mv /usr/share/apache-maven-* /usr/share/maven && \
    ln -s /usr/share/maven/bin/mvn /bin/ && \
    #
    # install takari extensions
    #
    curl -O https://repo1.maven.org/maven2/io/takari/aether/takari-local-repository/0.11.2/takari-local-repository-0.11.2.jar && \
    mv takari-local-repository-*.jar /usr/share/maven/lib/ext/ && \
    curl -O https://repo1.maven.org/maven2/io/takari/takari-filemanager/0.8.3/takari-filemanager-0.8.3.jar && \
    mv takari-filemanager-*.jar /usr/share/maven/lib/ext/ && \
    #
    # install ant
    #
    curl -O https://archive.apache.org/dist/ant/binaries/binaries/apache-ant-1.9.4-bin.zip && \
    unzip apache-ant-*-bin.zip -d /usr/share && \
    rm apache-ant-*-bin.zip && \
    mv /usr/share/apache-ant-* /usr/share/ant && \
    ln -s /usr/share/ant/bin/ant /bin/ && \
    #
    # custom user
    #
    useradd -l -r -d /home/developer -u 1000100000 -g root -s /bin/bash developer && \
    mkdir -p /work/developer && chmod 777 -R /work/developer && \
    chown -R developer:root /work/developer

ADD maven/settings.xml /usr/share/maven/conf
ADD maven/toolchains.xml /usr/share/maven/conf

ENV JAVA_HOME /usr/lib/jvm/jdk11
ENV MAVEN_HOME /usr/share/maven
ENV M2_HOME /usr/share/maven
ENV ANT_HOME /usr/share/ant

ENV HOME /work/developer
WORKDIR /work/developer
USER developer
