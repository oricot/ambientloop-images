# Flux 3 Image Klein, distillé, texte -> image et références (25/10, PA55.3) : le socle plus les trois fichiers
# du jeu « klein » de la carte, 20,31 Go. Prêt, construit seulement sur demande (le site ne s'en sert pas encore).
#
# Depuis la copie publique ml-resources/flux-3-image-klein-comfy, comme la carte (22/10) : le dépôt officiel de
# BFL demande un compte. Les empreintes sont celles du dépôt OFFICIEL (installer.sh, empreinte_attendue) — la
# copie au commit relevé le 25/10 les porte toutes les trois.
ARG SOCLE=ghcr.io/oricot/serverless-socle:8713616
FROM ${SOCLE}
ARG KLEIN=https://huggingface.co/ml-resources/flux-3-image-klein-comfy/resolve/3ba0f7064cbb1666a71e2820d3cc5c2273bb6cd0

RUN descendre-poids "$KLEIN/diffusion_models/flux3-image-klein-bf16.safetensors" diffusion_models \
        c3e9813cdd049c831c836b2e9db61150e49a93fc1a4c63b256494642fee0bd7c
RUN descendre-poids "$KLEIN/text_encoders/qwen3vl_4b_bf16.safetensors" text_encoders \
        f0b24fc5c8d7c0ea6ca909da14c20af5cac53f22506be942c6c956f838b9630f
RUN descendre-poids "$KLEIN/vae/flux2-vae.safetensors" vae \
        868fe7b343cc8f3a19dbcfcafbc3d5f888802be3f89bd81b65b3621a066ce8f3

RUN printf 'service klein\n' >> /opt/IMAGE
