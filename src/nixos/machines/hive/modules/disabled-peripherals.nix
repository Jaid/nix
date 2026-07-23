{...}: {
  boot.blacklistedKernelModules = [
    # Intel Wi-Fi
    "iwlwifi"
    "iwlmvm"
    "mac80211"
    "cfg80211"
    "libarc4"
    "rfkill"

    # Bluetooth
    "bluetooth"
    "btusb"
    "btintel"
    "btrtl"
    "btbcm"
    "btmtk"

    # PCIe, HDMI/DisplayPort and USB audio
    "snd_hda_intel"
    "snd_hda_codec_atihdmi"
    "snd_hda_codec_hdmi"
    "snd_hda_codec"
    "snd_hda_core"
    "snd_intel_dspcfg"
    "snd_intel_sdw_acpi"
    "snd_usb_audio"
    "snd_hwdep"
    "snd_pcm"
    "snd_timer"
    "snd"
    "soundcore"
    "snd_pcsp"
    "pcspkr"

    # Thunderbolt and USB4
    "thunderbolt"
  ];

  hardware.bluetooth.enable = false;
  services.pipewire.enable = false;
  systemd.services.systemd-rfkill.enable = false;
  systemd.sockets.systemd-rfkill.enable = false;

  # Hive’s RGB controller shares usbhid with ordinary input devices and the
  # BMC virtual keyboard, so disable only the controller rather than usbhid.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="26ce", ATTR{idProduct}=="01a2", ATTR{authorized}="0"
  '';
}
