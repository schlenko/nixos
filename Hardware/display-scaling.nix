{ ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";      # VS Code/Electron native Wayland
    GDK_DPI_SCALE = "0.8";     # GTK text scale (Nemo, polkit dialog)
    QT_SCALE_FACTOR = "0.8";   # Qt apps
  };
}