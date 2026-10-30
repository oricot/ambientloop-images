# MiniMax H3 SOUS CUDA 12.8 (30/10, PA55 — go d'Olivier : « lance la création de l'image adaptée et commençons les
# tests ») : le même service que services/h3, sur le socle de la variante cu128. Pourquoi : le point d'entrée filtré en
# CUDA 13.0 n'a obtenu aucun serveur deux soirs (27 et 30/10) ; sans filtre, RunPod en trouve en 26 s.
#
# LE FORMAT EST fp8_scaled : int8_convrot exige un PyTorch en CUDA 13 (sans lui il tourne, lentement) ; sous CUDA 12
# l'installeur de la carte choisit fp8_scaled, le repli officiel de MiniMax, et c'est aussi le nom que config.py écrit.
# L'encodeur de texte nvfp4_awq ne demande pas de Blackwell (l'éditeur). Pilote 570 ou plus (CUDA 12.8 à 13.0 sur le
# point d'entrée). Le rendu se juge sur les deux clips de l'essai (tir, scenes/pa55-essai-serverless).
# Dépôt Comfy-Org/MiniMax-H3 au commit relevé le 25/10, empreintes = oid LFS publiés.
ARG SOCLE=ghcr.io/oricot/serverless-socle-cu128:8713616
FROM ${SOCLE}
ARG MMX=https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/e5eb578a89295337b8ff433a035929ce0279e0b6

RUN descendre-poids "$MMX/diffusion_models/minimax_h3_fl2va_pruned_fp8_scaled.safetensors" diffusion_models \
        12944c1f7791637e7de12208aef04da82bd26b95271b1b47d817364315ade993
RUN descendre-poids "$MMX/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" text_encoders \
        35a88d51044231fe332301d7a62aa81e3f2cba62febeb446e2c1e3e0ef76f2c6
RUN descendre-poids "$MMX/vae/minimax_h3_video_vae_fp16.safetensors" vae \
        7c1f131492e7eddacaac9069a61b81bdd39de5cc96561e677c5eab1cdce5e522
RUN descendre-poids "$MMX/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors" loras \
        2339acdf19bfe123f46b971ea35d367a84adb85de43627e1eceafa5a5b2b111e
# Le décodeur audio : le nœud le réclame, il rend aussi la bande sonore (installer.sh, 24/08).
RUN descendre-poids "$MMX/vae/minimax_h3_audio_vae_fp32.safetensors" vae \
        8e505d95dd1561d47abd43d4238fd40d9bb1ae9e147ed0a4cba778d76ae4db48

RUN printf 'service h3 (cu128, fp8_scaled)\n' >> /opt/IMAGE
