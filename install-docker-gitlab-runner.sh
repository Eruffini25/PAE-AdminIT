#!/bin/bash

echo "🔐 Token d'enregistrement GitLab :"
read -rp "Token : " TOKEN

echo "🏷️  Tag(s) pour ce runner (ex: ansible,docker) :"
read -rp "Tags : " TAGS

echo "🌐 URL de GitLab (ex: http://192.168.192.143:8080) :"
read -rp "URL : " GITLAB_URL

DESCRIPTION="runner-$TAGS"
IMAGE="debian:12"

echo ""
echo "[INFO] Enregistrement du runner (via Docker) avec les paramètres suivants :"
echo " - URL         : $GITLAB_URL"
echo " - Token       : $TOKEN"
echo " - Tags        : $TAGS"
echo " - Description : $DESCRIPTION"
echo " - Image       : $IMAGE"
echo ""

docker run --rm -it \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner register \
  --non-interactive \
  --url "$GITLAB_URL" \
  --token "$TOKEN" \
  --executor "docker" \
  --docker-image "$IMAGE" \
  --description "$DESCRIPTION" \
  --tag-list "$TAGS" \
  --run-untagged="true" \
  --locked="false"

echo "[INFO] ⏳ Attente de la création du fichier de configuration GitLab Runner..."

for i in {1..30}; do
    if [ -f /srv/gitlab-runner/config/config.toml ]; then
        echo "[INFO] ✅ Fichier config.toml détecté."
        break
    fi
    sleep 1
done

docker run -d --name gitlab-runner \
  --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner
