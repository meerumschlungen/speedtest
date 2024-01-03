FROM debian:bookworm

# Install basics
RUN apt-get update && apt-get install -y curl jq

# Install speedtest cli
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
RUN apt-get install -y speedtest

COPY ./speedtest.sh .
CMD ["./speedtest.sh"]
