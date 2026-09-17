# Copyright 2025 German Cancer Research Center (DKFZ) and contributors.
# SPDX-License-Identifier: Apache-2.0

# Dockerfile for nnUNet task images
# Author: Ashis Ravindran, DKFZ
# Built on top of image nnunet:base-1.0.0
FROM nnunet:base-1.0.0
ARG TASK_NAME
ARG MULTI_MODAL=False

# Maintainer information
LABEL maintainer="ashis.ravindran@dkfz-heidelberg.de"
LABEL version="1.0"
LABEL description=""
LABEL image.source=""
LABEL image.revision="commit-sha"
LABEL image.version="tag-or-version"

ENV TASK_NAME=$TASK_NAME
ENV MULTI_MODAL=$MULTI_MODAL
RUN nnUNet_download_pretrained_model $TASK_NAME

CMD ["/bin/bash", "/app/start_nnunet.sh" ]
HEALTHCHECK --interval=60s --timeout=10s --start-period=300s --retries=3 \
  CMD python /app/scripts/health_check.py || exit 1

# Commands:
# docker build -t nnunet:heart --build-arg TASK_NAME=Task002_Heart .
# docker run -v /home/a178n/DKFZ/eucaim_work/test_input:/home/eucaim/nnUNet_input -v /home/a178n/DKFZ/eucaim_work/test_out:/home/eucaim/nnUNet_output --gpus all nnunet:Task002_Heart 