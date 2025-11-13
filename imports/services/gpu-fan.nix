{ config, ... }:
{
  # Service for starting up the GPU fans automatically
  systemd.services.gpu-fan = {
    enable = true;
    description = "GPU fan control";
    wantedBy = [ "multi-user.target" ];
    path = [ config.hardware.nvidia.package.settings ];
    script = ''nvidia-settings --ctrl-display=:1 -a [gpu:0]/GPUFanControlState=1 -a [fan:0]/GPUTargetFanSpeed=50 > /home/nova/fan.log'';
    serviceConfig.Type = "oneshot";
  };
}