FROM cirrusci/flutter:latest

USER root
RUN apt-get update && apt-get install -y wget unzip openjdk-21-jdk

ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN mkdir -p $ANDROID_HOME/cmdline-tools \
    && cd $ANDROID_HOME/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip \
    && unzip tools.zip -d latest \
    && rm tools.zip

RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" \
               "platforms;android-34" \
               "build-tools;34.0.0"

RUN flutter doctor
RUN flutter precache --android

WORKDIR /app
COPY . .

CMD ["flutter", "build", "apk"]
