#!/bin/bash

# Dossier contenant tes fichiers ansible
ANSIBLE_DIR="../Ansible-script/"

docker run -it --rm \
  --name ansible-gitlab \
  -v "$ANSIBLE_DIR":/ansible \
  -v "/home/adminit/.ssh/id_ed25519":/root/.ssh:ro \
  -w /ansible \
  cytopia/ansible:latest /bin/bash
  