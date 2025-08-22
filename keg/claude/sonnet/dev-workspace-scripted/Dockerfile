# Absolute Minimal Dockerfile Pattern
# Copies ROOT/ overlay to filesystem root, runs build script with success/failure presentation
# All complexity delegated to build scripts - maximum flexibility with minimal layers

ARG FROM=ubuntu:24.04
FROM ${FROM}

ARG FROM
ARG BUILD_ENV=default.env
ARG BUILD_SCRIPT=build/build.sh
ARG BUILD_CONFIG=config-default.sh
ARG UID=1000
ARG USER=dev
ARG ROOT=ROOT

USER 0
COPY ${ROOT}/. /

ARG ON_FAIL=exit

RUN /${BUILD_SCRIPT} && /build/success.sh || /build/failed.sh && $ON_FAIL 99
    
USER ${UID}

ENTRYPOINT ["sh", "/entrypoint.sh"]
STOPSIGNAL SIGQUIT