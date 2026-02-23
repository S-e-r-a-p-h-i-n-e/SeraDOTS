# Optionals (Environment Overrides)

## What it is
A secondary environment loading phase for non-critical or user-specific variables.

## What it does
Loads variables that deal with UI toolkits (like forcing Wayland for Qt/GTK via `20-toolkits.env`) and personal user preferences (`90-user-prefs.sh`). 

## Purpose
Keeps `core/00-core.env` clean and strictly focused on system-critical paths. It allows the user to tweak toolkit rendering engines or subjective preferences without risking a failure in the main bootstrapper.

**Optionals are loaded after core/ and before any compositor logic.**