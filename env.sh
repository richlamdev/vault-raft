export VAULT_ADDR="http://127.0.0.1:8200"

HOST_STRING="template"
SLD_STRING="middleearth"
TLD_STRING="test"
DOMAIN_STRING="${SLD_STRING}.${TLD_STRING}"
SUBJECT_CN_STRING="${HOST_STRING}.${DOMAIN_STRING}"
ISSUER_NAME_CN_STRING="Lord of the Rings"

VAULT_ROLE_STRING="common_vault_role"
NO_TLS_STRING="-tls-skip-verify"
KEY_TYPE_STRING="ec"
KEY_BITS_STRING="256"

IP_SAN1_STRING="192.168.60.6"
ALT_NAME1_STRING="${SUBJECT_CN_STRING}"

#IP_SAN2_STRING=""
#ALT_NAME2_STRING=""
TTL_STRING="9552h"
