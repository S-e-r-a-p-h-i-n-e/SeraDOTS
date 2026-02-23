# Core (The Contract & Bootstrapper)

## What it is
The absolute heart of the SeraDOTS architecture. It contains the environment definitions (`env/`) and the primary startup sequence (`session/`).

## What it does
It evaluates the host machine, calculates necessary paths and variables, and exports them as a strictly POSIX-compliant environment *before* any graphical session or daemon starts. It then safely hands off execution to the chosen window manager.

## Purpose
This acts as the "Single Source of Truth." By relying on environment variables (`00-core.env`) rather than hardcoded paths or systemd targets, the entire ecosystem becomes init-agnostic and distribution-agnostic. Every tool and script downstream reads from this contract.

**Nothing outside this directory may define or mutate core environment variables.**