# Utiliza la imagen base de Alpine Linux
FROM alpine:latest

# Etiqueta del mantenedor
LABEL maintainer="GNR092"

# Instala Samba, Supervisor y Bash, y configura los directorios
RUN apk --no-cache add samba samba-common-tools supervisor bash $$ rm -rf /var/cache/apk/* && \
    mkdir -p /config /cpublic && \
    chmod -R 0777 /cpublic

ARG SAMBA_USER
ARG SAMBA_PASS

# Copia los archivos de configuración al directorio /config
COPY *.conf /config/
WORKDIR /
COPY start.sh .
RUN chmod +x start.sh


# Define el volumen para el directorio compartido
VOLUME /cpublic

# Expone los puertos necesarios para Samba
EXPOSE 135/tcp 137/udp 138/udp 139/tcp 445/tcp

# Define el comando de inicio para Supervisor
CMD ["sh", "start.sh"]

HEALTHCHECK --start-period=1m --interval=5s --retries=24 CMD nc -v -w 1 localhost 445

