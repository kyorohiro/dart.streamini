FROM ubuntu:18.04
#
#
# docker build -t streamini .
# cd ..
# docker run -p8443:8443 -p8080:8080 -v.:/works/streamini -it streamini 
#
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y curl wget gnupg less lsof net-tools git apt-utils -y

WORKDIR /works

# DART
RUN apt-get install apt-transport-https
RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN apt-get update
RUN apt-get install dart -y
ENV PATH="${PATH}:/usr/lib/dart/bin/"
ENV PATH="${PATH}:/root/.pub-cache/bin"
#
RUN pub global activate webdev
RUN pub global activate stagehand


#
# CODE-SERVER
RUN wget https://github.com/cdr/code-server/releases/download/1.939-vsc1.33.1/code-server1.939-vsc1.33.1-linux-x64.tar.gz
RUN tar xzf code-server1.939-vsc1.33.1-linux-x64.tar.gz -C ./ --strip-components 1

#
# Dart Plugin
RUN /works/code-server --install-extension Dart-Code.dart-code
RUN mkdir /works/streamini


#
# AWS 
#
WORKDIR /works/streamini
EXPOSE 8443 8080
COPY . /works/streamini
RUN pub get
#VOLUME [ "/works/streamini" ]
#CMD [ "/works/code-server", "--allow-http", "--no-auth", "/works/streamini" ]
