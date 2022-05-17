{ config, pkgs, ... }:
{
  home.username = "lyr";
  home.homeDirectory = "/home/lyr";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    # Import neovim nightly
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];


  home.packages = with pkgs; [
    nixpkgs-fmt
  ];

  services.gpg-agent.enable = true;

  programs.go.enable = true;
  programs.git = {
    enable = true;
    userName = "lyr";
    userEmail = "lyr-7d1h@pm.me";
    extraConfig = {
      pull = { rebase = false; };
      init = { defaultBranch = "master"; };
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
    viAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-commentary
      vim-toml
      auto-pairs
      nvim-cm-racer
    ];
    extraConfig = ''
      set number
      set tabstop=4
      set shiftwidth=4
      set clipboard+=unnamedplus

      let mapleader=";"

      " Always use original yank when pasting
      noremap <Leader>p "0p
      noremap <Leader>P "0P
      vnoremap <Leader>p "0p

      " Easier Split Navigation
      nnoremap <C-j> <C-W><C-J>
      nnoremap <C-k> <C-W><C-K>
      nnoremap <C-l> <C-W><C-L>
      nnoremap <C-h> <C-W><C-H>
    '';
  };

  # systemd.user.timers = {
  #   daily-paper = {
  #     Unit = {
  #       Description = "Set your daily wallpaper";
  #     };
  #     Timer = {
  #       Unit = "daily-paper";
  #       OnCalendar = "daily";
  #       Persistent = true; 
  #     };
  #     Install = {
  #       WantedBy = [ "timers.target" ];
  #     };
  #   };
  # };
  systemd.user.services = {
    daily-paper = {
      Unit = {
        Description = "setting your daily wallpaper";
        After="network-online.target";
        Wants="network-online.target";
      };

      Service = {
        ExecStart = "/home/lyr/bin/daily_paper";
        Type = "oneshot";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
  # Automatically start services
  systemd.user.startServices = "sd-switch";

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -s copy-command 'wl-copy'

      # Allow scrolling with mouse
      set -g mouse on
      # Vim keybindings in copy-mode
      set-window-option -g mode-keys vi

      # Vi bindings for moving between planes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host home.lyrx.dev
        ProxyCommand /usr/bin/cloudflared access ssh --hostname %h

      # TECHINC
      Host inc_mpd
          User techinc 
          Hostname 10.209.10.3
    '';
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    defaultKeymap = "emacs";
    shellAliases = {
      update = "home-manager switch";
      ssh = "TERM=xterm ssh";
      tf = "terraform";
      configure = "vim ~/.config/nixpkgs/home.nix";
      ls = "ls --color=auto";
    };
    initExtra = ''
      source ~/.p10k.zsh

      if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='vim'
      else
        export EDITOR='nvim'
      fi

      # set emacs keybinds (ctrl+a, ctrl+e)
      bindkey -e

      # ctrl + space to accept suggestions
      bindkey '^ ' autosuggest-accept

      autoload -Uz select-word-style
      select-word-style bash

      x-backward-kill-word(){
        WORDCHARS='*?_-[]~\!#$%^(){}<>|`@#$%^*()+:?' zle backward-kill-word
      }
      zle -N x-backward-kill-word

      # alt + backspace 
      bindkey '^[^?' x-backward-kill-word

      # alt + delete remove word
      bindkey '^[[3;5~' kill-word

      # Enable reverse search
      bindkey '^R' history-incremental-search-backward

      # alt + <- and alt + -> move a word
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word

      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      bindkey  "^[[3~"  delete-char

      # Needed for obs on wayland
      export QT_QPA_PLATFORM=wayland

      # AWS stuff
      export AWS_PROFILE=DPG-Media---Recosearch.dpg-administrator-cf
      export AWS_DEFAULT_REGION=eu-west-1
      export AWS_DEFAULT_SSO_START_URL=https://d-93677093a7.awsapps.com/start
      export AWS_DEFAULT_SSO_REGION=eu-west-1

      kaws() {
        selected=$(aws configure list-profiles | fzf)
        export AWS_PROFILE=$selected
      }

      ktx() {
        current="$(kubectl config current-context)"
        selected=$( (kubectl config view -o jsonpath="{.contexts[?(@.name != "''${current}")].name}" | xargs -n 1; echo "''${current}" ) | fzf -0 -1 --tac -q "''${1:-""}" --prompt "$current> ")
        if [ ! -z "$selected" ]; then
            kubectl config use-context "''${selected}"
        fi
      }


      # Keep same directory in gnome-terminal
      . /etc/profile.d/vte.sh

      # Initialize asdf if it exists
      if [[ -f /opt/asdf-vm/asdf.sh ]]; then
        . /opt/asdf-vm/asdf.sh
      fi

      # Adding custom executables
      export PATH="$PATH:$HOME/.npm/bin"
      export PATH="$HOME/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
    '';
    zplug = {
      enable = true;
      plugins = [
        { name = "plugins/kubectl"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/aws"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/terraform"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/npm"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/poetry"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/docker"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/docker-compose"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/tmux"; tags = [ from:oh-my-zsh ]; }
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };
  };

  home.stateVersion = "21.11";

  programs.home-manager.enable = true;
}
