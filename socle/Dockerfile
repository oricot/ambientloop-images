# Le socle des images à la requête (25/10, PA55.3) : l'image de la carte, plus le gestionnaire de RunPod.
# Aucun poids : chaque service (services/<nom>/Dockerfile) part d'ici et n'ajoute que les siens.
#
# POURQUOI UN SOCLE COMMUN ET UNE IMAGE PAR SERVICE (notes/sujets/PA55.md, PA55.3) : une image commune à
# tous les poids ferait ~95 Go — au-delà de ce que la construction chez GitHub a tenu (52,8 Go en
# septembre) et des 80 Go que RunPod documente — et chaque machine neuve la descendrait entière pour
# servir un seul modèle. Avec un socle partagé, une machine qui a déjà une de nos images ne descend plus
# que les poids de l'autre : les couches du socle sont les mêmes.
#
# LE MÊME COMFYUI QUE LA CARTE : on part de l'image de la carte (carte/Dockerfile), pas de celle du
# travailleur officiel (runpod/worker-comfyui), qui porte son propre ComfyUI, CUDA 12.8 et un autre
# PyTorch. Ce qu'on reprend du travailleur officiel, c'est son gestionnaire seul — handler.py et
# network_volume.py, version 5.11.0 (commit b7574c8), copiés tels quels et lus le 25/10 : il ne parle qu'au
# ComfyUI local (127.0.0.1:8188) ; il n'envoie vers un stockage que si BUCKET_ENDPOINT_URL est posé, ce
# qu'on ne fait pas. Licence AGPL-3.0, jointe (LICENSE-worker-comfyui) ; ce dépôt est public.
ARG CARTE=ghcr.io/oricot/comfyui-carte:8713616
FROM ${CARTE}

# Les bibliothèques du gestionnaire, à des versions fixées : runpod 1.7.13 est celle que l'épinglage du
# travailleur officiel (runpod~=1.7.12) choisit aujourd'hui. Le torch de l'image reste intouché.
RUN pip install -q --no-cache-dir --break-system-packages \
        runpod==1.7.13 websocket-client==1.9.2 requests==2.34.2 \
        --constraint /opt/contrainte-torch.txt

COPY handler.py network_volume.py serveur.sh /
COPY descendre-poids /usr/local/bin/descendre-poids
RUN chmod +x /serveur.sh /usr/local/bin/descendre-poids

# L'essai de démarrage, sans carte : ComfyUI s'importe en entier (tous ses nœuds) puis s'arrête. Une
# dépendance qui casse le démarrage casse ici la construction, et pas le premier travail d'un client.
RUN cd /opt/ComfyUI && timeout 300 python3 main.py --quick-test-for-ci --cpu

RUN printf 'gestionnaire worker-comfyui 5.11.0 (b7574c8), runpod 1.7.13\n' >> /opt/IMAGE

# Remplace le démarrage de l'image de la carte (SSH, Jupyter) : un travailleur à la requête n'en a pas.
# Le point d'entrée de NVIDIA (nvidia_entrypoint.sh) reste devant, comme sur la carte.
CMD ["/serveur.sh"]
