{ channels, ... }:

final: prev: {
  inherit (channels.unstable)
    nerd-fonts
    talosctl
    vscode
    formats
    vimPlugins
    throne
    claude-code-bin
    ;
}
