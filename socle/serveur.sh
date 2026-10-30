#!/usr/bin/env bash
# Le démarrage du travailleur à la requête (25/10, PA55.3) : ComfyUI en arrière-plan, puis le gestionnaire
# de RunPod (handler.py, worker-comfyui 5.11.0) qui reçoit les travaux et les lui passe.
#
# Repris de src/start.sh du travailleur officiel, réduit à ce qui nous sert : ComfyUI vit dans /opt/ComfyUI
# (l'image de la carte), pas dans /comfyui ; ni SSH ni ComfyUI-Manager ici.
#
# ComfyUI n'écoute que sur 127.0.0.1 : le gestionnaire est sur la même machine, personne d'autre n'a à
# le joindre (règle du 28/09). SERVIR_EN_LOCAL=1 lance le gestionnaire en petit serveur HTTP, lui aussi
# sur 127.0.0.1, pour un essai sur une machine à nous (docker run … -e SERVIR_EN_LOCAL=1).
set -u

# Le même allocateur que le travailleur officiel, s'il est dans l'image (sinon rien ne change).
TCMALLOC="$(ldconfig -p 2>/dev/null | grep -Po 'libtcmalloc.so.\d' | head -n 1)"
[ -n "$TCMALLOC" ] && export LD_PRELOAD="$TCMALLOC"

# La carte répond-elle, et ce PyTorch a-t-il ses noyaux ? Un échec ici se lit en clair dans le journal du
# travailleur, au lieu d'un « serveur injoignable » trompeur au premier travail.
if ! python3 -c "import torch; torch.cuda.init(); print('carte :', torch.cuda.get_device_name(0), torch.__version__, 'CUDA', torch.version.cuda); (torch.zeros(8, device='cuda') + 1).sum().item()"; then
    echo "serveur.sh : la carte ne répond pas à ce PyTorch (CUDA 13 : pilote 580 ou plus ; variante cu128 : pilote 570 ou plus)" >&2
    exit 1
fi

cd /opt/ComfyUI
python3 -u main.py --listen 127.0.0.1 --port 8188 --disable-auto-launch --disable-metadata \
    --verbose "${COMFY_LOG_LEVEL:-INFO}" --log-stdout &
echo $! > /tmp/comfyui.pid

cd /
if [ "${SERVIR_EN_LOCAL:-}" = "1" ]; then
    exec python3 -u /handler.py --rp_serve_api --rp_api_host=127.0.0.1
fi
exec python3 -u /handler.py
