# home-manager
My home manger setup

## Install

### Arch Linux

```bash
sudo pacman -S nix
sudo sytemctl --user enable --now nix-daemon
sudo usermod -aG nix-users $USER
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
nix-channel --update
nix-shell '<home-manager>' -A install
```
