# Userland (Application Configs)

## What it is
The collection of configurations for user-facing applications (Rofi, Waybar, Kitty, Zsh, Wallust, etc.).

## What it does
Dictates the appearance and specific behavior of the applications you interact with daily. These applications are downstream consumers of the system.

## Purpose
Purely swappable plugins. Applications in this directory should rely on the `core/` environment variables and `services/` for logic. They should never attempt to manage system state on their own. If an application in Userland is deleted, the system will continue to function normally.