{
  description = "A wrapper tool for nix OpenGL applications";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  # this commit of nixpkgs set the nvidiaVersion to "535.86.05";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/9a74ffb2ca1fc91c6ccc48bd3f8cbc1501bf7b8a";

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        isIntelX86Platform = system == "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
          overlays = [];
        };

        nixgl = pkgs.recurseIntoAttrs (pkgs.callPackage ./nixGL.nix {
          enable32bits = isIntelX86Platform;
          nvidiaVersion = "535.86.05";
        });
      in rec {

        inherit nixgl;

        packages = {

          default = nixgl.nixGLCommon nixgl.nixGLNvidia;
          nixGLDefault = nixgl.nixGLCommon nixgl.nixGLNvidia;
          nixGLNvidia = nixgl.nixGLNvidia;
          nixGLNvidiaBumblebee = nixgl.nixGLNvidiaBumblebee;
          nixGLIntel = nixgl.nixGLIntel;
          nixVulkanNvidia = pkgs.auto.nixVulkanNvidia;
          nixVulkanIntel = pkgs.nixVulkanIntel;
        };

        # deprecated attributes for retro compatibility
        defaultPackage = packages;
      })) // rec {
        # deprecated attributes for retro compatibility
        overlay = overlays.default;
        overlays.default = final: _:
          let isIntelX86Platform = final.system == "x86_64-linux";
          in {
            nixgl = import ./default.nix {
              pkgs = final;
              enable32bits = isIntelX86Platform;
              enableIntelX86Extensions = isIntelX86Platform;
              nvidiaVersion = "535.86.05";
            };
          };
      };
}
