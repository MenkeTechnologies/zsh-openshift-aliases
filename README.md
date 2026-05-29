```
 ___  ____  _  _    _____ ____  _____ _   _ ____  _   _ ___ _____ _____
|_  ||_   ||| ||   / ___// ___// ___|| | | / ___|| | | |_ _|  ___|_   _|
  | |  | | | || |  | |_  \___ \\___ \| |_| \___ \| |_| || || |_    | |
  | |  | | | || |  |  _|  ___) |___) |  _  |___) |  _  || ||  _|   | |
  |_|  |_| ||_||_|  |_|   |____/____/|_| |_|____/|_| |_|___|_|     |_|
       __ _ _ _  __ _ ___  ___  ____
      / _` | | |/ _` / __|/ _ \/ ___|
     | (_| | | | (_| \__ \  __/\___ \
      \__,_|_|_|\__,_|___/\___||____/
```

<p align="center">
<code>// `oc` IS A WORD. `og`, `ologin`, `ocdev`, `ocqa` ARE THE GRID. 52 ALIASES. ONE PLUGIN.</code>
</p>

---

[![Aliases](https://img.shields.io/badge/aliases-52-ff2a6d.svg)](zsh-openshift-aliases.plugin.zsh)
[![Tag](https://img.shields.io/badge/tag-v0.1.0-39ff14.svg)](https://github.com/MenkeTechnologies/zsh-openshift-aliases/tags)
[![Shell](https://img.shields.io/badge/shell-zsh-05d9e8.svg)](#install)
[![Tool](https://img.shields.io/badge/needs-oc-d300c5.svg)](https://github.com/openshift/oc)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](license.md)

### `[SIGNAL // 52 OPENSHIFT ALIASES + `oc` COMPLETION + LOGIN MACROS]`

> *// jacking into your OpenShift cluster from zsh — no more `oc get pods --namespace`-by-hand //*

---

## `> SYSTEM OVERVIEW`

`zsh-openshift-aliases` registers 52 short aliases over `oc` (the OpenShift CLI) plus pre-wired login macros for dev/QA endpoints and zsh tab-completion for the `oc` binary. Auto-noops on hosts where `oc` is missing — safe to load in zpwr-tier plugin chains without `command -v` guards in your `.zshrc`.

Set `OCP_USERNAME`, `OCP_DEV_URL`, `OCP_QA_URL` in your env, then `ocdev` / `ocqa` log you in with one keystroke.

---

## `> WHAT YOU GET`

```
[x] 52 oc-* aliases (og=get, oa=apply, od=describe, oco=config, ...)
[x] ologin       — oc rsh into running pod
[x] ocdev/ocqa   — env-driven login macros
[x] oc completion auto-sourced when `oc` is on PATH
[x] no-op when `oc` isn't installed — safe to load unconditionally
```

---

## `> INSTALL`

### Zinit

```sh
zinit ice lucid nocompile
zinit load MenkeTechnologies/zsh-openshift-aliases
```

### Oh My Zsh

```sh
cd "$HOME/.oh-my-zsh/custom/plugins" && \
  git clone https://github.com/MenkeTechnologies/zsh-openshift-aliases.git
```

Add `zsh-openshift-aliases` to the `plugins=(...)` array in `~/.zshrc`.

### Manual

```sh
git clone https://github.com/MenkeTechnologies/zsh-openshift-aliases.git
source zsh-openshift-aliases/zsh-openshift-aliases.plugin.zsh
```

---

## `> CONFIG`

Set in your shell before sourcing the plugin (or in `~/.zshrc` after):

```sh
export OCP_USERNAME='your-username'
export OCP_DEV_URL='https://api.dev.example.com:6443'
export OCP_QA_URL='https://api.qa.example.com:6443'
```

Then:

```sh
ocdev      # oc login $OCP_DEV_URL -u $OCP_USERNAME
ocqa       # oc login $OCP_QA_URL -u $OCP_USERNAME
ologin     # oc rsh into the focused pod
og pods    # oc get pods
oa -f foo  # oc apply -f foo
```

---

## `> LICENSE`

[MIT](license.md)

---

<p align="center">
<code>// END OF FILE // CLUSTER LOCKED //</code>
</p>
