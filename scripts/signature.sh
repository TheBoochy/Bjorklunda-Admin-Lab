#!/bin/bash
echo "============================================================"
echo "Name:      Vulkan"
echo "Email:     whatever@gmail.com"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Hostname:  $(hostname)"
echo "IP:        $(hostname -I | awk '{print $1}')"
echo "============================================================"