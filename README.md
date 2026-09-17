# nnUNet EUCAIM Docker
Copyright (c) [German Cancer Research Center (DKFZ)](https://www.dkfz.de). All rights reserved.
Please make sure that your usage of this code is in compliance with its [license](LICENSE).
This project is supported by EUCAIM grant number is 101100633.

This repository provides Docker images for running [nnUNet](https://github.com/MIC-DKFZ/nnUNet/tree/nnunetv1) inference in a reproducible and containerized environment, tailored for the EUCAIM project.

---

## Setup

To build all task-specific nnUNet images, run:

```bash
docker build  --build-arg USER_UID=2323  --build-arg USER_GID=2323 -t "nnunet:base-1.0.0" nnunet-base/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-abdominal-organ-segmentation:1.0.0 nnunet-task-abdominal/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-brain-tumour-pet:1.0.0 nnunet-task-brain-pet/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-colon-cancer:1.0.0 nnunet-task-colon/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-hippocampus-segmentation:1.0.0 nnunet-task-hippocampus/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-kidney-tumour:1.0.0 nnunet-task-kidney/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-liver-tumour:1.0.0 nnunet-task-liver/
docker build -t harbor.eucaim.cancerimage.eu/processing-tools/nnunet-pancreas-tumour:1.0.0 nnunet-task-pancreas/
```

You may optionally specify the user UID and GID to avoid permission issues when running containers.

### Runtime contract

The image starts as root, runs `/app/entrypoint.sh`, and drops to a non-root
user with `gosu` before the tool runs. The caller controls that user:

| variable | default | effect |
|---|---|---|
| `HOST_UID` | `1000` | uid the tool runs as; output files are owned by it |
| `HOST_GID` | `1000` | requested gid — see the limitation below |
| `HOST_USER` | `eucaim` | user name to run as |

Input and output directories are given on the command line, and override the
`nnUNet_input` / `nnUNet_output` environment defaults:

```bash
docker run --rm --gpus all \
  -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) \
  -v "$PWD/input:/home/eucaim/nnUNet_input:ro" \
  -v "$PWD/output:/home/eucaim/nnUNet_output" \
  <image> /bin/bash /app/start_nnunet.sh \
  --input_directory /home/eucaim/nnUNet_input \
  --output_directory /home/eucaim/nnUNet_output
```

DICOM SEG files are written to a `segmentations/` subdirectory of the output
directory. The output directory does not need to be world-writable, provided
`HOST_UID` matches its owner. Set `KEEP_INTERMEDIATES=1` to retain the
NIfTI scratch directories when debugging a failed run.

**Known limitations**

- `HOST_GID` is accepted but not applied. `entrypoint.sh` creates the group
  only when no group named `$HOST_USER` exists, and this image creates
  `eucaim` at build time, so `usermod -u` changes the uid but leaves the
  primary group at the build-time gid. The script is supplied by EUCAIM and
  must not be modified, so this cannot be fixed here.
- Passing a `HOST_USER` other than `eucaim` creates a new user that does not
  own `nnUNet_output`, and the run fails on first write. Use the default, or
  point `--output_directory` at a directory the runtime user owns.

### Image Hierarchy
* `nnunet:base-1.0.0`: Built first, this image includes all the necessary environment dependencies. Uses the official NVIDIA CUDA Ubuntu 22.04 runtime: `nvidia/cuda:11.8.0-runtime-ubuntu22.04`.
* `nnunet-<organ task>:latest`: Built on top of `nnunet:base-1.0.0`, each task-specific image includes the corresponding pretrained model checkpoint (downloaded at build time).

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

