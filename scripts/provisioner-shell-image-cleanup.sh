#!/bin/bash

set -exuo pipefail

# Cleaning apt since we no longer need it's caches.
sudo apt clean

# And truncate machine-id since cloud-init does it weirdly.
sudo truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id

# No longer packer.
sudo rm /var/tmp/packer