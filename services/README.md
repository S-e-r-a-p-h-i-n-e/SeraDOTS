# Services (Agnostic Adapters)

## What it is
A collection of standalone, executable shell scripts categorized by function (input, media, power, system, theme, ui).

## What it does
These scripts act as translation layers. When the WM receives a keypress (e.g., "SUPER + SHIFT + T to change the waybar layout."), it calls a service script here. The script reads the core environment contract, figures out the current state, and executes the actual underlying binary.

## Purpose
To decouple logic from the Window Manager. By keeping all execution logic here, the system achieves true modularity. You can swap out your audio server, your screenshot tool, or your app launcher by updating a single service script, touching zero lines of your WM config.

**Services may execute commands and read state, but must never export new environment variables.**