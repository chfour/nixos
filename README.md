# this is my NixOS flake

im relatively new to it but i really like this distro can you tell

uses nixpkgs/nixos-unstable and home-manager

## `machines`

does what it says on the tin

### `foxbox`

this is my laptop

it's a thinkpad E14 gen 2 so the corresponding nixos-hardware
module is included

it runs the latest kernel

gnome & pipewire

also libvirt

idk what else to say

### `fovps`

this is my vps hosted on contabo's cheapest tier :fire:

buncha stuff on it

## `users`

yeh

### `chfour`

thats me

git, vscodium, mpd as a user service, a bunch of packages

gui stuff only gets enabled if there is a gui

there's also a custom zsh dir with a modified af-magic theme

the gnome config has blur-my-shell, runcat, and the appindicator extension, and it gets
included automatically if gnome is enabled

i also tweak gnome a bit

nuff said
