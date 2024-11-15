FROM oryd/oathkeeper:v0.40.7

ARG TARGETPLATFORM
ARG BUILDPLATFORM

USER root

RUN apk add --no-cache gettext inotify-tools

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ory

ENTRYPOINT ["/entrypoint.sh"]
CMD []