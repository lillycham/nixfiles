# nixfiles

My configs, using nix, home-manager and nix-darwin

## bootstrap

Necessary due to flakes.

```
$ git clone <this repo>
$ cd nixfiles 
$ nix build .#<insert desired attr here>
$ ./result/sw/bin/darwin-rebuild switch --flake . # or nixos-rebuild switch on linux i guess
```
g
## subsequent runs

just use darwin-rebuild/nixos-rebuild.
