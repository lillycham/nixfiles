UNAME := $(shell uname)

all: update switch

update:
	nix-channel --update

switch:
	-darwin-rebuild switch
	-nixos-rebuild switch
	home-manager  switch
