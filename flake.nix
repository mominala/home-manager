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
      url = "github:muniftanjim/tmux-suspend";
    };
    emacs-config = {
      flake = false;
      url = "github:mominala/.emacs.d/literate";
    };


  };

  outputs = { nixpkgs, home-manager, enhancd, zsh-syntax-highlighting, zsh-autosuggestions, spaceship-prompt, zsh-completions, tmux-suspend, emacs-config, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      suspend = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-suspend";
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
        extraSpecialArgs = { inherit enhancd zsh-syntax-highlighting zsh-autosuggestions zsh-completions spaceship-prompt suspend emacs-config; };

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
