# 🧠 Nix Disk Usage Cheat Sheet (Flakes Edition)

## 🔍 1. See what’s preventing GC

```bash
nix-store --gc --print-roots | rg -v /proc
```

👉 Anything listed here = **will NOT be deleted**

---

## 📦 2. Find big stuff (what eats space)

### Quick overview

```bash
nix store gc --print-live | xargs nix path-info -Sh | sort -h
```

### Best tool (install once)

```bash
nix profile add nixpkgs#nix-du
nix-du -s=500MB
```

---

## 💣 3. The usual suspects

### 🧨 direnv (BIGGEST culprit)

Check:

```bash
du -sh ~/.cache/nix-direnv
find . -name .direnv
```

Clean:

```bash
rm -rf ~/.cache/nix-direnv
find ~/work -name .direnv -type d -exec rm -rf {} +
```

---

### 🧨 `result` symlinks (pins builds forever)

Check:

```bash
find ~ -maxdepth 2 -name result
```

Remove:

```bash
rm ~/result
rm ~/nix-config/result
```

---

### 🧨 old profiles / generations

```bash
nix profile wipe-history --older-than 7d
home-manager expire-generations "-7 days"
sudo nix-collect-garbage -d
```

---

## 🧹 4. Actually free space

```bash
nix-collect-garbage -d
```

---

## 📉 5. Reduce store size (dedup)

```bash
nix store optimise
```

---

## 🔬 6. Debug: why is this still here?

```bash
nix-store -q --roots /nix/store/<path>
```

👉 shows exactly what’s keeping it alive

---

# ⚠️ Flakes-specific pitfalls

## ❌ Problem: direnv creates GC roots

```
.direnv/flake-profile-*   ← pins entire devShell
.direnv/flake-inputs/*    ← pins sources
```

👉 Result: GC does nothing, store explodes

---

## ✅ Fix: ephemeral dev shells

Use:

```bash
nix develop --no-link
```

---

## ✅ Better `.envrc`

```bash
use flake
```

Then periodically:

```bash
rm -rf .direnv
```

---

## ✅ Best practice (long-term)

* Don’t keep `.direnv/` forever
* Don’t keep `result` symlinks
* Periodically:

  ```bash
  nix-collect-garbage -d
  ```

---

# 🧪 7. Nuclear cleanup (safe but aggressive)

If things are really bad:

```bash
rm -rf ~/.cache/nix-direnv
find ~ -name .direnv -type d -exec rm -rf {} +
find ~ -name result -type l -delete

nix profile wipe-history --older-than 1d
sudo nix-collect-garbage -d
nix-collect-garbage -d
```

---

# 🎯 Rule of thumb

If `/nix/store` is huge:

> ❌ Not garbage collection’s fault
> ✅ You still have **live roots**

---

# 🚀 Minimal clean workflow

```bash
# 1. remove dev shell roots
rm -rf ~/.cache/nix-direnv
find ~/work -name .direnv -exec rm -rf {} +

# 2. remove build pins
find ~ -name result -type l -delete

# 3. clean generations
nix profile wipe-history --older-than 7d
sudo nix-collect-garbage -d

# 4. final GC
nix-collect-garbage -d
```
