FROM alpine:latest

RUN apk add curl jq curl speedtest-cli

COPY ./speedtest.sh .
CMD ["./speedtest.sh"]
