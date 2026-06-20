#!/bin/bash

# Bjorklunda Admin Lab
# Script: create_idm_users_groups.sh
# Purpose: Create IdM groups, users, and group memberships for the Linux identity environment.

set -e

echo "======================================"
echo "Bjorklunda Admin Lab - IdM user setup"
echo "======================================"
echo

echo "Checking Kerberos ticket..."
if ! klist >/dev/null 2>&1; then
    echo "No active Kerberos ticket found."
    echo "Run this first:"
    echo "kinit admin"
    exit 1
fi

echo "Kerberos ticket found."
echo

IDM_GROUPS=(
    "linuxitusers"
    "linuxhrusers"
    "linuxfinanceusers"
    "linuxeducationusers"
)

echo "Creating IdM groups..."
for IDM_GROUP in "${IDM_GROUPS[@]}"; do
    if ipa group-show "$IDM_GROUP" >/dev/null 2>&1; then
        echo "Group already exists: $IDM_GROUP"
    else
        ipa group-add "$IDM_GROUP" --desc="Bjorklunda Linux group $IDM_GROUP"
        echo "Created group: $IDM_GROUP"
    fi
done

echo

echo "Creating IdM users..."

create_user_if_missing() {
    USERNAME="$1"
    FIRSTNAME="$2"
    LASTNAME="$3"
    IDM_GROUP="$4"

    if ipa user-show "$USERNAME" >/dev/null 2>&1; then
        echo "User already exists: $USERNAME"
    else
        ipa user-add "$USERNAME" --first="$FIRSTNAME" --last="$LASTNAME" --random
        echo "Created user: $USERNAME"
    fi

    ipa group-add-member "$IDM_GROUP" --users="$USERNAME" >/dev/null 2>&1 || true
    echo "Ensured membership: $USERNAME -> $IDM_GROUP"
}

create_user_if_missing "linuxit01" "Linux" "IT01" "linuxitusers"
create_user_if_missing "linuxhr01" "Linux" "HR01" "linuxhrusers"
create_user_if_missing "linuxfinance01" "Linux" "Finance01" "linuxfinanceusers"
create_user_if_missing "linuxeducation01" "Linux" "Education01" "linuxeducationusers"

echo
echo "IdM user and group creation completed."
