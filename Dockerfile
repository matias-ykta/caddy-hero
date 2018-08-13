
FROM alpine:latest

RUN apk add -U tzdata curl && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

RUN mkdir -m 777 /file
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ADD config.zip /file/config.zip

CMD /entrypoint.sh
