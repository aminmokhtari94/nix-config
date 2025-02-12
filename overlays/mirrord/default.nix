{ channels, ... }:

final: prev: {
  inherit (channels.unstable) mirrord;
}
