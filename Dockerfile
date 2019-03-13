FROM alpine:3.9

LABEL maintainer="docker-dario@neomediatech.it"

RUN apk update && apk upgrade && \ 
    apk add --no-cache tzdata bash tini samba shadow && \
    cp /usr/share/zoneinfo/Europe/Rome /etc/localtime

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/etc", "/var/cache/samba", "/var/lib/samba", "/var/log/samba", "/run/samba"]

EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=60s --timeout=15s CMD smbclient -L '\\localhost' -U '%' -m SMB3
            
ENTRYPOINT ["/entrypoint.sh"]

#CMD ["tini", "--", "in.tftpd", "-4", "-vvv", "--foreground", "--secure", "-p", "/tftpboot"]
CMD ["in.tftpd", "-4", "-vvv", "--foreground", "--secure", "-p", "/tftpboot"]
