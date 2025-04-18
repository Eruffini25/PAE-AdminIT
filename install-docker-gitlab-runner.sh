#!/bin/bash

echo "Token d'enregistrement GitLab :"
read -rp "Token : " TOKEN

echo "Tag pour ce runner (ex: ansible,docker) :"
read -rp "Tags : " TAGS

echo "URL du gitlab :"
read -rp "Url : " GITLAB_URL


# Définir d'autres variables fixes
#GITLAB_URL="http://192.168.192.143:8080"
DESCRIPTION="runner-$TAGS"
IMAGE="debian:12"

echo ""
echo "[INFO] Enregistrement du runner avec les paramètres suivants :"
echo " - URL         : $GITLAB_URL"
echo " - Token       : $TOKEN"
echo " - Tags        : $TAGS"
echo " - Description : $DESCRIPTION"
echo " - Image       : $IMAGE"
echo ""

# Exécution de la commande
gitlab-runner register \
  --non-interactive \
  --url "$GITLAB_URL" \
  --registration-token "$TOKEN" \
  --executor "docker" \
  --docker-image "$IMAGE" \
  --description "$DESCRIPTION" \
  --tag-list "$TAGS" \
  --run-untagged="true" \
  --locked="false"
