FROM openjdk:8-jdk
MAINTAINER Zhenquan.Liang <lplzq87@gmail.com>

# Global Env Settings
ENV TOOLS_DIR /opt  
WORKDIR ${TOOLS_DIR}

# Update package to latest
RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 git file build-essential --no-install-recommends

# Installing and Configuring Gradle
ENV GRADLE_VERSION 3.4.1 
ENV GRADLE_HOME ${TOOLS_DIR}/gradle-${GRADLE_VERSION}
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN wget -q ${GRADLE_SDK_URL}  \
	&& unzip -q gradle-${GRADLE_VERSION}-bin.zip -d ${TOOLS_DIR}  \
	&& rm -rf gradle-${GRADLE_VERSION}-bin.zip
RUN chmod u+x ${GRADLE_HOME}/bin/*

# Installing Android sdk/build-tools/images
ENV ANDROID_HOME ${TOOLS_DIR}/android-sdk-linux
ENV ANDROID_TARGET_SDK="android-25,android-26" \
    ANDROID_BUILD_TOOLS="build-tools-26.0.2" \
    ANDROID_SDK_TOOLS="25.2.3" \
    ANDROID_IMAGES="sys-img-armeabi-v7a-android-21"
RUN mkdir ${ANDROID_HOME} && wget -q --output-document=android-sdk.zip \
	https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip && \
    unzip -q android-sdk.zip -d ${ANDROID_HOME}

# Updating images/libraries/tools
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter "${ANDROID_TARGET_SDK}" && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter platform-tools && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter "${ANDROID_BUILD_TOOLS}"
RUN echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services && \
    echo y | android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository
# TODO: add constraint layout services

# Installing CMake from dl.google.com
ENV CMAKE_VERSION 3.6.4111459 
RUN wget -q https://dl.google.com/android/repository/cmake-${CMAKE_VERSION}-linux-x86_64.zip -O android-cmake.zip \
	&& mkdir -p ${ANDROID_HOME}/cmake \
	&& unzip -q android-cmake.zip -d ${ANDROID_HOME}/cmake/${CMAKE_VERSION}
RUN chmod u+x ${ANDROID_HOME}/cmake/${CMAKE_VERSION}/bin/ -R

# Installing Android NDK
ENV ANDROID_NDK_VERSION r13b
ENV ANDROID_NDK_HOME ${TOOLS_DIR}/android-ndk-${ANDROID_NDK_VERSION}
ENV ANDROID_NDK_URL http://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
RUN wget -q "${ANDROID_NDK_URL}" \
  && unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip -d ${TOOLS_DIR}  \
  && rm -rf android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
#RUN chmod u+x ${ANDROID_NDK_HOME}/ -R

ENV PATH ${GRADLE_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}:${ANDROID_HOME}/cmake/${CMAKE_VERSION}/bin:$PATH

RUN mkdir ${ANDROID_HOME}/licenses && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" >> ${ANDROID_HOME}/licenses/android-sdk-license
RUN echo "3046d46e22f5119de7c4e1b156e5750820085e09\n7c928e048b455a44b323aba54342415d0429c542" >> ${ANDROID_HOME}/licenses/android-sdk-preview-license
# fix cmake license issure
RUN echo '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:repository xmlns:ns2="http://schemas.android.com/repository/android/common/01" xmlns:ns3="http://schemas.android.com/repository/android/generic/01" xmlns:ns4="http://schemas.android.com/sdk/android/repo/addon2/01" xmlns:ns5="http://schemas.android.com/sdk/android/repo/repository2/01" xmlns:ns6="http://schemas.android.com/sdk/android/repo/sys-img2/01"><license id="android-sdk-license" type="text">xxx</license><localPackage path="cmake;3.6.4111459" obsolete="false"><type-details xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:genericDetailsType"/><revision><major>3</major><minor>6</minor><micro>4111459</micro></revision><display-name>CMake 3.6.4111459</display-name><uses-license ref="android-sdk-license"/></localPackage></ns2:repository>' >> ${ANDROID_HOME}/cmake/${CMAKE_VERSION}/package.xml
