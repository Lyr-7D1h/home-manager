{config, pkgs, lib, ...}:
 
lib.mkIf (config.networking.hostName == "oser") {
}

