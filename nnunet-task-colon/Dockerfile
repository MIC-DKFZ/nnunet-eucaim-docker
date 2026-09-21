# Copyright 2025 German Cancer Research Center (DKFZ) and contributors.
# SPDX-License-Identifier: Apache-2.0

# Dockerfile for nnUNet task images
# Author: Ashis Ravindran, DKFZ
# Built on top of image nnunet:base-1.0.0
FROM nnunet:base-1.0.0
ARG MULTI_MODAL=False

# Maintainer information
LABEL maintainer="ashis.ravindran@dkfz-heidelberg.de"
LABEL version="1.0.0"
LABEL description="nnUNet model pretrained on Task010_Colon targeting are colon cancer primaries."
LABEL image.source="https://github.com/MIC-DKFZ/nnunet-eucaim-docker"
LABEL image.revision=""
LABEL image.version="1.0.0"

ENV TASK_NAME=Task010_Colon
ENV MULTI_MODAL=$MULTI_MODAL
RUN nnUNet_download_pretrained_model $TASK_NAME \
    && chown -R eucaim:eucaim $RESULTS_FOLDER

CMD ["/bin/bash", "/app/start_nnunet.sh" ]
HEALTHCHECK --interval=60s --timeout=10s --start-period=300s --retries=3 \
  CMD python /app/scripts/health_check.py || exit 1

# Commands:
# docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-colon-cancer:latest .
# docker push harbor.eucaim.cancerimage.eu/processing-tools/nnunet-colon-cancer:latest
# docker run --rm \
# -v $(pwd)/toy_datasets:/home/eucaim/nnUNet_input \  # mounting data volume (read only)
# -v $(pwd)/toy_out:/home/eucaim/nnUNet_output \      # mounting sandbox to save output (read and write)
# --gpus all \
# nnunet-colon-cancer:latest                          # image to run