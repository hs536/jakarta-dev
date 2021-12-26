FROM centos:7

# system update
RUN yum -y update && yum clean all

# set locale
RUN yum reinstall -y glibc-common && yum clean all
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/Japan /etc/localtime

# editor install
RUN yum install -y which unzip tar wget zip && \
    yum clean all && \
    #
    # setup jdk
    #
    GITHUB_REL_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases && \
    VERSION_PATH=`curl -sL ${GITHUB_REL_URL}/latest | grep "OpenJDK11U-jdk_x64_linux_11" | grep "href" | grep -v "sign" | grep -v "debug" | sed -r "s;^.*(/download/)(.*)(\.tar\.gz).*$;\2;"` && \
    curl -sLO "${GITHUB_REL_URL}/download/${VERSION_PATH}.tar.gz" && \
    tar -xzvpf ${VERSION_PATH##*/}.tar.gz && rm -rf ${VERSION_PATH##*/}.tar.gz && \
    JDK_DIR_NAME=openjdk-`echo ${VERSION_PATH} | sed -r "s;^.*_linux_(.*)$;\1;"` && \
    ln -s ${JDK_DIR_NAME} /usr/lib/jvm/jdk11
    java -version
    
ENV JAVA_HOME /usr/lib/jvm/jdk11
ENV MAVEN_HOME /usr/share/maven
ENV M2_HOME /usr/share/maven
ENV ANT_HOME /usr/share/ant
