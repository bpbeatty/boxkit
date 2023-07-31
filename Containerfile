FROM quay.io/toolbx-images/alpine-toolbox:edge

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="<brian@27megahertz.com>"

ADD etc /etc
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

COPY extra-packages /
RUN apk update && \
    apk upgrade && \
    grep -v '^#' /extra-packages | xargs apk add && \
    apk list -I | \
      sed -rn '/-doc/! s/([a-z-]+[a-z]).*/\1/p' | \
      awk '{ print system("apk info \""$1"-doc\" > /dev/null") == 0 ? $1 "-doc" : "" }' | \
      xargs apk add && \
    sed -i -e 's/set\ mouse=/\"set\ mouse=/g' /usr/share/vim/vim*/defaults.vim && \
    rm /extra-packages

WORKDIR /tmp
RUN wget -P /tmp/ice \
    https://github.com/AdoptOpenJDK/IcedTea-Web/releases/download/icedtea-web-1.8.8/icedtea-web-1.8.8.linux.bin.zip \
    https://github.com/AdoptOpenJDK/IcedTea-Web/releases/download/icedtea-web-1.8.8/icedtea-web-1.8.8.linux.bin.zip.sha256.txt && \
    cd ice && \
    if sha256sum -c icedtea-web-1.8.8.linux.bin.zip.sha256.txt; then \
      unzip -d /opt icedtea-web-1.8.8.linux.bin.zip; \
      ln -s /opt/icedtea-web-image/bin/javaws /usr/local/bin/javaws; \
    fi && \
    cd .. && \
    rm -rf /tmp/ice
WORKDIR /

RUN   ln -fs /bin/sh /usr/bin/sh && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
