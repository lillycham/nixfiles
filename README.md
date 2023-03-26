# nixfiles

My configs, using nix, home-manager and nix-darwin

## bootstrap

Necessary due to flakes.

```
$ git clone <this repo>
$ cd nixfiles 
$ nix build .#<insert desired attr here>
$ ./result/sw/bin/darwin-rebuild switch --flake . # or nixos-rebuild switch on nixos
```

## subsequent runs

just use darwin-rebuild/nixos-rebuild.

## structure

- /hosts/ contains a folder for each unique device. 
  - home.nix contains platform specific home-manager configs
  - default.nix is the system configuration
- /hosts/common.nix contains non-platform specific configs. it is imported in home.nix.
- /config/ contains program configs, imported via home-manager.
