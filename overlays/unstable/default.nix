{ channels, ... }:

final: prev: {
  inherit (channels.unstable) nerd-fonts talosctl vscode;
}
