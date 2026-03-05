#!/bin/bash

# setup-local-dns.sh
# Maps *.watcher.local to the Minikube IP in /etc/hosts

set -e

MINIKUBE_IP=$(minikube ip)
DOMAINS=("grafana.watcher.local" "prometheus.watcher.local" "alertmanager.watcher.local")

echo "Detected Minikube IP: $MINIKUBE_IP"

for DOMAIN in "${DOMAINS[@]}"; do
    if grep -q "$DOMAIN" /etc/hosts; then
        echo "Updating entry for $DOMAIN..."
        sudo sed -i.bak "s/.*$DOMAIN/$MINIKUBE_IP $DOMAIN/" /etc/hosts
    else
        echo "Adding entry for $DOMAIN..."
        echo "$MINIKUBE_IP $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
    fi
done

echo "Local DNS setup complete."
echo "You can now access:"
echo "  http://grafana.watcher.local"
echo "  http://prometheus.watcher.local"
echo "  http://alertmanager.watcher.local"

echo ""
echo "Note: For wildcard support (*.watcher.local), consider installing dnsmasq:"
echo "  echo \"address=/.watcher.local/$MINIKUBE_IP\" | sudo tee /usr/local/etc/dnsmasq.d/watcher.conf"
