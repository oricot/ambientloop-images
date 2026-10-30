# MiniMax H3, image de début et de fin + à chaud (25/10, PA55.3) : le socle plus les cinq fichiers du jeu
# « minimax-fl » de la carte, 44,43 Go — remplace l'image de septembre (jeu à références, recette C).
#
# LE FORMAT EST int8_convrot, comme sur la carte : l'installeur le choisit sous CUDA 13, et le socle est en
# CUDA 13. config.py écrit fp8_scaled ; côté client, tools/serverless.py lit les fichiers de ce Dockerfile
# et le rattrapage de format (variante_presente) envoie le bon nom. Exige une machine à pilote 580 ou plus
# (CUDA 13) : à régler sur le point d'entrée.
# Dépôt Comfy-Org/MiniMax-H3 au commit relevé le 25/10, empreintes = oid LFS publiés.
ARG SOCLE=ghcr.io/oricot/serverless-socle:8713616
FROM ${SOCLE}
ARG MMX=https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/e5eb578a89295337b8ff433a035929ce0279e0b6

RUN descendre-poids "$MMX/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors" diffusion_models \
        e889202c41dafb67b10d67b97f0d8541508036a6090af23425a5c2615d03c47a
RUN descendre-poids "$MMX/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" text_encoders \
        35a88d51044231fe332301d7a62aa81e3f2cba62febeb446e2c1e3e0ef76f2c6
RUN descendre-poids "$MMX/vae/minimax_h3_video_vae_fp16.safetensors" vae \
        7c1f131492e7eddacaac9069a61b81bdd39de5cc96561e677c5eab1cdce5e522
RUN descendre-poids "$MMX/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors" loras \
        2339acdf19bfe123f46b971ea35d367a84adb85de43627e1eceafa5a5b2b111e
# Le décodeur audio : le nœud le réclame, il rend aussi la bande sonore (installer.sh, 24/08).
RUN descendre-poids "$MMX/vae/minimax_h3_audio_vae_fp32.safetensors" vae \
        8e505d95dd1561d47abd43d4238fd40d9bb1ae9e147ed0a4cba778d76ae4db48

RUN printf 'service h3\n' >> /opt/IMAGE
