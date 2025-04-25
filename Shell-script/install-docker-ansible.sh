#!/bin/bash

# Résout le chemin absolu du dossier Ansible-script
ANSIBLE_DIR="$(cd "$(dirname "$0")/../Ansible-script" && pwd)"

# Nom de l'image à utiliser
IMAGE_NAME="willhallonline/ansible:latest"

# Vérifie si l’image existe localement, sinon la télécharge
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "[INFO] 🔽 Téléchargement de l’image $IMAGE_NAME..."
  docker pull "$IMAGE_NAME"
fi

# Lancement du conteneur Ansible prêt à l'emploi
echo "[INFO] 🚀 Lancement du conteneur Ansible avec SSH, Sh, etc."
docker run -it --rm \
  --name ansible-gitlab \
  -v "$ANSIBLE_DIR":/ansible \
  -v "$HOME/.ssh/id_ed25519":/root/.ssh/id_ed25519:ro \
  -w /ansible \
  "$IMAGE_NAME" /bin/sh
