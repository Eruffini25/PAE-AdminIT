#!/bin/bash

# Couleurs
INFO="[INFO]"
OK="✅"
ERR="❌"

# Résout le chemin absolu du dossier Ansible-script
ANSIBLE_DIR="$(cd "$(dirname "$0")/../Ansible-script" && pwd)"

# Chemin du fichier inventory
INVENTORY_FILE="$ANSIBLE_DIR/inventory-runner"


# Vérifie que le fichier existe
if [ ! -f "$INVENTORY_FILE" ]; then
  echo "$INFO $ERR Le fichier $INVENTORY_FILE n'existe pas."
  exit 1
fi

# Demande à l'utilisateur les informations nécessaires
read -p "Adresse IP de GitLab CE (ex: 192.168.192.143) : " GITLAB_IP
read -p "Port de GitLab CE (par défaut 80) : " GITLAB_PORT
GITLAB_PORT=${GITLAB_PORT:-80}
read -p "Token de registration du runner : " TOKEN
read -p "Tag du runner (défaut: debian-runner) : " RUNNER_TAG
RUNNER_TAG=${RUNNER_TAG:-debian-runner}

# Supprimer les anciennes lignes de config dans la section [gitlabrunner:vars]
awk '/^\[gitlabrunner:vars\]/ {flag=1; print; next} /^\[.*\]/ {flag=0} !flag || (flag && !/^(gitlab_url|registration_token|runner_tags)=/)' "$INVENTORY_FILE" > tmp_inventory

# Ajouter les nouvelles variables
echo "gitlab_url=http://$GITLAB_IP:$GITLAB_PORT" >> tmp_inventory
echo "registration_token=$TOKEN" >> tmp_inventory
echo "runner_tags=$RUNNER_TAG" >> tmp_inventory

# Télécharger l'image Ansible Docker si besoin
echo "$INFO 🔽 Téléchargement de l’image willhallonline/ansible:latest..."
docker pull willhallonline/ansible:latest

# Écraser l'ancien fichier
mv tmp_inventory "$INVENTORY_FILE"

echo "$INFO Fichier inventory mis à jour avec succès."

# Lancer Ansible via Docker
echo "$INFO 🚀 Lancement du conteneur Ansible et exécution du playbook..."

docker run -it --rm \
  --name ansible-gitlab \
  -v "$ANSIBLE_DIR":/ansible \
  -v "$HOME/.ssh/id_ed25519":/root/.ssh/id_ed25519:ro \
  -w /ansible \
  willhallonline/ansible:latest \
  ansible-playbook -i inventory-runner deploy-gitlab-runner.yml
