{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.default.theme;
in
{
  options.default.theme = with types; {
    name = mkOption {
      type = str;
      default = "inspired";
      description = "Name of theme to apply to apps and tools appearance";
    };

    # Shared design tokens consumed by hyprland / ironbar / fuzzel
    # so the whole stack stays in lock-step (rounding, palette, fonts, motion).
    palette = mkOption {
      type = attrsOf str;
      default = {
        bg          = "1e1e2e";
        bgAlt       = "181825";
        surface     = "313244";
        surfaceAlt  = "45475a";
        fg          = "cdd6f4";
        fgMuted     = "a6adc8";
        accent      = "F48FB1";
        accent2     = "78A8FF";
        teal        = "63F2F1";
        urgent      = "f38ba8";
        ok          = "a6e3a1";
        warn        = "f9e2af";
      };
      description = "Shared color tokens (hex without #) used across the wayland stack";
    };

    rounding = mkOption {
      type = ints.unsigned;
      default = 10;
      description = "Corner radius (px) shared by hyprland, ironbar, fuzzel";
    };

    font = mkOption {
      type = str;
      default = "JetBrainsMono Nerd Font";
      description = "Primary UI font";
    };

    animationsBezier = mkOption {
      type = str;
      default = "0.05, 0.9, 0.1, 1.1";
      description = "Shared overshoot bezier curve";
    };
  };
}
