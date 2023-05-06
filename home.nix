{ config, pkgs, lib, enhancd, zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions, spaceship-prompt, suspend, emacs-config, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  home.username = "malaoui";
  home.homeDirectory = "/home/malaoui";

  home.file = {
    ".emacs.d" = {
      source = emacs-config;
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    nnn
    git
    bat
    htop
    tldr
    duf
    fd
    ripgrep
    powerline-fonts
    pandoc
    xsel
    ranger
    tmux
    emacs
    plantuml
    haskell-language-server
    nodePackages.bash-language-server
    opam
    julia
    libvterm-neovim
    texlive.combined.scheme-full
    direnv
    feh
    w3m
    ueberzug
    emacs-all-the-icons-fonts
  ];


  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    defaultKeymap = "emacs";
    history.extended = true;
    plugins = [
      {
        name = "enhancd";
        file = "init.sh";
        src = enhancd;
      }
      {
        name = "zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
        src = zsh-autosuggestions;
      }
      {
        name = "zsh-syntax-highlighting";
        file = "zsh-syntax-highlighting.zsh";
        src = zsh-syntax-highlighting;
      }
      {
        name = "spaceship-prompt";
        file = "spaceship.zsh";
        src = spaceship-prompt;
      }
      {
        name = "zsh-completions";
        file = "zsh-completions.zsh";
        src = zsh-completions;
      }

    ];
    shellAliases = {
      ect = "emacsclient -nw";
      ecg = "emacsclient -c";
      ls = "ls --color=yes";
      ll = "ls --color=yes -alF";
      la = "ls --color=yes -A";
      l = "ls --color=yes -CF";
    };
    initExtra = ''
    source ~/.nix-profile/etc/profile.d/nix.sh

    unset TMUX

    SPACESHIP_PROMPT_ORDER=(
    time          # Time stamps section
    user          # Username section
    dir           # Current directory section
    host          # Hostname
    git           # Git section (git_branch + git_status)
    venv          # virtualenv section
    pyenv         # Pyenv section
    exec_time     # Execution time
    jobs          # Background jobs indicator
    exit_code     # Exit code section
    line_sep      # line break
    char          # Prompt character
    )

    eval "$(zoxide init zsh)"

    export WORKON_HOME="~/.virtualenvs/"
    export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"
    source ~/.local/bin/virtualenvwrapper.sh
    '';
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "tmux-256color";
    historyLimit = 50000;
    escapeTime = 0;
    aggressiveResize = true;
    keyMode= "emacs";
    # mouse= true;
    extraConfig = ''
    set -g prefix C-b
    bind-key -n C-a send-prefix

    set -g buffer-limit 20
    set -g display-time 1500
    setw -g allow-rename off
    setw -g automatic-rename off
    set -g remain-on-exit off
    set -g set-titles on
    set -g set-titles-string "#I:#W"
    set -g base-index 1
    setw -g pane-base-index 1


    # Unbind default key bindings, we're going to override
    unbind "\$" # rename-session
    unbind ,    # rename-window
    unbind %    # split-window -h
    unbind '"'  # split-window
    unbind \}    # swap-pane -D
    unbind \{    # swap-pane -U
    unbind [    # paste-buffer
    unbind ]
    unbind "'"  # select-window
    unbind n    # next-window
    unbind p    # previous-window
    unbind l    # last-window
    unbind M-n  # next window with alert
    unbind M-p  # next window with alert
    unbind o    # focus thru panes
    unbind &    # kill-window
    unbind "#"  # list-buffer
    unbind =    # choose-buffer
    unbind z    # zoom-pane
    unbind M-Up  # resize 5 rows up
    unbind M-Down # resize 5 rows down
    unbind M-Right # resize 5 rows right
    unbind M-Left # resize 5 rows left

    # Rename session and window
    bind r command-prompt -I "#{window_name}" "rename-window '%%'"
    bind R command-prompt -I "#{session_name}" "rename-session '%%'"

    # Split panes
    bind - split-window -h -c "#{pane_current_path}"
    bind _ split-window -v -c "#{pane_current_path}"


    # Select pane and windows
    bind j previous-window
    bind k next-window
    bind -r [ select-pane -t :.-
    bind -r ] select-pane -t :.+
    bind -r Tab last-window   # cycle thru MRU tabs
    bind -r C-o swap-pane -D

    # Zoom pane
    bind + resize-pane -Z


    # Kill pane/window/session shortcuts
    bind x kill-pane
    bind X kill-window
    bind C-x confirm-before -p "kill other windows? (y/n)" "kill-window -a"
    bind Q confirm-before -p "kill-session #S? (y/n)" kill-session


    # Detach from session
    bind d detach
    bind D if -F '#{session_many_attached}' \
        'confirm-before -p "Detach other clients? (y/n)" "detach -a"' \
        'display "Session has only 1 client attached"'

    # Hide status bar on demand
    bind C-s if -F '#{s/off//:status}' 'set status off' 'set status on'


    set -g visual-activity on

    # ================================================
    # ===     Copy mode, scroll and clipboard      ===
    # ================================================
    set -g @copy_use_osc52_fallback on

    # Prefer emacs style key table
    setw -g mode-keys emacs

    bind p paste-buffer
    bind C-p choose-buffer

    # trigger copy mode by
    bind PageUp copy-mode

    # Scroll up/down by 1 line, half screen, whole screen
    bind -T copy-mode M-Up              send-keys -X scroll-up
    bind -T copy-mode M-Down            send-keys -X scroll-down
    bind -T copy-mode M-PageUp          send-keys -X halfpage-up
    bind -T copy-mode M-PageDown        send-keys -X halfpage-down
    bind -T copy-mode PageDown          send-keys -X page-down
    bind -T copy-mode PageUp            send-keys -X page-up

    # When scrolling with mouse wheel, reduce number of scrolled rows per tick to "2" (default is 5)
    bind -T copy-mode WheelUpPane       select-pane \; send-keys -X -N 2 scroll-up
    bind -T copy-mode WheelDownPane     select-pane \; send-keys -X -N 2 scroll-down


    set -g @continuum-save-interval '15'
    set -g @continuum-restore 'on'

    '';

    plugins = with pkgs.tmuxPlugins; [
      yank
      tmux-fzf
      nord
      prefix-highlight
      open
      resurrect
      continuum
      suspend
    ];
  };

  programs.alacritty = {
    enable = true;
    settings = {
      colors.primary = {
        background =  "#2e3440";
        foreground =  "#d8dee9";
        dim_foreground =  "#a5abb6";
      };
      colors.cursor = {
        text= "#2e3440";
        cursor= "#d8dee9";
      };
      colors.vi_mode_cursor={
        text= "#2e3440";
        cursor= "#d8dee9";
      };
      colors.selection= {
        text= "CellForeground";
        background= "#4c566a";
      };
      colors.search={
        matches={
          foreground= "CellBackground";
          background= "#88c0d0";
        };
        footer_bar={
          background= "#434c5e";
          foreground= "#d8dee9";
        };
      };
      colors.normal={
        black= "#3b4252";
        red= "#bf616a";
        green= "#a3be8c";
        yellow= "#ebcb8b";
        blue= "#81a1c1";
        magenta= "#b48ead";
        cyan= "#88c0d0";
        white= "#e5e9f0";
      };
      colors.bright= {
        black= "#4c566a";
        red= "#bf616a";
        green= "#a3be8c";
        yellow= "#ebcb8b";
        blue= "#81a1c1";
        magenta= "#b48ead";
        cyan= "#8fbcbb";
        white= "#eceff4";
      };

      colors.dim =  {
        black= "#373e4d";
        red= "#94545d";
        green= "#809575";
        yellow= "#b29e75";
        blue= "#68809a";
        magenta= "#8c738c";
        cyan= "#6d96a5";
        white= "#aeb3bb";
      };

      window.decorations = "none";
      window.padding = {
        x = 5;
        y = 5;
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };


  home.file.".config/ranger/rifle.conf".text = ''
    !mime ^text, label editor, ext org, ext tex = emacsclient -c "$@"
    else = xdg-open "$@"
  '';

  home.file.".config/ranger/rc.conf".text = ''
    set preview_images true
    set preview_images_method ueberzug
  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  home.sessionVariables = {
    EDITOR="emacsclient -nw";
    VISUAL="emacsclient";
    TERM="xterm-256color";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.fzf.tmux.enableShellIntegration = true;
  programs.fzf.enableZshIntegration = true;
  fonts.fontconfig.enable = true;

  home.activation.emacsConfig = lib.hm.dag.entryAfter [ "installPackages" ] ''
    PATH="${config.home.path}/bin:$PATH" $DRY_RUN_CMD emacs --debug-init --batch -u $USER'';

  services.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

}
