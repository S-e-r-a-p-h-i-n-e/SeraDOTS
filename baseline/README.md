# Baseline (The Canvas)

## What it is
This directory contains the foundational Window Manager (WM) and compositor configurations (e.g., Sway, SwayFX). 

## What it does
It defines the visual workspace, the window rules, and the raw keyboard/mouse bindings. It is explicitly stripped of complex logic, daemon management, and environment variables.

## Purpose
In this agnostic architecture, the WM is treated as a highly disposable "dumb terminal." It does not dictate the system state. Its only job is to map user inputs (like a keypress) to the agnostic scripts located in `../services/`. This ensures that switching from Sway to Hyprland requires zero changes to the underlying system logic defined in core and services.