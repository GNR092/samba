![Docker Pulls](https://img.shields.io/docker/pulls/gnr092/samba)
![Docker Stars](https://img.shields.io/docker/stars/gnr092/samba)
![Docker Image Size](https://img.shields.io/docker/image-size/gnr092/samba)
![Docker Image Version](https://img.shields.io/docker/v/gnr092/samba)


# Samba Docker

## Modos de ejecución para crear el contenedor Docker

### Primer paso

**¡Importante!** antes de comenzar habilitar permisos de escritura/lectura en carpeta compartida: 

```
mkdir -p $HOME/docker/samba/cpublic && \
chmod 777 -R $HOME/docker/samba/cpublic
```

### docker-compose (*Opción recomendada*)


``` docker
services:
  samba:
    container_name: samba
    image: gnr092/samba:latest
    environment:
        # Si no se asigna estas variables de entorno por defecto sera user y pass 123456
      - SAMBA_USER=testuser #Cambiar por el usuario que desee
      - SAMBA_PASS=testpass #Cambiar contraseña
    ports:
      - "135:135/tcp" 
      - "137:137/udp" 
      - "138:138/udp" 
      - "139:139/tcp" 
      - "445:445/tcp"
    volumes:
      - './cpublic:/cpublic'
    restart: unless-stopped
```

### docker-cli

```
docker run -d \
        --name=Samba \
        -e SAMBA_USER='testuser' \
        -e SAMBA_PASS='testpass' \
        -v $HOME/docker/samba/cpublic:/cpublic \
        -p 135:135 \
        -p 137:137 \
        -p 138:138 \
        -p 139:139 \
        -p 445:445 \
        --restart=always \
        gnr092/samba
```

## Parámetros

Las imágenes de contenedor se configuran utilizando parámetros pasados en tiempo de ejecución (como los anteriores). 
Estos parámetros están separados por dos puntos e indican ``<external>: <internal>`` respectivamente. 

| Parámetro | Función |
| ------ | ------ |
| ``-v ~/docker/samba/cpublic:/cpublic`` | Definimos ruta donde alojamos los ficheros compartidos |
| ``135:135`` | Puerto protocolo SMB |
| ``137:137`` | Puerto protocolo NetBios |
| ``138:138`` | Puerto protocolo NetBios |
| ``139:139`` | Puerto protocolo SMB |
| ``445:445`` | Puerto protocolo SMB |