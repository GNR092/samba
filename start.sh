#!/bin/bash
set -e

addgroup -g 1000 $SAMBA_USER && adduser -D -H -G $SAMBA_USER -s /bin/false -u 1000 $SAMBA_USER

echo -e "$SAMBA_PASS\n$SAMBA_PASS" | smbpasswd -a -s -c /config/smb.conf $SAMBA_USER 2>/dev/null

exec supervisord -c /config/supervisord.conf