#!/bin/bash

# Load required kernel modules
modprobe br_netfilter
modprobe nf_nat
modprobe xt_REDIRECT
modprobe xt_owner
modprobe iptable_nat
modprobe iptable_mangle
modprobe iptable_filter

# Ensure modules are loaded on reboot
cat <<EOF > /etc/modules-load.d/istio-modules.conf
br_netfilter
nf_nat
xt_REDIRECT
xt_owner
iptable_nat
iptable_mangle
iptable_filter
EOF

echo done