#!/bin/bash

# Demande l’IP de GitLab CE
read -rp "Entrez l'adresse IP de GitLab CE : " GITLAB_IP

# Résout le chemin absolu du dossier Ansible-script
ANSIBLE_DIR="$(cd "$(dirname "$0")/../Ansible-script" && pwd)"

# Chemin du fichier inventory
INVENTORY_FILE="$ANSIBLE_DIR/inventory"

# Mise à jour de l’IP dans la section [gitlabce]
# Ne modifie que la première occurrence de x.x.x.x
if [[ -f "$INVENTORY_FILE" ]]; then
  sed -i "/^\[gitlabce\]/,/^\[/ s/x\.x\.x\.x/$GITLAB_IP/" "$INVENTORY_FILE"
  echo "[INFO] ✅ Fichier inventory mis à jour avec l'IP $GITLAB_IP"
else
  echo "[ERREUR] ❌ Fichier inventory introuvable à l’emplacement : $INVENTORY_FILE"
  exit 1
fi

# Nom de l'image à utiliser
IMAGE_NAME="willhallonline/ansible:latest"

# Vérifie si l’image existe localement, sinon la télécharge
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "[INFO] 🔽 Téléchargement de l’image $IMAGE_NAME..."
  docker pull "$IMAGE_NAME"
fi

# Lancement du conteneur Ansible et exécution du playbook
echo "[INFO] 🚀 Lancement du conteneur Ansible et exécution du playbook..."
docker run -it --rm \
  --name ansible-gitlab \
  -v "$ANSIBLE_DIR":/ansible \
  -v "$HOME/.ssh/id_ed25519":/root/.ssh/id_ed25519:ro \
  -w /ansible \
  "$IMAGE_NAME" ansible-playbook -i inventory deploy-gitlab-ce.yml
