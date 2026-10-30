# MAKE YOUR PICTURE, une commande entière sur une seule machine (30/10, PA55.3 — Olivier : « oui. et donc ok pour qwen ») :
# Krea 2 Turbo (+ les modules des crans du corps), puis Qwen 2.1 édition, sortie de Krea 2 et visage en images 1 et 2 —
# ce que tools/commandes.py écrit pour la carte. serverless-krea2 reste tel quel.
#
# LA MÉMOIRE, en CUDA 13 : Krea 2 Turbo fp8_scaled 13,14 + encodeur 5,24 + décodeur ≈ 18,7 Go ; Qwen 2.1 int8_convrot
# 7,26 + encodeur 9,35 + décodeur 0,68 = 17,3 Go ; les deux résidents ≈ 36 Go, plus le calcul : le palier 48 Go suffit.
# En CUDA 12 Qwen 2.1 n'existe qu'en bf16 (32,4 Go) : ComfyUI devrait décharger Krea 2 entre les deux étapes — d'où le
# socle CUDA 13 (le palier 48 Go en trouve). Le pic réel se mesure au premier tirage (tir).
#
# LES MODULES DES CRANS (poitrine-v2, fesses-f1-v2) : nos fichiers, JAMAIS dans ce dépôt (public) — ils descendent d'un
# dépôt Hugging Face PRIVÉ (TotalRico/ambientloop-modules, le compte Hugging Face d'Olivier), avec un jeton en lecture passé comme secret de construction
# (secrets.HF_TOKEN de GitHub) : il ne reste dans aucune couche de l'image. Empreintes vérifiées. Olivier, 30/10 : le dépôt
# privé de GitHub n'a pas la place de construire (43 Go libres), « 1 oui je suis ta reco ».
# Sous leur nom, dans loras/ : le graphe les nomme comme sur la carte (avec_modules, le client d'image du projet).
ARG SOCLE=ghcr.io/oricot/serverless-socle:8713616
FROM ${SOCLE}
ARG KREA=https://huggingface.co/Comfy-Org/Krea-2/resolve/1171f4dc7e325bf3734586942e737872506c73e1
ARG QWEN=https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/aacf31a6d48e707f352ecba714cee0680da3479b
ARG MODULES=https://huggingface.co/TotalRico/ambientloop-modules/resolve/main

RUN descendre-poids "$KREA/diffusion_models/krea2_turbo_fp8_scaled.safetensors" diffusion_models \
        eb4dd8c612cfd10f64f25b057e6e6bbcb5737c94a7372177e456dbf7579502f1
RUN descendre-poids "$KREA/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" text_encoders \
        54bd5144df0bbc25dd6ccadfcb826b521445a1b06ae5a42570bdd2974ca87094
RUN descendre-poids "$KREA/vae/qwen_image_vae.safetensors" vae \
        a70580f0213e67967ee9c95f05bb400e8fb08307e017a924bf3441223e023d1f
RUN descendre-poids "$QWEN/diffusion_models/qwen_image_2.1_int8_convrot.safetensors" diffusion_models \
        cb74113cb03faecd79611b01fd7fd642f0aa60d6f0b95086abee214d75eaa57d
RUN descendre-poids "$QWEN/text_encoders/qwen3vl_8b_int8_convrot.safetensors" text_encoders \
        8bfd0f6e12abf2d2d697ecc888e5e90b0d6741d6708f05799f53afa560452e8f
RUN descendre-poids "$QWEN/vae/qwen_image_2.1_vae_bf16.safetensors" vae \
        bb21f7473051e1ac368515dd3f2e15cd44d7a11748ee8823e1ddca3e4876b7c9

RUN --mount=type=secret,id=hf_token,required=true \
    mkdir -p /opt/ComfyUI/models/loras && cd /opt/ComfyUI/models/loras \
 && for f in poitrine-v2 fesses-f1-v2; do \
        curl -fsSL --retry 3 -H "Authorization: Bearer $(cat /run/secrets/hf_token)" -o "$f.safetensors" \
             "$MODULES/$f.safetensors" || exit 1; \
    done \
 && printf '%s  %s\n' \
        24c2acd5d3bf88920a084984099928c85ed17c985d914b8ceb19a1731aafd07f poitrine-v2.safetensors \
        06be93ed343ba85622819f931015c9c6910034cef81208c308fba03590e7ae42 fesses-f1-v2.safetensors | sha256sum -c -

RUN printf 'service picture (krea2 turbo fp8 + qwen 2.1 int8 + modules poitrine-v2, fesses-f1-v2)\n' >> /opt/IMAGE
