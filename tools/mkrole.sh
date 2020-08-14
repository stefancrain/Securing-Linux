#!/bin/bash
echo "Enter a new role name"
read ROLE_INPUT
ROLE="ansible_role_"$(echo "$ROLE_INPUT" | sed -e "s# #_#g" -e "s#-#_#g" |  tr '[:upper:]' '[:lower:]')
ROLE_DIR="./roles/$ROLE"

echo "Creating role for $ROLE"

ansible-galaxy init --role-skeleton="./tools/role-skeleton" --init-path "./roles" --offline "$ROLE" --force
gsed --in-place --expression "s/SKELYEAR/$(date +%Y)/" "${ROLE_DIR}/LICENSE"
gsed --in-place --expression "s/SKELYEAR/$(date +%Y)/" "${ROLE_DIR}/README.md"
gsed --in-place --expression "s/SKELYEAR/$(date +%Y)/" "${ROLE_DIR}/USAGE.md"

