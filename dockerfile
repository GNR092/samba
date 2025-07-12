# Utiliza la imagen base de Alpine Linux
FROM alpine:3.20

# Metadata sobre el contenedor
LABEL maintainer="GNR092"
LABEL description="Servidor Samba seguro y configurable en Docker"

# Variables de entorno por defecto (pueden ser sobrescritas por .env o docker-compose)
ENV \
    PUID=1000 \
    PGID=1000 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC \
    SAMBA_USER="testuser" \
    SAMBA_PASS="testpass" \
    SMB_WORKGROUP=WORKGROUP \
    SMB_SERVER_STRING="Servidor Samba %v" \
    SMB_NETBIOS_NAME=samba \
    SMB_MIN_PROTOCOL=SMB2 \
    SMB_MAX_PROTOCOL=SMB3 \
    SMB_NAME_RESOLVE_ORDER="host bcast wins" \
    SMB_ENCRYPT=if_required \
    SMB2_MAX_CREDITS=8192

RUN \
    apk add --no-cache \
        samba \
        samba-common-tools \
        supervisor \
        tzdata \
        shadow \
        netcat-openbsd \
        acl \
        gettext \
    && rm -rf /tmp/* /var/cache/apk/* \ 
    && mkdir -p /config /cpublic \ 
    && chown ${PUID}:${PGID} /cpublic \ 
    && chmod 2770 /cpublic 


COPY --chown=root:root --chmod=640 smb.conf /config/smb.conf
COPY --chown=root:root --chmod=640 supervisord.conf /config/
COPY --chmod=750 start.sh /start.sh

VOLUME /cpublic
EXPOSE 135/tcp 137/udp 138/udp 139/tcp 445/tcp

HEALTHCHECK --start-period=120s --interval=30s --timeout=5s --retries=3 \
    CMD sh -c \
    'nc -z 127.0.0.1 445 && \
    smbclient -L //127.0.0.1 -U "${SAMBA_USER}"%"${SAMBA_PASS}" -m SMB2 -t 3 | grep -q "Compartido"'


CMD ["/start.sh"]