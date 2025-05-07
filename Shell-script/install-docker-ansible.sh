#!/bin/bash

# Couleurs
INFO="[INFO]"
OK="✅"
ERR="❌"

# Demander l'IP
read -p "Entrez l'adresse IP de GitLab CE : " IP_GITLAB

# Fichier inventory
INVENTORY_FILE="inventory-serveur"

# Vérifie que le fichier existe
if [ ! -f "$INVENTORY_FILE" ]; then
  echo "$INFO $ERR Le fichier $INVENTORY_FILE n'existe pas."
  exit 1
fi

# Vérifie si la section [gitlabce] est présente, sinon l'ajoute
if ! grep -q "^\[gitlabce\]" "$INVENTORY_FILE"; then
  echo "$INFO $OK Ajout de la section [gitlabce] dans $INVENTORY_FILE"
  echo -e "\n[gitlabce]" >> "$INVENTORY_FILE"
fi

# Supprimer une ancienne IP si présente
sed -i "/^[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}$/d" "$INVENTORY_FILE"

# Ajouter la nouvelle IP
echo "$IP_GITLAB" >> "$INVENTORY_FILE"
echo "$INFO $OK Fichier $INVENTORY_FILE mis à jour avec l'IP $IP_GITLAB"

# Télécharger l'image Ansible Docker si besoin
echo "$INFO 🔽 Téléchargement de l’image willhallonline/ansible:latest..."
docker pull willhallonline/ansible:latest

# Lancer Ansible via Docker
echo "$INFO 🚀 Lancement du conteneur Ansible et exécution du playbook..."
docker run --rm -it \
  -v "$PWD":/ansible \
  -w /ansible \
  willhallonline/ansible:latest \
  ansible-playbook -i "$INVENTORY_FILE" deploy-gitlab-ce.yml

