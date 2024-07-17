{
  description = "Home Manager (dotfiles) and NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lix = {
      url = "git+https://git.lix.systems/lix-project/lix?ref=refs/tags/2.90.0";
      flake = false;
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pp-modules = {
      url = "github:ppenguin/nixos-modules/main";
      # url = "/home/jeroen/devel/github.com/ppenguin/nixos-modules";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    /*
    fh = {
      url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    */
    nix-snapd = {
      url = "github:io12/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixinate = {
      url = "github:matthewcroughan/nixinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # darwin.url = "github:lnl7/nix-darwin/master";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pyprland = {
    #   url = "github:hyprland-community/pyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-std.url = "github:chessai/nix-std";

    nurpkgs = {url = "github:nix-community/NUR";};

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # nix-colors.url = "github:misterio77/nix-colors";

    # nixvim = {
    #   url = "github:nix-community/nixvim/main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nvf = {
      url = "github:notashelf/nvf/main";
      # url = "github:notashelf/nvf/32d231395fe000eb1aca283e6f385404b9f0770a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # these inputs used in overlays only
    # xdph = {
    #   url = "github:hyprwm/xdg-desktop-portal-hyprland/91e48d6acd8a5a611d26f925e51559ab743bc438"; # 2024-05-26 to solve screensharing ???
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # (arbitrary?): propagate system stuff here, get rest from inputs
  outputs = inputs @ {
    self,
    nixpkgs,
    nixinate,
    ...
  }: let
    inherit
      (import ./nixos-builder.nix {
        inherit (nixpkgs) lib;
        inherit inputs;
      })
      getNixosConfigs
      getDarwinConfigs
      ;
  in {
    apps = nixinate.nixinate.x86_64-linux self;

    homeConfigurations =
      (import ./home/hm-builder.nix {
        inherit (nixpkgs) lib;
        inherit inputs;
        # TODO:See this: https://discourse.nixos.org/t/nixos-custom-module-configuration-with-flakes-and-home-manager/17360/5
        # This means we don't need this hocus pocus? Or is this only valid if HM is used as a NixOS module, which we don't do
        # to support users independently updating their own HM config (without root access)
        systemConfigs =
          inputs.self.nixosConfigurations
          // inputs.self.darwinConfigurations;
      })
      .getHMConfigs; # all top level user names (dirs) under ./home will be used and paired with hostnames if the user is defined in the host definition

    nixosConfigurations = getNixosConfigs ./hosts;

    darwinConfigurations = getDarwinConfigs ./hosts;
  };
}
