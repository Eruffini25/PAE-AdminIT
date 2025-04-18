#!/bin/bash

echo "[INFO] 📁 Création des volumes persistants..."
mkdir -p /srv/gitlab/config /srv/gitlab/logs /srv/gitlab/data

# Récupération de l'adresse IP de la machine
IP_MACHINE=$(hostname -I | awk '{print $1}')

echo "[INFO] 🚀 Lancement de GitLab CE en Docker..."
docker run --detach \
  --hostname $IP_MACHINE:8080 \
  --publish 8080:80 --publish 8443:443 --publish 2222:22 \
  --name gitlab \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab \
  --volume /srv/gitlab/logs:/var/log/gitlab \
  --volume /srv/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest

echo "[INFO] ✅ GitLab CE lancé. Accès via : http://$IP_MACHINE:8080"
echo "[INFO] ⏳ Attente du fichier de mot de passe initial (max 60s)..."

# Attente jusqu'à ce que le fichier soit dispo
for i in {1..60}; do
    if docker exec gitlab test -f /etc/gitlab/initial_root_password; then
        break
    fi
    sleep 1
done

# Lecture du mot de passe
PASSWORD=$(docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null | awk '{print $2}')

echo "[INFO] 🌐 IP : http://$IP_MACHINE:8080"

if [ -n "$PASSWORD" ]; then
  echo "[INFO] 👤 User     : root"
  echo "[INFO] 🔑 Password : $PASSWORD"
else
  echo "[WARNING] ❌ Le mot de passe n’a pas pu être récupéré automatiquement."
  echo "[ASTUCE] 🔧 Tu peux le définir manuellement via :"
  echo "         docker exec -it gitlab gitlab-rails console"
  echo "         user = User.find_by_username('root')"
  echo "         user.password = 'TonMotDePasse'"
  echo "         user.password_confirmation = 'TonMotDePasse'"
  echo "         user.save!"
fi

# Affichage brut du mot de passe (pour automatisation si besoin)
#echo "$PASSWORD"
