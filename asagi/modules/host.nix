{ config, pkgs, ... }:

{
  # make the tailscale command usable to users
  environment.systemPackages = [ pkgs.tailscale ];

  # enable the tailscale service
  services.tailscale.enable = true;

  # auto connection
  launchd.daemons.tailscale-autoconnect = {
    script = ''
      AUTH_KEY_FILE="/etc/tailscale/authkey"

      if [ ! -f "$AUTH_KEY_FILE" ]; then
        echo "Auth key file not found at $AUTH_KEY_FILE"
        exit 1
      fi

      sleep 2
      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        exit 0
      fi

      ${pkgs.tailscale}/bin/tailscale up --authkey "$(cat $AUTH_KEY_FILE)"
    '';

    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
}

