# nnUNet EUCAIM Docker
Copyright (c) [German Cancer Research Center (DKFZ)](https://www.dkfz.de). All rights reserved.
Please make sure that your usage of this code is in compliance with its [license](LICENSE).
This project is supported by EUCAIM grant number is 101100633.

This repository provides Docker images for running [nnUNet](https://github.com/MIC-DKFZ/nnUNet/tree/nnunetv1) inference in a reproducible and containerized environment, tailored for the EUCAIM project.

---

## Setup

To build all task-specific nnUNet images, run:

```bash
docker build  --build-arg USER_UID=2323  --build-arg USER_GID=2323 -t "nnunet:base" nnunet-base/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-pancreas-tumour:latest nnunet-task-pancreas/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/ nnunet-abdominal-organ-segmentation:latest nnunet-task-abdominal/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/ nnunet-brain-tumour-pet:latest  nnunet-task-abdominal/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/ nnunet-colon-cancer:latest nnunet-task-abdominal/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/ nnunet-liver-tumour:latest nnunet-task-abdominal/
```

You may optionally specify the user UID and GID to avoid permission issues when running containers.

### Image Hierarchy
* `nnunet:base`: Built first, this image includes all the necessary environment dependencies. Uses the official NVIDIA CUDA Ubuntu 22.04 runtime: `nvidia/cuda:11.8.0-runtime-ubuntu22.04`.
* `nnunet-<organ task>:latest`: Built on top of `nnunet:base`, each task-specific image includes the corresponding pretrained model checkpoint (downloaded at build time).

## Usage
Each container expects two mounted directories for I/O:
* Input: `/home/eucaim/nnUNet_input`
* Output: `/home/eucaim/nnUNet_output`

Your DICOM series folders containing `.dcm` files should be placed inside the input directory. The container processes them sequentially and writes the segmentation outputs to the output directory using the same filenames.

Expected dataset structure:
```
dataset/
├── study_001/
│   ├── series_001/
│   │   ├── IMG0001.dcm
│   │   ├── IMG0002.dcm
│   │   └── ...
│   ├── series_002/
│   │   ├── IMG0001.dcm
│   │   ├── IMG0002.dcm
│   │   └── ...
│   └── ...
├── study_002/
│   ├── series_001/
│   │   ├── IMG0001.dcm
│   │   ├── IMG0002.dcm
│   │   └── ...
│   └── ...
└── ...
```

### Example

To run inference using the image for Liver Tumor, execute:
```bash
docker run \
  -v /host/dataset/study_001:/home/eucaim/nnUNet_input \
  -v /host/data_out:/home/eucaim/nnUNet_output \
  --gpus all \
  nnunet-liver-tumour:latest
```

## Data Format Conventions
* All input must as DICOM series folders.
* All files in the input folder will be processed in batch.
* Output files are written with identical filenames into the output folder.

## Notes
A patched version nnUNet source is placed in the `nnunet-base` folder for installation purposes at build time. As soon as the issue https://github.com/MIC-DKFZ/nnUNet/issues/2876 is fixed, direct git clone from official would be possible.

