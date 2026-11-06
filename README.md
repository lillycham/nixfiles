# nixfiles

My configs, using nix, home-manager and nix-darwin

## bootstrap

Necessary due to flakes.

### macOS
```shell
$ nix build
$ sudo ./result/activate
```

### NixOS
```
$ sudo nixos-rebuild switch --flake .
```

## subsequent runs


```shell
$ darwin-rebuild switch --flake .
```

```shell
$ nixos-rebuild switch --flake .
```

## Akyuu

The normal Akyuu package comes from `lillycham-nur`. The `akyuu` input supplies
the Home Manager module, service helpers and dashboard fonts.

After an Akyuu publication:

```shell
nix flake update lillycham-nur
nix flake update akyuu
nh darwin build ~/nixfiles -H mirai
```

`akyuu-dev-switch` selects `mirai-akyuu-dev` and overrides `akyuu` with the local
checkout (`~/devel/akyuu`, or `$AKYUU_SRC`). It does not change `flake.lock`.
A normal switch selects the NUR package again.

## structure

- /hosts/ contains a folder for each unique device. 
  - home.nix contains platform specific home-manager configs
  - default.nix is the system configuration
- /hosts/common.nix contains non-platform specific configs. it is imported in home.nix.
- /config/ contains program configs, imported via home-manager.
