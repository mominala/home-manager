{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    enhancd = {
      flake = false;
      url = "github:b4b4r07/enhancd";
    };
    zsh-autosuggestions = {
      flake = false;
      url = "github:zsh-users/zsh-autosuggestions";
    };
    zsh-completions = {
      flake = false;
      url = "github:zsh-users/zsh-completions";
    };
    zsh-syntax-highlighting = {
      flake = false;
      url = "github:zsh-users/zsh-syntax-highlighting";
    };
    spaceship-prompt = {
      flake = false;
      url = "github:spaceship-prompt/spaceship-prompt";
    };
    tmux-suspend = {
      flake = false;
      url = "github:MunifTanjim/tmux-suspend";
    };
    emacs-config = {
      flake = false;
      url = "github:mominala/.emacs.d/literate";
    };
    nixgl.url = "github:guibou/nixGL";

  };

  outputs = { nixgl, nixpkgs, home-manager, enhancd, zsh-syntax-highlighting, zsh-autosuggestions, spaceship-prompt, zsh-completions, tmux-suspend, emacs-config, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ nixgl.overlay ];
      };
      suspend = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "suspend";
        version = "1.0";
        src = tmux-suspend;
      };
    in {
      homeConfigurations.malaoui = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = { inherit pkgs enhancd zsh-syntax-highlighting zsh-autosuggestions zsh-completions spaceship-prompt suspend emacs-config; };

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
