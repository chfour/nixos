{ ... }:

{
  systemd.network.enable = true;
  networking.useDHCP = false;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";

    networkConfig.DHCP = "ipv4";
    
    # apparently ipv6s are done manually
    # https://contabo.com/blog/adding-ipv6-connectivity-to-your-server/
    # idk anymore skull emoji
    
    address = [
      "2a02:c207:2177:8888::1/64"
    ];
    routes = [
      { routeConfig.Gateway = "fe80::1"; }
    ];
    dns = [
      "2a02:c207::1:53"
      "2a02:c207::2:53"
    ];
  };
}
