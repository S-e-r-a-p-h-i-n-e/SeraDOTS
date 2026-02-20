# SeraDOTS 🌙

**A work in progress distribution-agnostic, init-agnostic Wayland dotfiles**

SeraDOTS is a reference implementation of a modern Linux desktop built around a strict contract: **design against the least capable environment first, and allow more capable environments to extend it.** 

This project aims to be modular and understandable. It is not a distro, and it is not a one-size-fits-all rice.

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
* A working **Sway** reference profile.
* A fully usable Wayland desktop.
* Script-driven theming via Wallust.
* Clean separation between **core**, **baseline**, and **optional extensions**.

This repository serves as a working system with its configurations transparent by design. In here, everything has a reason, and those reasons are meant to be easily understood no matter the experience.

## 📈 Status
* **Core and Baseline**: Completed
* **Qt and GTK integration:** In progress
* **Extensions:** Once theming and featureset is finalized
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

## ⚠️ Disclaimer

This project is a work in progress. Breaking changes may happen while the architecture is refined. However, the **design and layout is stable**, the **baseline is usable**, and regressions are avoided intentionally.
