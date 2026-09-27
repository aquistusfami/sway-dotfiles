{
	description = "NixOS Flake Configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
	};

	outputs = { self, nixpkgs, nixos-hardware, ... }@inputs: {
		nixosConfigurations = {
			nixos = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen5
					
					./hardware-configuration.nix
					./configuration.nix
				];
      };
    };
  };
}



