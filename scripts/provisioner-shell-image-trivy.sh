#!/bin/bash

set -exuo pipefail

# Remove fwup keys, we don't need these anyway.
sudo rm -rf /var/lib/fwupd/pki/*

# Trivy for scanning for Vulns, installing manually in /tmp so it isn't left around.
# TODO: Not doing '--exit-code 1' on the trivy binary because it detects old kernel versions and fails https://github.com/aquasecurity/trivy/issues/3764.
#    There is no easy way to remove the old kernels, apt autoremove doesn't work since it seems to be hard coded to keep X amount.
# Skipping /dev, /proc, /sys, /run, /var/run, /tmp because they are memory fs, skipping /var/cache/apt & /var/lib/apt/lists since there is no point scanning apt cache's.
# Skipping /etc/ssh/ssh_host_*_key since it's suppose to exist anyway.

# Download and install
mkdir -p /tmp/trivy
curl -L -o /tmp/trivy.tar.gz https://github.com/aquasecurity/trivy/releases/download/v0.58.1/trivy_0.58.1_Linux-64bit.tar.gz
tar -xzvf /tmp/trivy.tar.gz -C /tmp/trivy

# Run
sudo /tmp/trivy/trivy fs --timeout 15m --skip-files '/etc/ssh/ssh_host_*_key' --skip-dirs /dev --skip-dirs /proc \
  --skip-dirs /sys --skip-dirs /run --skip-dirs /var/run --skip-dirs /tmp --skip-dirs /var/cache/apt \
  --skip-files /etc/ssl/private/ssl-cert-snakeoil.key \
  --skip-dirs /var/lib/apt/lists -s HIGH,CRITICAL --scanners vuln,misconfig,secret /

# Cleanup
sudo /tmp/trivy/trivy clean --all