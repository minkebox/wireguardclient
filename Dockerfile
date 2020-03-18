FROM alpine:latest

RUN apk --no-cache add wireguard-tools dnsmasq miniupnpd ;\
    rm -rf /etc/dnsmasq.conf /etc/miniupnpd

COPY root/ /

VOLUME /etc/wireguard

HEALTHCHECK --interval=60s --timeout=5s CMD ifconfig wg0 || exit 1

ENTRYPOINT ["/startup.sh"]
