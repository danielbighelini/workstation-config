#!/usr/bin/env bash

set -e

cd ~/workspace/workstation-config/ansible

sudo ansible-playbook playbooks/workstation.yml
