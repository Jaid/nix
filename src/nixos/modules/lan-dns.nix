{lib, ...} @ input: {
  options.jaidCustomModules.lan-dns.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Prefer the router’s DNS server for LAN host and service resolution";
  };
  config = lib.mkIf (input.config.jaidCustomModules.lan-dns.enable) {
    networking = {
      dhcpcd.extraConfig = ''
        nohook resolv.conf
      '';
      nameservers = ["10.0.0.2" "fd00::1"];
      search = ["lan"];
    };
  };
}
