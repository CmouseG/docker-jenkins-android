##################################
# Dockerfile for jenkins-android #
# Based on Ubuntu                #
##################################

# Set the base image from Ubuntu
FROM ubuntu:16.04

# 镜像维护者
MAINTAINER CmouseG <mouseg1668924806@gmail.com>

# Nerver ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections && \
    echo "debconf shared/accepted-oracle-license-v1-1 seen true" | /usr/bin/debconf-set-selections

# Change aliyun source
RUN rm -rf /etc/apt/sources.list
COPY ./sources.list /etc/apt/

# Add oracle-jdk8 packages to and from apt.
RUN apt-get update && \
	apt-get install software-properties-common python-software-properties -y && \
	add-apt-repository ppa:webupd8team/java && \
	apt-get update && \
	apt-get install oracle-java8-installer -y && \
	apt-get install oracle-java8-set-default -y && \
	apt-get install -y unzip && \
	apt-get install -y lib32ncurses5 lib32z1 && \
	apt-get autoclean -y && \
	apt-get autoremove -y

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
# ENV PATH $JAVA_HOME:$PATH
ENV JAVA_OPTS -Duser.timezone=Asia/Shanghai -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8

# Add Android SDK
## Source https://developer.android.com/studio/index.html
RUN wget --progress=dot:giga https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
	mv android-sdk_r24.4.1-linux.tgz /opt/ && \
	cd /opt && tar xzvf ./android-sdk_r24.4.1-linux.tgz && \
	rm -r /opt/android-sdk_r24.4.1-linux.tgz && \
	apt-get install gcc-multilib -y && \
	apt-get autoclean -y && \
	apt-get autoremove -y

ENV ANDROID_HOME /opt/android-sdk-linux/
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

RUN echo $PATH && \
    ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk -u --filter platform-tools,android-19,build-tools-19.0.3 && \
    chmod -R 755 $ANDROID_HOME

# Copy dir
COPY ./licenses /opt/android-sdk-linux/licenses
#ADD ./licenses /opt/android-sdk-linux/
#RUN mv /opt/android-sdk-linux/android-sdk-license /opt/android-sdk-linux/licenses

# Add gradle
## Source https://services.gradle.org/distributions/
ADD http://os2xb1aks.bkt.clouddn.com/android/gradle/gradle-2.14.1-bin.zip /opt/
RUN unzip /opt/gradle-2.14.1-bin.zip -d /opt && \
    rm /opt/gradle-2.14.1-bin.zip
ENV GRADLE_HOME /opt/gradle-2.14.1
ENV PATH $GRADLE_HOME/bin:$PATH

# Add git
RUN apt-get install -y git-core && \
    apt-get autoclean -y && \
    apt-get autoremove -y

# Add Jenkins
# Thanks to orchardup/jenkins Dockerfile
RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - && \
	echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" >> /etc/apt/sources.list && \
	apt-get update && \
	mkdir /var/run/jenkins && \
	apt-get install -y jenkins && \
	service jenkins stop && \
	apt-get autoclean -y && \
	apt-get autoremove -y

EXPOSE 8080

VOLUME ["/root/.jenkins/"]
#VOLUME ["/opt/android-sdk-linux/"]

ENTRYPOINT [ "java","-jar","/usr/share/jenkins/jenkins.war" ]