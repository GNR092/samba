![Docker Pulls](https://img.shields.io/docker/pulls/gnr092/samba)
![Docker Stars](https://img.shields.io/docker/stars/gnr092/samba)
![Docker Image Size](https://img.shields.io/docker/image-size/gnr092/samba)
![Docker Image Version](https://img.shields.io/docker/v/gnr092/samba)

# Servidor Samba en Docker 🐳

Este proyecto te permite desplegar un servidor Samba robusto y configurable usando Docker, ideal para compartir archivos en tu red local.

---

## 🚀 Primeros Pasos

### 1. Preparar la Carpeta Compartida

Antes de crear el contenedor, habilita los permisos de lectura/escritura en la carpeta que deseas compartir. Por ejemplo, si usas `~/docker/samba/cpublic`:

```bash
mkdir -p "$HOME/docker/samba/cpublic" && \
chmod 2770 "$HOME/docker/samba/cpublic"
```
Nota: El chmod 2770 establece permisos de grupo y el bit setgid para que los nuevos archivos dentro de la carpeta hereden el grupo.

### 2. Crear el Archivo de Configuración .env 📄
Para una configuración sencilla y segura, usa un archivo .env. Crea un archivo llamado .env en el mismo directorio donde tendrás tu docker-compose.yml o desde donde ejecutarás el comando docker run.

[Archivo .env](./https://raw.githubusercontent.com/GNR092/samba/refs/heads/master/.env)

### 🚀 Modos de Ejecución
Puedes levantar tu servidor Samba usando Docker Compose (recomendado para gestionar servicios) o Docker CLI.

🐳 Opción 1: Docker Compose (Recomendado)
Utiliza docker-compose para una gestión sencilla del servicio. Crea un archivo docker-compose.yml en el mismo directorio que tu archivo .env.

```yaml
# docker-compose.yml
services:
  samba:
    container_name: samba
    image: gnr092/samba:${SMB_VERSION:-release}
    environment:
      - SAMBA_USER=${SMB_USER}
      - SAMBA_PASS=${SMB_PASSWORD}
    ports:
      - "137-138:137-138/udp"  # NetBIOS (nmbd)
      - "139:139/tcp"          # Samba (smbd)
      - "445:445/tcp"          # Samba (smbd)
    volumes:
      - ${SMB_DIRECTORY}:/cpublic
    env_file:
      - .env
    restart: unless-stopped
```
Para levantar el contenedor, ejecuta:

```bash
docker compose up -d
```

💻 Opción 2: Docker CLI
Si prefieres usar el comando docker run directamente, puedes cargar el archivo .env con la bandera --env-file.

```bash
docker run -d \
  --name samba \
  --env-file ./.env \
  -v "$HOME/docker/samba/cpublic:/cpublic" \
  -p 137:137/udp \
  -p 138:138/udp \
  -p 139:139/tcp \
  -p 445:445/tcp \
  --restart=unless-stopped \
  gnr092/samba:latest
```

### ⚙️ Parámetros de Configuración
Las siguientes variables de entorno se pueden definir en tu archivo .env para personalizar el comportamiento del servidor Samba.

|Variable de Entorno | Función | Valor por Defecto | Notas |
|-|-|-|-|
|TZ |Zona horaria del contenedor.|Etc/UTC|Importante para logs y sincronización horaria.|
|SMB_WORKGROUP|Grupo de trabajo o dominio de Samba.|WORKGROUP|Debe coincidir con el grupo de tu red.|
|SMB_NETBIOS_NAME|Nombre NetBIOS del servidor Samba.|samba|Nombre con el que el servidor será visible en la red.|
|SMB_MIN_PROTOCOL|Protocolo SMB mínimo permitido (ej. SMB2, SMB3).|SMB2|Asegura compatibilidad con clientes modernos.|
|SMB_MAX_PROTOCOL|Protocolo SMB máximo permitido (ej. SMB3).|SMB3|Permite el uso de las últimas características SMB.|
|SMB_ENCRYPT|Requisito de cifrado para conexiones SMB (if_required, mandatory, no).|if_required|mandatory exige cifrado, if_required lo usa si el cliente lo soporta.|
|SAMBA_USER|Nombre de usuario para autenticación en Samba.|testuser|¡IMPRESCINDIBLE CAMBIAR EN PRODUCCIÓN!|
|SAMBA_PASS|Contraseña para el SAMBA_USER.|testpass|¡IMPRESCINDIBLE CAMBIAR EN PRODUCCIÓN!|