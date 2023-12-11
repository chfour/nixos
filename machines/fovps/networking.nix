{ ... }:

{
  systemd.network.enable = true;
  networking.useDHCP = false;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";

    # apparently ipv6s are done manually
    # https://contabo.com/blog/adding-ipv6-connectivity-to-your-server/
    # idk anymore skull emoji
    
    networkConfig = {
      DHCP = "ipv4";
    };
    address = [
      "2a02:c207:2087:819::1/64"
    ];
    routes = [
      { routeConfig.Gateway = "fe80::1"; }
    ];
  };
}
