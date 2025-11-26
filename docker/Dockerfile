ARG TIMEZONE="Europe/Moscow"
ARG VERSION

# -------------------------------------
FROM ubuntu:24.04 AS build
ARG VERSION=

SHELL [ "/bin/bash", "-c" ]
ENV SHELL="/bin/bash"
ENV PATH=$PATH:/app

WORKDIR /app

RUN \
# exit immediately if any command exits with a non-zero status
set -e; \
echo "----- Install Linphone packages -----"; \
export DEBIAN_FRONTEND=noninteractive; \
apt-get update; \
apt-cache search linphone; \
apt-get install -y linphone-desktop${VERSION:+=${VERSION}}; \
echo "----- DONE -----"

RUN \
set -e; \
echo "----- Install Docker extensions -----"; \
apt-get install -y python3-docker; \
apt-get install -y speech-dispatcher; \
echo "----- DONE -----"

# Cleanup
RUN \
echo "----- Cleanup -----"; \
apt-get autoremove -y; \
apt-get clean; \
rm -rf /{app,tmp}/* /var/lib/apt/lists/*; \
echo "----- DONE -----"

## STAGE SQUASH
# -------------------------------------
FROM scratch
COPY --from=build / /

WORKDIR /app
ENV PATH=$PATH:/app

COPY *.sh *.py ./
RUN chmod +x *.sh *.py

CMD [ "linphone" ]
ENTRYPOINT [ "./entrypoint.sh" ]
