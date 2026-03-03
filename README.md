# SeraDOTS 🌙

**A work in progress distribution-agnostic, init-agnostic Wayland dotfiles**

SeraDOTS is a reference implementation of a modern Linux desktop built around a strict contract: **design against the least capable environment first, and allow more capable environments to extend it.** 

This project aims to be modular and understandable. It is not a distro, and it is not a one-size-fits-all rice. In here, Core defines what must work everywhere while Extensions define what works better somewhere.

These dotfiles does **NOT** aim to abstract away Wayland or the compositor. It is meant to be transparent, predictable, and easy to modify

---

## 🎯 Project Goals

SeraDOTS is designed with the following principles in mind:

* **WM-Agnostic**: **Sway** is the baseline compositor because it enforces strict Wayland constraints. More capable compositors (Hyprland, Niri, River, etc.) may extend the design.
* **Init-Agnostic**: No reliance on `systemd`-only features for correctness. The system must function on `systemd`, `runit`, `OpenRC`, `s6`, etc.
* **Least Common Denominator Contract**: The least capable environment defines the rules. Extensions may add features but never break the baseline.
* **Stability and Ease of Use First, Visuals Second**: Core behavior, environment loading, and correctness come before eye candy.

## 📦 What This Repository Is (Right Now)

At its current stage, SeraDOTS provides:

* A finished core environment and baseline.
* A working **Sway, SwayFX, Hyprland, and Niri** reference profile.
* A fully usable Wayland desktop.
* Script-driven theming via Wallust.
* Clean separation between **core**, **baseline**, and **optional extensions**.
* A Configuration Deployment Tool (Note that this does NOT install prerequisites like compositors and userland apps until further notice.)

This repository serves as a working system with its configurations transparent by design. In here, everything has a reason, and those reasons are meant to be easily understood no matter the experience.

## 📈 Status
* **Core and Baseline**: Completed
* **Qt and GTK integration:** Completed
* **Extensions:** In Progress
* **Installer:** Once everything is finalized (Hyprland and Niri)
* **Documentation:** Ongoing

## 📜 Philosophy of Project
* **Consistency over flash**
* **Correctness over convenience**
* **Architecture over aesthetics**

## 🤔 Is this for you?

Well, I don't really know but I will tell you this. If you:

* **are someone who want a lightweight Wayland desktop that just works**
* **are interested in a WM-agnostic dotfile design**
* **are studying system designs, system integration, and software engineering**
* **are a designer looking for a clean, modular template**
* **are tired of fragile, over-engineered configs, and personalized configs**

Then this project is probably for you.

---

## 🤍 Credits

Credits to:
* [NeKoRoSyS](https://github.com/NeKoRoSYS) for all the help and configs he's given me throughout this project. Feel free to check out NeKoRoSHELL [here](https://github.com/NeKoRoSYS/NeKoRoSHELL).
* [The HyDE Project](https://github.com/HyDE-Project) for the initial Rofi Layouts, Waybar Layouts and assets. You can check out HyDE [here](https://github.com/HyDE-Project/HyDE)
* [Nana-4 and The Materia-GTK Contributors](https://github.com/nana-4/materia-theme) for the Materia-GTK theme used for GTK.
* [The Papirus Development Team](https://github.com/PapirusDevelopmentTeam) for their port of the Materia-GTK theme to Qt and Kvantum

---

## ⚠️ Disclaimer

This project is a work in progress. Breaking changes may happen while the architecture is refined. However, the **design principles and conceptual layout are stable**, the **baseline is usable**, regressions are avoided intentionally, and installers are **not** included until applications look like they belong in the system, extensions are finished, and everything is documented.

For a minimal installation, the **core** is all you need. It defines the environmental contract and session behavior. After that you are free to set up the system however you like. 

You may use the included **baseline, extensions, optionals, services, and userland configs** at your discretion seeing how some parts of the services are NOT compositor agnostic and is made with the baseline in mind with the rest usable no matter the init system and distro.

Some folder layouts, scripts, and integration details may still be reorganized as the project is finalized.

Once it's finished, the sky is the limit.
