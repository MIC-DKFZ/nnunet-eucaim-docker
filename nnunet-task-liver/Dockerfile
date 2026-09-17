# Copyright 2025 German Cancer Research Center (DKFZ) and contributors.
# SPDX-License-Identifier: Apache-2.0

# Dockerfile for nnUNet task images
# Author: Ashis Ravindran, DKFZ
# Builds image nnunet:base
FROM nnunet:base
ARG MULTI_MODAL=False

# Maintainer information
LABEL maintainer="ashis.ravindran@dkfz-heidelberg.de"
LABEL version="1.0"
LABEL description="nnUNet model pretrained on Task029_LiTS targeting are liver and liver tumor."
LABEL image.source="https://github.com/MIC-DKFZ/nnunet-eucaim-docker"
LABEL image.revision=""
LABEL image.version="1.0"

USER eucaim
ENV TASK_NAME=Task029_LiTS
ENV MULTI_MODAL=$MULTI_MODAL
# The pretrained model is published with a different capitalisation than the
# one the nnU-Net runtime looks up (Task029_LITS vs Task029_LiTS).
RUN nnUNet_download_pretrained_model $TASK_NAME
RUN set -eu; \
    root="$RESULTS_FOLDER/nnUNet"; \
    for d in "$root"/*/; do \
        d="${d%/}"; \
        if [ -d "$d/$TASK_NAME" ]; then continue; fi; \
        alt="$(find "$d" -mindepth 1 -maxdepth 1 -type d -iname "$TASK_NAME" -print -quit 2>/dev/null || true)"; \
        if [ -n "$alt" ]; then ln -s "$alt" "$d/$TASK_NAME"; fi; \
    done; \
    if [ ! -d "$root/3d_fullres/$TASK_NAME/nnUNetTrainerV2__nnUNetPlansv2.1" ]; then \
        echo "no 3d_fullres model for $TASK_NAME under $root" >&2; \
        find "$root" -maxdepth 2 >&2; exit 1; \
    fi

CMD ["/bin/bash", "/app/start_nnunet.sh" ]
HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD python /app/scripts/health_check.py || exit 1

# Commands:
# docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-liver-tumour:latest .
# docker push harbor.eucaim.cancerimage.eu/processing-tools/nnunet-liver-tumour:latest
# docker run --rm \
# -v $(pwd)/toy_datasets:/home/eucaim/nnUNet_input \  # mounting data volume (read only)
# -v $(pwd)/toy_out:/home/eucaim/nnUNet_output \      # mounting sandbox to save output (read and write)
# --gpus all \
# nnunet-liver-tumour:latest                          # image to run
