FROM quay.io/toolbx-images/alpine-toolbox:edge

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="<brian@27megahertz.com>"

COPY extra-packages /
RUN apk update && \
    apk upgrade && \
    grep -v '^#' /extra-packages | xargs apk add && \
    apk list -I | \
      sed -rn '/-doc/! s/([a-z-]+[a-z]).*/\1/p' | \
      awk '{ print system("apk info \""$1"-doc\" > /dev/null") == 0 ? $1 "-doc" : "" }' | \
      xargs apk add && \
    rm /extra-packages

RUN   ln -fs /bin/sh /usr/bin/sh && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
