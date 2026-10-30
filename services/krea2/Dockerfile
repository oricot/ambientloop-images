# Krea 2 Turbo, texte -> image (25/10, PA55.3) : le socle plus les trois fichiers du jeu « krea2 » de la carte
# (tools/pod/installer.sh du projet), 18,64 Go. Mêmes noms que sur la carte : config.py, COMFY_IMAGE_RULES
# « krea2-turbo ». Dépôt Comfy-Org/Krea-2 au commit relevé le 25/10, empreintes = oid LFS publiés.
# Une carte plus petite suffit (protocole, mesure 3) : c'est une raison de plus d'avoir son propre point d'entrée.
ARG SOCLE=ghcr.io/oricot/serverless-socle:8713616
FROM ${SOCLE}
ARG KREA=https://huggingface.co/Comfy-Org/Krea-2/resolve/1171f4dc7e325bf3734586942e737872506c73e1

# Un fichier par couche : une machine neuve les descend en parallèle.
RUN descendre-poids "$KREA/diffusion_models/krea2_turbo_fp8_scaled.safetensors" diffusion_models \
        eb4dd8c612cfd10f64f25b057e6e6bbcb5737c94a7372177e456dbf7579502f1
RUN descendre-poids "$KREA/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" text_encoders \
        54bd5144df0bbc25dd6ccadfcb826b521445a1b06ae5a42570bdd2974ca87094
RUN descendre-poids "$KREA/vae/qwen_image_vae.safetensors" vae \
        a70580f0213e67967ee9c95f05bb400e8fb08307e017a924bf3441223e023d1f

RUN printf 'service krea2\n' >> /opt/IMAGE
