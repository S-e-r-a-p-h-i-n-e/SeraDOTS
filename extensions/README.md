# Extensions

## What it is
A collection of compositor-session–scoped augmentation layers that translate global environment intent into spatial, visual, or interactive behavior.

## What it does
Houses compositor-aware logic such as window manager configurations, compositor-specific UI layers, and session augmentations that assume the presence of a display backend (Wayland or X11).

Extensions are optional by design: they are not required for the core environment to initialize, but they shape how a graphical session behaves, looks, and feels.

## Purpose
To provide a clean, isolated sandbox for session-level differentiation without polluting `core/`, `optionals/`, or `userland/`.

Extensions may be opinionated, backend-specific, and impure. If an extension fails or is removed, the base environment and application convergence layers remain intact.

**Extensions may consume the core contract, but must never define or override it.**