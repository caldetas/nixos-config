{ config, vars, ... }:
{
  services.jitsi-meet = {
    enable = true;
    hostName = "meet.${vars.domain}";

    # Recommended hardening for a Jitsi-only Prosody instance
    prosody.lockdown = true;

    config = {
      prejoinPageEnabled = true;
      enableWelcomePage = true;
    };

    interfaceConfig = {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
    };
  };

  services.jitsi-videobridge.openFirewall = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "info@${vars.domain}";
  };
}
