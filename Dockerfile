FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    MOZ_PLUGIN_PATH=/usr/lib/mozilla/plugins

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl bzip2 locales \
        libgtk-3-0 libgtk2.0-0 libgl1-mesa-glx libdbus-glib-1-2 libasound2 libxt6 libnss3 \
        libx11-xcb1 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
        libfontconfig1 fonts-dejavu-core && \
    locale-gen en_US.UTF-8 ru_RU.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# ESR 52 still supports NPAPI Flash. 32.0.0.363 predates Adobe's EOL kill switch.
ARG FIREFOX_VERSION=52.9.0esr
ARG FLASH_SHA256=c430d3f6b0127f9463e4e70857fbb9174fa5aa9e0f951e98ab48a17a7d9731bc
RUN curl -fLsS --retry 3 \
        "https://ftp.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2" \
        -o /tmp/firefox.tar.bz2 && \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt && \
    rm /tmp/firefox.tar.bz2 && \
    mkdir -p /usr/lib/mozilla/plugins && \
    curl -fLsS --retry 3 \
        'https://archive.org/download/flashplayerarchive/pub/flashplayer/installers/archive/fp_32.0.0.363_archive.zip/32_0_r0_363%2Fflashplayer32_0r0_363_linux.x86_64.tar.gz' \
        -o /tmp/flash.tar.gz && \
    echo "${FLASH_SHA256}  /tmp/flash.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/flash.tar.gz -C /usr/lib/mozilla/plugins libflashplayer.so && \
    rm /tmp/flash.tar.gz && \
    printf 'pref("app.update.enabled", false);\n' > /opt/firefox/defaults/pref/adofox.js && \
    useradd -m -s /bin/bash ffuser

USER ffuser
WORKDIR /home/ffuser
ENTRYPOINT ["/opt/firefox/firefox", "-no-remote"]
