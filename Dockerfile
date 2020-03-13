FROM alpine:latest

RUN apk --no-cache add wireguard-tools dnsmasq miniupnpd ;\
    rm -rf /etc/dnsmasq.conf /etc/miniupnpd

COPY root/ /

VOLUME /etc/wireguard

ENTRYPOINT ["/startup.sh"]
