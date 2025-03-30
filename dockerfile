# Utiliza la imagen base de Alpine Linux
FROM alpine:3.20

# Metadata
LABEL maintainer="GNR092"
LABEL description="Servidor Samba seguro en Docker"

# Instalación de paquetes en una sola capa
RUN \
    # Instalar dependencias principales
    apk add --no-cache \
        samba \
        samba-common-tools \
        supervisor \
        netcat-openbsd \
        tzdata \
        shadow \
    # Limpieza y preparación
    && rm -rf /var/cache/apk/* \
    # Crear directorios necesarios
    && mkdir -p /config /cpublic \
    # Configurar permisos iniciales
    && chown ${PUID}:${PGID} /cpublic \
    && chmod 2770 /cpublic

# Copia de archivos de configuración
COPY --chown=root:root --chmod=640 *.conf /config/
COPY --chmod=750 start.sh  /

# Variables de entorno (agrupadas lógicamente)
ENV \
    # Configuración regional
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm \
    # Configuración Samba
    SAMBA_USER="testuser" \
    SAMBA_PASS="testpass" \
    # Configuración sistema
    TZ=Etc/UTC \
    PUID=1000 \
    PGID=1000

    # Volúmenes y puertos
VOLUME /cpublic
EXPOSE 135/tcp 137/udp 138/udp 139/tcp 445/tcp

# Verificación de salud
HEALTHCHECK --start-period=30s --interval=1m --timeout=3s \
    CMD nc -z localhost 445 || exit 1

# Punto de entrada
CMD ["/start.sh"]