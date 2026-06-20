#!/bin/bash

# Bjorklunda Admin Lab
# Script: verify_idm_users_groups.sh
# Purpose: Verify IdM users, groups, and group memberships.

echo "=========================================="
echo "Bjorklunda Admin Lab - IdM verification"
echo "=========================================="
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

echo "IdM users:"
echo "----------"
ipa user-find linux || true

echo

echo "IdM groups:"
echo "-----------"
ipa group-find linux || true

echo

echo "Group memberships:"
echo "------------------"

IDM_GROUPS=(
    "linuxitusers"
    "linuxhrusers"
    "linuxfinanceusers"
    "linuxeducationusers"
)

for IDM_GROUP in "${IDM_GROUPS[@]}"; do
    echo
    echo "Members of $IDM_GROUP:"
    ipa group-show "$IDM_GROUP" || true
done

echo
echo "IdM verification completed."
