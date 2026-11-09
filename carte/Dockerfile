# ComfyUI déjà installé, pour la carte louée — 24/10 (CF23 ; Olivier : « ton idée de docker est la bonne
# solution oui » ; étude : notes/etude-image-docker-24-10.md).
#
# Écrite dans tools/pod/image/ du projet, déplacée ici le 25/10 (PA55.3) : c'est ce dépôt que GitHub
# construit. Elle sert deux fois — telle quelle pour la carte, et comme base du socle à la requête
# (socle/Dockerfile).
#
# CE QUI EST DEDANS : ce que tools/pod/installer.sh pose aujourd'hui sur la carte, sauf les poids —
# ComfyUI et l'extension de contrôle de Krea 2, tous deux à un commit fixé, et les bibliothèques
# Python qu'ils demandent, torch épinglé à celui de l'image de base. Ni poids, ni clé, ni rien de
# nous : l'image est publique. Les poids descendent sur le disque de la machine à chaque allumage
# (installeur, .part puis renommage) et ComfyUI les voit arriver sans redémarrer.
#
# LA BASE est celle que `tools/pod.sh creer` loue déjà (POD_IMAGE par défaut) : même CUDA 13, même
# PyTorch, même serveur SSH de RunPod. Rien ne change pour la carte, sauf qu'il n'y a plus rien à poser.
#
# ComfyUI vit dans /opt/ComfyUI, hors de /workspace : le volume réseau, quand il y en a un, se monte
# sur /workspace et masquerait ce qui y serait.
# LA BASE se choisit à la construction (30/10, PA55) : CUDA 13 par défaut ; la variante « cu128 » (même PyTorch 2.9.1, CUDA
# 12.8.1, pilote 570 ou plus) pour le tir à la demande, qui n'obtient aucun serveur filtré en CUDA 13.0 (deux soirs).
ARG BASE=runpod/pytorch:1.1.0-cu1300-torch291-ubuntu2404
FROM ${BASE}

# Le commit de ComfyUI : celui qui tire sur la carte, relevé sur le volume d'Islande le 24/10 au soir
# (0.41.3, du 17/10 ; Klein et H3 y ont tiré le 24/10). Une image construite sur la pointe du dépôt ne
# se reproduit pas.
ARG COMFY_COMMIT=8713616fcc321624e306bbd36be5906203dcb0dc
# L'extension de profondeur de Krea 2 : le commit contrôlé le 12/10 (installer.sh, KREA_CN_COMMIT).
ARG KREA_CN_DEPOT=facok/comfyui-krea2-controlnet
ARG KREA_CN_COMMIT=79ebfd3bd80d2180b334dd7ce57f3c9ddaa0848f

RUN test -n "$COMFY_COMMIT" || { echo "COMFY_COMMIT manque" >&2; exit 1; }

# aria2 : l'installeur descend les poids avec, en seize connexions (85 Mo/s depuis Hugging Face).
RUN apt-get update \
 && apt-get install -y --no-install-recommends aria2 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git init -q ComfyUI \
 && cd ComfyUI \
 && git remote add origin https://github.com/comfyanonymous/ComfyUI.git \
 && git fetch -q --depth 1 origin "$COMFY_COMMIT" \
 && git checkout -q FETCH_HEAD \
 && test "$(git rev-parse HEAD)" = "$COMFY_COMMIT"

# Les bibliothèques de ComfyUI — le même ordre que l'installeur, pour les mêmes raisons (installer.sh,
# 25/08 et 04/09) : torch épinglé à celui de l'image, torchvision posé d'abord, seul, depuis l'index
# PyTorch de son CUDA, puis épinglé à son tour ; ensuite seulement requirements.txt.
WORKDIR /opt/ComfyUI
RUN set -e; \
    CU=$(python3 -c "import torch;print(torch.version.cuda or '')"); \
    IDX="https://download.pytorch.org/whl/cu$(echo "$CU" | tr -d '.')"; \
    echo "torch==$(python3 -c "import torch;print(torch.__version__.split('+')[0])")" > /tmp/contrainte.txt; \
    pip install -q --no-cache-dir --break-system-packages torchvision --constraint /tmp/contrainte.txt --index-url "$IDX"; \
    echo "torchvision==$(python3 -c "import torchvision;print(torchvision.__version__.split('+')[0])")" >> /tmp/contrainte.txt; \
    pip install -q --no-cache-dir --break-system-packages -r requirements.txt \
        --constraint /tmp/contrainte.txt --extra-index-url "$IDX"; \
    cp /tmp/contrainte.txt /opt/contrainte-torch.txt; \
    python3 -c "import torch, torchvision; print('torch', torch.__version__, 'torchvision', torchvision.__version__)"

# L'extension de contrôle de Krea 2 : deux fichiers Python, ni install.py ni requirements.txt
# (contrôlée le 12/10, notes/chaine-qwen-depth-carte-12-10.md).
RUN git init -q "custom_nodes/$(basename "$KREA_CN_DEPOT")" \
 && cd "custom_nodes/$(basename "$KREA_CN_DEPOT")" \
 && git remote add origin "https://github.com/$KREA_CN_DEPOT.git" \
 && git fetch -q --depth 1 origin "$KREA_CN_COMMIT" \
 && git checkout -q FETCH_HEAD \
 && test "$(git rev-parse HEAD)" = "$KREA_CN_COMMIT"

# MUSUBI-TUNER, TO TRAIN THE KREA 2 MODULE ON OUR CARD (variante « entrainement », 09/11, VS61 ; Olivier 09/11 : « on fait les premier
# tests sur une H100 si on trouve un prix inférieru a 1euro ou une RTX pro 6000 » ; notes/finance/module-sur-notre-carte-09-11.md) :
# empty MUSUBI_COMMIT, nothing changes. Set : kohya-ss/musubi-tuner at a fixed commit (0.3.6, 27/09), in its own environment
# /opt/musubi/.venv that sees the system's torch (--system-site-packages, torch pinned by /opt/contrainte-torch.txt) and takes its
# own pinned libraries (transformers, diffusers, accelerate…) without touching ComfyUI's. Checked before (CLAUDE.md, 22/08) :
# Apache-2.0 ; no setup.py nor install script (hatchling) ; in the Krea 2 path (krea2_*.py, krea2/, networks/lora_krea2.py,
# hv_train_network.py), nothing sent out — the only uploads are behind --huggingface_repo_id, never passed ; the only download is
# the Qwen3-VL-4B tokenizer (public), fetched HERE at a fixed revision so the card runs offline (HF_HUB_OFFLINE=1). No weights :
# the card fetches Krea 2 Raw from the open copy (tools/pod/entrainer.sh), checked by its hash. Run by tools/pod/entrainer.sh.
ARG MUSUBI_COMMIT=
ARG QWEN_TOKENIZER_REV=ebb281ec70b05090aa6165b016eac8ec08e71b17
RUN if [ -n "$MUSUBI_COMMIT" ]; then set -e; \
      git init -q /opt/musubi && cd /opt/musubi \
      && git remote add origin https://github.com/kohya-ss/musubi-tuner.git \
      && git fetch -q --depth 1 origin "$MUSUBI_COMMIT" && git checkout -q FETCH_HEAD \
      && test "$(git rev-parse HEAD)" = "$MUSUBI_COMMIT"; \
      python3 -m venv --system-site-packages /opt/musubi/.venv; \
      /opt/musubi/.venv/bin/pip install -q --no-cache-dir -e . --constraint /opt/contrainte-torch.txt; \
      HF_HOME=/opt/musubi/hf /opt/musubi/.venv/bin/python -c "from huggingface_hub import snapshot_download as s; \
s('Qwen/Qwen3-VL-4B-Instruct', revision='$QWEN_TOKENIZER_REV', allow_patterns=['*.json', '*.txt', '*.jinja'])"; \
      /opt/musubi/.venv/bin/python -c "import torch, transformers, diffusers, accelerate; \
import musubi_tuner.krea2_train_network; print('musubi ok', torch.__version__, transformers.__version__)"; \
      rm -rf /opt/musubi/.git; \
    fi

# Ce que l'image porte, lisible sur la machine sans rien lancer : `cat /opt/IMAGE`.
RUN printf 'comfyui %s\nkrea2-controlnet %s\nmusubi-tuner %s\n' "$COMFY_COMMIT" "$KREA_CN_COMMIT" "${MUSUBI_COMMIT:-aucun}" > /opt/IMAGE \
 && cat /opt/contrainte-torch.txt >> /opt/IMAGE

LABEL org.opencontainers.image.description="ComfyUI preinstalled on the RunPod CUDA 13 PyTorch base, no weights"
