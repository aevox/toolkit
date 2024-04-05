# Toolkit

This repository houses a `flake.nix` encapsulating a declarative suite of tools for development and operations.
It is designed for effortless integration into other projects, providing a reproducible set of tools including `kubectl`, `fluxcd`, among others.

If you want your project to use the packages defined in this repository you can create your own nix flake and use this one as input.
You can find an example [here](./examples/flake.nix).


# QuickStart
The next commands assume you have Nix installed on your machine.
See the [Installing section](#installing-nix) for a quick guide to install Nix.

## Installing Packages

You can use the `nix profile` command to permanently install packages defined in `flake.nix` into your user profile.
Replace `<package-name>` with the name of the package you want to install:
```bash
nix profile install 'github:aevox/toolkit#<package-name>'
```

For the default package, you can simply use:
```bash
nix profile install 'github:aevox/toolkit#default'
```

## Activating the Development Environment

Navigate to the directory containing `flake.nix` and activate your development environment:
```bash
nix develop
```

You can also use nix-shells. You can find an example [here](./examples/shell.nix)
Navigate to the directory containing `shell.nix` and activate the nix shell:
```bash
nix-shell
```

## Automatic Dev Shell Loading with Direnv

[Direnv](https://direnv.net) is a tool that automatically loads and unloads environment variables as you switch between different project directories.

**Install Direnv** using your system's package manager or Nix (it is also in this flake):
```bash
# This uses Nix to install direnv
nix profile install nixpkgs#direnv

# You can also use this flake:
nix profile install gihub.com/aevox/toolkit#direnv
```

**Activate** direnv in your shell:
```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
# If you're using bash
# echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
```

**Configure `.envrc`** to automatically load your Nix environment:
```bash
direnv allow .envrc
```

# Installing Nix

Here is a TLDR to install nix on either MacOS or Linux. (last update 08/04/2024).
You can find more information on the [official download page](https://nixos.org/download/).

## MacOS

**Install Nix**:
```bash
sh <(curl -L https://nixos.org/nix/install)
```

**Enable** the `flake` command and **add caches** for accessing pre-built binaries:
```bash
mkdir -p "$HOME"/.config/nix/
cat << EOF > "$HOME"/.config/nix/nix.conf
substituters = https://nix-community.cachix.org https://cache.nixos.org/
trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
experimental-features = nix-command flakes
EOF
```

**Authorize** users with root privileges to utilize caches:
```bash
sudo mkdir -p /etc/nix
echo 'trusted-users = root @admin' | sudo tee -a /etc/nix/nix.conf
```

**Restart** the Nix daemon to apply changes:
```bash
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
```

## Linux

**Install Nix**:
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

**Enable** the `flake` command and add Nix caches for accessing pre-built binaries:
```bash
mkdir -p "$HOME"/.config/nix/
cat << EOF > "$HOME"/.config/nix/nix.conf
substituters = https://nix-community.cachix.org https://cache.nixos.org/
trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
experimental-features = nix-command flakes
EOF
```

**Authorize** users with root privileges to utilize caches:
```bash
sudo mkdir -p /etc/nix
echo 'trusted-users = root @wheel' | sudo tee -a /etc/nix/nix.conf
```

**Restart** the Nix daemon to apply changes:
```bash
sudo systemctl restart nix-daemon
```


# Enhancing the Shell Experience with ZSH

To use `zsh` as your default shell in Nix-generated environments, integrate the [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/) plugin [zsh-nix-shell](https://github.com/chisui/zsh-nix-shell) for seamless transition, alongside [nix-zsh-completions](https://github.com/spwhitt/nix-zsh-completions) for improved command-line completion.

**Clone and set up the plugin**:

```bash
git clone https://github.com/chisui/zsh-nix-shell.git $ZSH_CUSTOM/plugins/nix-shell
```

**Activate the plugin** by adding `nix-shell` to the plugins list in your `~/.zshrc`.
