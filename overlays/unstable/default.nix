{ channels, ... }:

final: prev: {
  inherit (channels.unstable)
    nerd-fonts
    talosctl
    vscode
    formats
    vimPlugins
    throne
    claude
    codex
    rtk
    openspec
    telegram-desktop
    ;
}
