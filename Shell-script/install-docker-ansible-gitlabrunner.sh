#!/bin/bash

# Couleurs
INFO="[INFO]"
OK="✅"
ERR="❌"

# Résout le chemin absolu du dossier Ansible-script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$SCRIPT_DIR/../Ansible-script"

# Chemin du fichier inventory
INVENTORY_FILE="$ANSIBLE_DIR/inventory-runner"

# Vérifie que le fichier existe
if [ ! -f "$INVENTORY_FILE" ]; then
  echo "$INFO $ERR Le fichier $INVENTORY_FILE n'existe pas."
  exit 1
fi

# Demande des informations à l'utilisateur
read -p "Adresse IP de GitLab CE (ex: 192.168.192.143) : " GITLAB_IP
read -p "Token de registration du runner : " TOKEN
read -p "Tag du runner (défaut: debian-runner) : " RUNNER_TAG
RUNNER_TAG=${RUNNER_TAG:-debian-runner}
read -p "Adresse IP de la machine GitLab Runner : " RUNNER_IP

# Mise à jour de la section [gitlabrunner] avec la bonne IP
awk -v newip="$RUNNER_IP" '
  /^\[gitlabrunner\]/ {print; print newip; skip=1; next}
  /^\[/ && skip {skip=0}
  !skip
' "$INVENTORY_FILE" > tmp_inventory_1

# Mise à jour des variables de la section [gitlabrunner:vars]
awk '/^\[gitlabrunner:vars\]/ {flag=1; print; next} /^\[.*\]/ {flag=0} !flag || (flag && !/^(gitlab_url|registration_token|runner_tags)=/)' tmp_inventory_1 > tmp_inventory

# Ajout des nouvelles valeurs
echo "gitlab_url=http://$GITLAB_IP" >> tmp_inventory
echo "registration_token=$TOKEN" >> tmp_inventory
echo "runner_tags=$RUNNER_TAG" >> tmp_inventory

# Remplacement du fichier final
mv tmp_inventory "$INVENTORY_FILE"
rm -f tmp_inventory_1

echo "$INFO 🔽 Téléchargement de l’image willhallonline/ansible:latest..."
docker pull willhallonline/ansible:latest

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
