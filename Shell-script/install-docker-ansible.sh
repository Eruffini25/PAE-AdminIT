#!/bin/bash

# Chemin absolu vers le dossier Ansible
ANSIBLE_DIR="$(cd "$(dirname "$0")/../Ansible-script" && pwd)"

# Nom de l'image personnalisée
IMAGE_NAME="my-ansible-env"

# Création d’un Dockerfile si absent
DOCKERFILE_PATH="$(dirname "$0")/Dockerfile"
if [ ! -f "$DOCKERFILE_PATH" ]; then
  echo "[INFO] Création du Dockerfile personnalisé..."
  cat > "$DOCKERFILE_PATH" <<EOF
FROM cytopia/ansible:latest

RUN apk update && apk add openssh nano bash
EOF
fi

# Build de l’image Docker
echo "[INFO] Construction de l'image Docker '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" "$(dirname "$0")"

# Lancement du conteneur Ansible
echo "[INFO] Lancement du conteneur Docker avec Ansible..."
docker run -it --rm \
  --name ansible-gitlab \
  -v "$ANSIBLE_DIR":/ansible \
  -v "/home/adminit/.ssh/id_ed25519":/root/.ssh/id_ed25519:ro \
  -w /ansible \
  "$IMAGE_NAME" /bin/sh
