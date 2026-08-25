# AGENTS.md

Project reference for AI agents (and humans) working in this repo.

## What this is

Foxocube's NixOS + home-manager single-flake configuration for a homelab. NixOS
26.05 (nixpkgs `nixos-26.05`), Nix 2.34.x via `pkgs.nixVersions.latest`.
Deployment is via **nh**: `nh os switch .#<host> -u` and
`nh home switch .#sam@<host> -u`. The `work` machine _is_ the dev box (NixOS-WSL
on a D: drive, `/mnt/d` auto-mounted).

## Machines

| host             | what                                        | notes                                                                                                                            |
| ---------------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `argon`          | Intel laptop, Hyprland GUI                  | NetworkManager + WireGuard; builds offloaded to minos; not reachable by name from WSL                                            |
| `minos`          | Proxmox VM, **build server + binary cache** | 192.168.42.24, `home.foxocube.xyz`; 8-way parallelism (builder `maxJobs = 8`)                                                    |
| `mnemosyne`      | Proxmox VM, homelab server                  | shared Postgres for 10+ apps (`system/programs/postgresql.nix`); NFS client to NAS (e-books for Kavita/Calibre at `/mnt/ebooks`) |
| `work`           | NixOS-WSL, this dev machine                 | `inputs.nixos-wsl`; no SSH from here to any machine (argon unresolvable, minos key rejected)                                     |
| `home-assistant` | home-manager only                           |                                                                                                                                  |

NAS "**juggernaut**" at 192.168.42.4: NFS exports (`/Storage/NixCold`,
`/Storage/Media/eBooks`) + CIFS media shares (`/media/juggernaut` autofs via
`system/modules/mounts.nix`).

## Repo layout

```
flake.nix          inputs, treefmt, checks (`.formatting`, `.pre-commit-check`)
os.nix / home.nix  build all host configs: ./system(./home) ++ ./system/machine/<host>
lib/overlays.nix   pkgs + overlays + builders (`pkgs.builders.mkNixos` / `mkHome`)
system|home/…      shared default.nix + machine/ + modules/ + programs/
secrets/           sops-encrypted per-host secrets (sops-nix, .sops.yaml at root)
```

Module order matters: `system/default.nix` (or `home/default.nix`) is applied
**before** the machine config, so machine-level plain values override/add to
shared ones (see "Nix settings gotchas").

## Nix cache / build architecture (the important part)

- **minos is the signing store for argon**: argon's system + home build on minos
  via the `ssh-ng://minos` builder (`system/modules/remoteBuild.nix`,
  `home/modules/remoteBuild.nix`). minos signs with
  `secret-key-files = /etc/nix/cache-priv-key.pem`; the public key is trusted
  globally (`minos:wcHt079XZRopdL7wy1aeBjkgE82Vmz1K9n8WpsOgZsY=`, in
  `system/default.nix`).
- **Hot cache**: minos's local store, 14-day TTL.
  `systemd.services.nix-store-ageout` (daily) takes garbage store paths older
  than 14 days, `nix copy --to file://`s them into the cold cache (this exports
  a _static_ binary cache: `<hash>.narinfo` + `nar/<filehash>.nar.xz`), and
  deletes them locally only if the offload succeeded (or was already present). A
  `mountpoint` guard skips the run when the NAS is unmounted.
- **Cold cache**: `/Storage/NixCold` on juggernaut, NFS-mounted at
  `/var/lib/nix-cold` (`_netdev nofail`), served statically through an nginx
  vhost on minos port 8000. Consumers (in substituter order): argon
  `ssh-ng://minos` → `http://192.168.42.24:8000/`; minos re-pulls its own
  offloads from `http://127.0.0.1:8000/`. 90-day retention via
  `systemd.services.nix-cold-cache-ageout` (narinfo + matching `.nar.xz`).
- **GC**: `programs.nh.clean` runs `nh clean --keep-since 4d --keep 3` (store GC
  included) on all hosts **except minos**, which forces `--no-gc` on minos so
  its own weekly GC can't destroy the 14-day hot cache. No `nix.gc.automatic`
  anywhere (conflicts with nh clean).
- Signatures survive the offload: `nix copy --to file://` carries store-DB
  signatures into the exported narinfo; substituted paths keep their upstream
  (already-trusted) signatures.

### Nix settings gotchas (learned the hard way)

- The **NixOS `nix` module merges** `nix.settings.substituters` lists across
  modules (shared + machine + its own `cache.nixos.org` default) — machine lists
  append, they do not replace. (Verified against the locked nixpkgs with a
  minimal `nixosSystem`.)
- **home-manager writes `nix.settings` verbatim** to a user-level
  `~/.config/nix/nix.conf`, which _replaces_ system-level lists for user nix
  calls and has no auto-trust: user-level config must repeat the full
  substituter list plus `trusted-substituters` and `trusted-public-keys` (see
  `home/modules/remoteBuild.nix`).
- `${...}` inside Nix indented strings `''...''` is **Nix interpolation**, not
  bash, and `#` starts a Nix comment. Never write bash `${var##*/}` in a systemd
  script string — use `basename`/`cut` instead.

## Working / verifying from the WSL box

- `nixos-rebuild dry-run --flake .#argon` does a full eval (exit 0) — run it
  after changes to argon or anything shared.
- **minos does NOT fully evaluate here**: `flake.nix` has the `faedupes` input
  commented out (WIP, owned by Fae) while `system/machine/minos/default.nix`
  still references `inputs.faedupes.packages.x86_64-linux.faedupes`. Verify
  minos changes with a **stub eval**: `import` the machine file with dummy
  `inputs`/`pkgs`/`lib`/`config` and force the changed attrs out via
  `nix eval --impure --json -f stub.nix | jq`.
- Smoke-test systemd script bodies by extracting them from a stub eval,
  sed-swapping the hardcoded paths, and running against scratch dirs in
  `/tmp/opencode`.
- Checks: `nix build .#checks.x86_64-linux.formatting` (treefmt),
  `nix build .#checks.x86_64-linux.pre-commit-check`; `nix fmt` (formats the
  whole repo) and `nix flake check` (runs all checks) also work from here.
- Reference nixpkgs checkout at `/mnt/d/nixpkgs` for module lookups — note it
  tracks `master` and may be newer than the pinned flake input; if the layout
  disagrees, verify against the rev in `flake.lock`.
- Direct formatting: find alejandra in the store, e.g.
  `ls -d /nix/store/*-alejandra-* | grep -v drv | head -1` then
  `/bin/alejandra -c <files>` (in-place without `-c`; there is no `-i` flag).
- No `python3` on PATH — use `jq` for JSON.
- WSL store paths are **immutable** (`chattr +i`); `cp -a/-r` carries the flag
  into copies and non-root can't clear it — simulate store paths with
  lightweight fake dirs.

## Conventions

- alejandra-style Nix (2-space indent); treefmt enforces it via
  `checks.formatting`.
- Shared modules (`system/default.nix`, `system/modules/*`, `home/modules/*`)
  stay machine-agnostic; per-host config goes in `machine/<host>/` (and
  `home/machine/sam@<host>/`).
- Working tree is frequently dirty (user edits alongside agents); never assume
  clean, don't commit unless asked.
