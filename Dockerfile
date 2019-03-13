FROM alpine:3.9

LABEL maintainer="docker-dario@neomediatech.it"

RUN apk update && apk upgrade && \ 
    apk add --no-cache tzdata bash tini samba shadow && \
    cp /usr/share/zoneinfo/Europe/Rome /etc/localtime && \
    useradd -c 'Samba User' -d /tmp -M -r smbuser && \
    sed -i 's|^\(   log file = \).*|\1/dev/stdout|' /etc/samba/smb.conf && \
    sed -i 's|^\(   unix password sync = \).*|\1no|' /etc/samba/smb.conf && \
    sed -i '/Share Definitions/,$d' /etc/samba/smb.conf && \
    echo '   security = user' >>/etc/samba/smb.conf && \
    echo '   directory mask = 0777' >>/etc/samba/smb.conf && \
    echo '   force create mode = 0666' >>/etc/samba/smb.conf && \
    echo '   force directory mode = 0777' >>/etc/samba/smb.conf && \
    echo '   force group = users' >>/etc/samba/smb.conf && \
    echo '   load printers = no' >>/etc/samba/smb.conf && \
    echo '   printing = bsd' >>/etc/samba/smb.conf && \
    echo '   printcap name = /dev/null' >>/etc/samba/smb.conf && \
    echo '   disable spoolss = yes' >>/etc/samba/smb.conf && \
    echo '   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536' >>/etc/samba/smb.conf && \
    echo '' >>/etc/samba/smb.conf && \

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/etc", "/var/cache/samba", "/var/lib/samba", "/var/log/samba", "/run/samba"]

EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=60s --timeout=15s CMD smbclient -L '\\localhost' -U '%' -m SMB3
            
ENTRYPOINT ["/entrypoint.sh"]

#CMD ["tini", "--", "in.tftpd", "-4", "-vvv", "--foreground", "--secure", "-p", "/tftpboot"]
CMD ["in.tftpd", "-4", "-vvv", "--foreground", "--secure", "-p", "/tftpboot"]
