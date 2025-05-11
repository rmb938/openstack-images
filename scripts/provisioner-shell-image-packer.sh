#!/bin/bash

set -exuo pipefail

# Placing a packer file that systemd can condition off of.
# If this file exists applications shouldn't start.
#   For example in a systemd unit
#   ConditionPathExists=!/var/tmp/packer
# Using /var/tmp/ because it's persistent if we reboot during packer.
sudo touch /var/tmp/packer