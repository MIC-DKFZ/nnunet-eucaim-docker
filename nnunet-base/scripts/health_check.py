# Copyright 2025 German Cancer Research Center (DKFZ) and contributors.
# SPDX-License-Identifier: Apache-2.0
import os, sys, time

MAX_QUIET_SECONDS = 30 * 60

def newest_mtime(root):
    newest = os.path.getmtime(root)
    for dirpath, dirnames, filenames in os.walk(root):
        for name in dirnames + filenames:
            try:
                newest = max(newest, os.path.getmtime(os.path.join(dirpath, name)))
            except OSError:
                pass
    return newest


def is_healthy():
    try:
        output_dir = os.getenv("nnUNet_output", "/home/eucaim/nnUNet_output")
        if not os.path.isdir(output_dir):
            return False
        return newest_mtime(output_dir) > time.time() - MAX_QUIET_SECONDS
    except Exception:
        return False


if __name__ == "__main__":
    sys.exit(0 if is_healthy() else 1)
