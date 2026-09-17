#!/bin/bash
# Copyright 2025 German Cancer Research Center (DKFZ) and contributors.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail
shopt -s nullglob

while [[ $# -gt 0 ]]; do
    case "$1" in
        --input_directory)  export nnUNet_input="${2:?--input_directory needs a value}";  shift 2 ;;
        --output_directory) export nnUNet_output="${2:?--output_directory needs a value}"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

trap '[[ "${KEEP_INTERMEDIATES:-0}" == 1 ]] || rm -rf "${nnUNet_output:?}/tmp" "${nnUNet_output:?}/nnunet_data_dir"' EXIT
trap 'echo "terminated" >&2; exit 143' TERM INT

python /app/scripts/convert_dcm2nifti.py
if [[ "$MULTI_MODAL" == False ]]; then
    # modify filename as nnUNet for mono-modal Nifti data
    for file in "$nnUNet_output"/nnunet_data_dir/*.nii.gz; do
        filename=$(basename "$file")
        if [[ "$filename" == *_0000.nii.gz ]]; then
            continue
        fi
        base="${filename%.nii.gz}"
        new_name="${base}_0000.nii.gz"
        new_path="$nnUNet_output/nnunet_data_dir/$new_name"

        mv "$file" "$new_path"
        echo "Renamed $filename to $new_name"
    done
fi
nnUNet_predict -i "$nnUNet_output/nnunet_data_dir" -o "$nnUNet_output/tmp" -t "${TASK_NAME:?}" -tr nnUNetTrainerV2 -p nnUNetPlansv2.1 -m 3d_fullres
python /app/scripts/convert_nifti2dcmseg.py
