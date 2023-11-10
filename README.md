# this is my NixOS flake

im relatively a beginner but i really like this distro can you tell

uses nixpkgs/nixos-unstable and home-manager :3

## `machines`

does what it says on the tin

### `foxbox`

this is my laptop. only configuration so far

it's a thinkpad E14 gen 2 so i have the corresponding nixos-hardware
module included there too

it runs the latest kernel

gnome & pipewire

also libvirt

idk what else to say

### `fovps`

this is my vps hosted on contabo's cheapest tier :fire:

at the time of writing i've only configured caddy on it but there
will be more stuff running on it

## `users`

yeh

### `chfour`

thats me

git, vscode, mpd as a user service, a bunch of packages

gui stuff only gets enabled if there is a gui

there's also a custom zsh dir with a modified af-magic theme

the gnome config has blur-my-shell, runcat, and the appindicator extension, and it gets
included automatically if gnome is enabled

i also tweak gnome a bit

nuff said

## epilogue

nixos turned my perception of linux upside down and i love it

i will never look at arch the same way ever again
