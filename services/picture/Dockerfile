# MAKE YOUR PICTURE, une commande entière sur une seule machine (30/10, PA55.3 — Olivier : « oui. et donc ok pour qwen ») :
# Krea 2 Turbo (+ les modules des crans du corps). Qwen 2.1 édition en est sorti le 01/11 (go 535G et 278A, Olivier : sa licence interdit
# la vente) ; restent qwen3vl_4b et qwen_image_vae, l'encodeur et le décodeur que Krea 2 charge. serverless-krea2 reste tel quel.
#
# LA MÉMOIRE, en CUDA 13 : Krea 2 Turbo fp8_scaled 13,14 + encodeur 5,24 + décodeur ≈ 18,7 Go, plus le calcul. Le palier se
# remesure sur cette image (tir).
#
# LES MODULES DES CRANS (poitrine-v2, fesses-f1-v2) : nos fichiers, JAMAIS dans ce dépôt (public) — ils descendent d'un
# dépôt Hugging Face PRIVÉ (TotalRico/ambientloop-modules, le compte Hugging Face d'Olivier), avec un jeton en lecture passé comme secret de construction
# (secrets.HF_TOKEN de GitHub) : il ne reste dans aucune couche de l'image. Empreintes vérifiées. Olivier, 30/10 : le dépôt
# privé de GitHub n'a pas la place de construire (43 Go libres), « 1 oui je suis ta reco ».
# Sous leur nom, dans loras/ : le graphe les nomme comme sur la carte (avec_modules, le client d'image du projet).
ARG SOCLE=ghcr.io/oricot/serverless-socle:8713616
FROM ${SOCLE}
ARG KREA=https://huggingface.co/Comfy-Org/Krea-2/resolve/1171f4dc7e325bf3734586942e737872506c73e1
ARG MODULES=https://huggingface.co/TotalRico/ambientloop-modules/resolve/main

RUN descendre-poids "$KREA/diffusion_models/krea2_turbo_fp8_scaled.safetensors" diffusion_models \
        eb4dd8c612cfd10f64f25b057e6e6bbcb5737c94a7372177e456dbf7579502f1
RUN descendre-poids "$KREA/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" text_encoders \
        54bd5144df0bbc25dd6ccadfcb826b521445a1b06ae5a42570bdd2974ca87094
RUN descendre-poids "$KREA/vae/qwen_image_vae.safetensors" vae \
        a70580f0213e67967ee9c95f05bb400e8fb08307e017a924bf3441223e023d1f

RUN --mount=type=secret,id=hf_token,required=true \
    mkdir -p /opt/ComfyUI/models/loras && cd /opt/ComfyUI/models/loras \
 && for f in poitrine-v2 fesses-f1-v2; do \
        curl -fsSL --retry 3 -H "Authorization: Bearer $(cat /run/secrets/hf_token)" -o "$f.safetensors" \
             "$MODULES/$f.safetensors" || exit 1; \
    done \
 && printf '%s  %s\n' \
        24c2acd5d3bf88920a084984099928c85ed17c985d914b8ceb19a1731aafd07f poitrine-v2.safetensors \
        06be93ed343ba85622819f931015c9c6910034cef81208c308fba03590e7ae42 fesses-f1-v2.safetensors | sha256sum -c -

RUN printf 'service picture (krea2 turbo fp8 + modules poitrine-v2, fesses-f1-v2)\n' >> /opt/IMAGE
