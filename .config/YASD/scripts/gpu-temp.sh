#!/bin/bash
if command -v nvidia-smi &> /dev/null; then
    # NVIDIA
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | awk '{print $1"°C"}'
elif sensors | grep -q 'amdgpu'; then
    # AMD
    sensors | grep -E 'edge|junction' | head -n 1 | awk '{print $2}' | tr -d '+'
else
    # Intel / Fallback to CPU
    sensors | grep 'Package id 0' | awk '{print $4}' | tr -d '+'
fi