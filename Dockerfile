FROM openjdk:8-jdk
MAINTAINER Zhenquan.Liang <lplzq87@gmail.com>

# Global Env Settings
ENV TOOLS_DIR /opt
ENV GRADLE_VERSION 3.4.1
ENV CMAKE_VERSION 3.9.6
ENV ANDROID_NDK_VERSION r13b

WORKDIR $TOOLS_DIR

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 git file build-essential --no-install-recommends

# Gradle
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN wget -q ${GRADLE_SDK_URL}  \
	&& unzip gradle-${GRADLE_VERSION}-bin.zip -d ${TOOLS_DIR}  \
	&& rm -rf gradle-${GRADLE_VERSION}-bin.zip
# TODO: gradle checksum
ENV GRADLE_HOME ${TOOLS_DIR}/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:$PATH
RUN chmod u+x ${GRADLE_HOME}/bin/*

# Installing CMake from cmake.org
RUN wget -q https://cmake.org/files/LatestRelease/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz
# TODO: cmake checksum
RUN tar zxf cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz
RUN mv cmake-${CMAKE_VERSION}-Linux-x86_64 ${ANDROID_HOME}/cmake
ENV PATH ${PATH}:${ANDROID_HOME}/cmake/bin
RUN chmod u+x ${ANDROID_HOME}/cmake/bin/ -R

# Installing Android sdk/build-tools/images
ENV ANDROID_TARGET_SDK="android-24,android-25,android-26" \
    ANDROID_BUILD_TOOLS="build-tools-26.0.2" \
    ANDROID_SDK_TOOLS="25.2.3" \
    ANDROID_IMAGES="sys-img-armeabi-v7a-android-23,sys-img-armeabi-v7a-android-21"
ENV ANDROID_HOME ${TOOLS_DIR}/android-sdk-linux

RUN mkdir ${ANDROID_HOME} && wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip && \
    unzip android-sdk.zip -d ${ANDROID_HOME}

ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:$PATH

# Updating images/libraries/tools
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter "${ANDROID_TARGET_SDK}" && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter platform-tools && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter "${ANDROID_BUILD_TOOLS}"
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository

# Installing Android NDK
ENV ANDROID_NDK_URL http://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
RUN curl -L "${ANDROID_NDK_URL}" -o android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip  \
  && unzip android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip -d ${TOOLS_DIR}  \
  && rm -rf android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
ENV ANDROID_NDK_HOME ${TOOLS_DIR}/android-ndk-${ANDROID_NDK_VERSION}
ENV PATH ${ANDROID_NDK_HOME}:$PATH
RUN chmod u+x ${ANDROID_NDK_HOME}/ -R

# Fix ConstraintLayout for Android 1.0.1 License Agreements
RUN mkdir ${ANDROID_HOME}/licenses && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" >> ${ANDROID_HOME}/licenses/android-sdk-license
RUN echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> ${ANDROID_HOME}/licenses/android-sdk-license
