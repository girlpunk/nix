# nix

## WSL

### Install

1. ```powershell
   wsl --install --no-distribution
   ```
2. https://github.com/nix-community/NixOS-WSL/releases/latest
3. ```bash
   nix-shell -p git
   mkdir ~/programs
   cd ~/programs
   git clone https://github.com/girlpunk/nix
   sudo nixos-rebuild boot --flake .#work
   ```
4. ```powershell
   wsl -t NixOS
   wsl -d NixOS --user root exit
   wsl -t NixOS
   ```
5. ```zsh
   q
   mv -v /home/nixos/programs .
   sudo rm -rv /home/nixos
   cd programs/nix
   home-manager switch --flake .#sam@work
   ```

### Updates

```zsh
cd ~/programs/nix
nh os switch .#work -u
nh home switch .#sam@work -u
```
