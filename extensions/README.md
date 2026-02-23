# Extensions

## What it is
A repository for modular add-ons and optional, scoped capability layers that build on top of the base contract.

## What it does
Houses supplementary logic (like custom compositor wrappers or session modifiers) that are not strictly required for the core system to boot, but add specific, layered functionality.

## Purpose
To provide a clean sandbox for expanding the system's capabilities without polluting the `core/` or `services/` directories. If an extension breaks, the baseline system remains completely intact.

**Extensions may consume the core contract, but must never redefine it.**