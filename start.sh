#!/bin/sh
set -euo pipefail  # Más estricto: -e (exit on error), -u (unset vars), -o pipefail (falla en pipes)

# Configuración básica del sistema
echo "Estableciendo zona horaria => ${TZ}"
ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
echo "${TZ}" > /etc/timezone

# Validación de variables críticas
if [[ -z "${SAMBA_USER:-}" || -z "${SAMBA_PASS:-}" ]]; then
    echo "ERROR: Las variables SAMBA_USER y SAMBA_PASS deben estar definidas." >&2
    exit 1
fi

sed -i "s/SMB_WORKGROUP/${SMB_WORKGROUP}/g" config/smb.conf
sed -i "s/SMB_SERVER_STRING/${SMB_SERVER_STRING}/g" config/smb.conf
sed -i "s/SMB_NETBIOS_NAME/${SMB_NETBIOS_NAME}/g" config/smb.conf
sed -i "s/SMB_MIN_PROTOCOL/${SMB_MIN_PROTOCOL}/g" config/smb.conf
sed -i "s/SMB_MAX_PROTOCOL/${SMB_MAX_PROTOCOL}/g" config/smb.conf
sed -i "s/SMB_NAME_RESOLVE_ORDER/${SMB_NAME_RESOLVE_ORDER}/g" config/smb.conf
sed -i "s/SMB_ENCRYPT/${SMB_ENCRYPT}/g" config/smb.conf
sed -i "s/SMB2_MAX_CREDITS/${SMB2_MAX_CREDITS}/g" config/smb.conf

# Creación de usuario/grupo con permisos seguros
if ! getent group "$SAMBA_USER" >/dev/null; then
    addgroup -g 1000 "$SAMBA_USER" || { echo "Error al crear el grupo"; exit 1; }
fi

if ! id "$SAMBA_USER" >/dev/null 2>&1; then
    adduser -D -H -G "$SAMBA_USER" -s /bin/false -u 1000 "$SAMBA_USER" || { echo "Error al crear el usuario"; exit 1; }
fi

# Configuración de contraseña Samba
echo "Configurando Samba para ${SAMBA_USER}..."
if ! (echo "${SAMBA_PASS}"; echo "${SAMBA_PASS}") | smbpasswd -a -s "${SAMBA_USER}"; then
    echo "ERROR: Fallo al configurar Samba. Verifica:" >&2|
    echo "1. El usuario existe (id ${SAMBA_USER})" >&2
    echo "2. El archivo /etc/samba/smb.conf es válido" >&2
    smbpasswd -L -d 3  # Modo debug
    exit 1
fi

# Permisos seguros para archivos críticos
chmod 640 /config/smb.conf
chown root:root /config/smb.conf

# Inicio de Supervisor (sin permisos de root)
exec supervisord -c /config/supervisord.conf