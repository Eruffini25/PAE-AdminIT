#!/bin/bash

# Couleurs
INFO="[INFO]"
OK="✅"
ERR="❌"

# Demander l'IP
read -p "Entrez l'adresse IP de GitLab CE : " IP_GITLAB

# Résout le chemin absolu du dossier Ansible-script
ANSIBLE_DIR="$(cd "$(dirname "$0")/../Ansible-script" && pwd)"

# Chemin du fichier inventory
INVENTORY_FILE_SERV="$ANSIBLE_DIR/inventory-serveur"
INVENTORY_FILE_RUN="$ANSIBLE_DIR/inventory-runner"


# Vérifie que le fichier existe
if [ ! -f "$INVENTORY_FILE_SERV" ]; then
  echo "$INFO $ERR Le fichier $INVENTORY_FILE_SERV n'existe pas."
  exit 1
fi

# Vérifie si la section [gitlabce] est présente, sinon l'ajoute
if ! grep -q "^\[gitlabce\]" "$INVENTORY_FILE_SERV"; then
  echo "$INFO $OK Ajout de la section [gitlabce] dans $INVENTORY_FILE_SERV"
  echo -e "\n[gitlabce]" >> "$INVENTORY_FILE_SERV"
fi

echo $IP_GITLAB >> "$INVENTORY_FILE_SERV"

# Télécharger l'image Ansible Docker si besoin
echo "$INFO 🔽 Téléchargement de l’image willhallonline/ansible:latest..."
docker pull willhallonline/ansible:latest

# Lancer Ansible via Docker
echo "$INFO 🚀 Lancement du conteneur Ansible et exécution du playbook..."

docker run -it --rm \
  --name ansible-gitlab \
  -v "$ANSIBLE_DIR":/ansible \
  -v "$HOME/.ssh/id_ed25519":/root/.ssh/id_ed25519:ro \
  -w /ansible \
  willhallonline/ansible:latest \
  ansible-playbook -i inventory-serveur deploy-gitlab-ce.yml
