FROM ubuntu:22.04

ARG SDK_VERSION=30.0.2
ARG NDK_VERSION=25.2.9519653

# JAVA ENV
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Godot dependencies

## Add i386 arch and update
RUN dpkg --add-architecture i386 \
    && apt-get update -yqq

## Android Deps
RUN apt-get install -y \
    expect openjdk-17-jdk libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386

## Other deps
RUN apt-get -y install \
        xvfb libasound2-dev libudev-dev \
        clang curl pkg-config libavcodec-dev libavformat-dev libavutil-dev libavfilter-dev libavdevice-dev \
        libssl-dev libx11-dev libgl1-mesa-dev libxext-dev gnupg wget unzip git build-essential \
        autoconf texinfo gcc-multilib xvfb

## Clean apt cache
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/*


# Android SDK (based on https://github.com/docker-android-sdk/android-30/tree/master)
ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}
ENV ANDROID_NDK_HOME  ${ANDROID_HOME}/ndk/${NDK_VERSION}
ENV ANDROID_NDK_ROOT  ${ANDROID_NDK_HOME}
ENV ANDROID_NDK       ${ANDROID_NDK_HOME}



RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools
COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux
RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "cmdline-tools;latest"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "build-tools;${SDK_VERSION}"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platform-tools"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platforms;android-30"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "system-images;android-30;google_apis;x86_64"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "ndk;${NDK_VERSION}" --channel=3
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "cmake;3.22.1"

# FFMPEG Kit
WORKDIR /opt/ffmpeg-kit
RUN git clone --branch v6.0.LTS https://github.com/arthenica/ffmpeg-kit /opt/ffmpeg-kit

RUN ./android.sh --disable-arm-v7a --disable-arm-v7a-neon --disable-x86 --disable-x86-64
# FULL: RUN ./android.sh --full --disable-arm-v7a --disable-arm-v7a-neon --disable-x86 --disable-x86-64 --disable-lib-openssl --disable-lib-libass
ENV FFMPEG_DIR /opt/ffmpeg-kit/prebuilt/android-arm64/ffmpeg

WORKDIR /app

ENTRYPOINT ["/bin/bash"]
