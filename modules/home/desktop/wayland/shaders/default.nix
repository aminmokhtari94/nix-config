{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.default.desktop.wayland.shaders;

  shaders = {
    # Soft vignette — barely-there darkening at the edges, easy on the eyes.
    vignette = pkgs.writeText "vignette.frag" ''
      #version 300 es
      precision highp float;
      in vec2 v_texcoord;
      uniform sampler2D tex;
      out vec4 fragColor;
      void main() {
        vec4 c = texture(tex, v_texcoord);
        vec2 p = v_texcoord - 0.5;
        float d = dot(p, p);
        float v = smoothstep(0.55, 0.18, d);
        fragColor = vec4(c.rgb * mix(0.78, 1.0, v), c.a);
      }
    '';

    # Subtle CRT — scanlines + chromatic aberration + vignette. Retro feel
    # without being unreadable. Matches the ironbar/fuzzel rounded aesthetic.
    crt = pkgs.writeText "crt.frag" ''
      #version 300 es
      precision highp float;
      in vec2 v_texcoord;
      uniform sampler2D tex;
      out vec4 fragColor;

      void main() {
        vec2 uv = v_texcoord;
        float ab = 0.0015;
        vec3 c;
        c.r = texture(tex, uv + vec2(ab, 0.0)).r;
        c.g = texture(tex, uv).g;
        c.b = texture(tex, uv - vec2(ab, 0.0)).b;

        float scan = 0.96 + 0.04 * sin(uv.y * 1400.0);
        c *= scan;

        vec2 p = uv - 0.5;
        float vig = smoothstep(0.75, 0.25, dot(p, p));
        c *= mix(0.85, 1.0, vig);

        fragColor = vec4(c, 1.0);
      }
    '';

    # Warm night — pulls the blue channel down a touch, adds the faintest
    # gold to highlights. Pairs with hypridle for evenings.
    warm = pkgs.writeText "warm.frag" ''
      #version 300 es
      precision highp float;
      in vec2 v_texcoord;
      uniform sampler2D tex;
      out vec4 fragColor;
      void main() {
        vec4 c = texture(tex, v_texcoord);
        c.rgb *= vec3(1.03, 0.99, 0.92);
        fragColor = c;
      }
    '';
  };
in {
  options.default.desktop.wayland.shaders = with types; {
    enable = mkEnableOption "Hyprland screen shader (post-process)";

    style = mkOption {
      type = enum ["vignette" "crt" "warm"];
      default = "vignette";
      description = "Which built-in shader to apply";
    };

    custom = mkOption {
      type = nullOr path;
      default = null;
      description = "Override built-in shader with a path to a .frag file";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings.config.decoration.screen_shader = toString (
      if cfg.custom != null
      then cfg.custom
      else shaders.${cfg.style}
    );
  };
}
