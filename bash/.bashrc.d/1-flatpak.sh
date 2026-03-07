# Based off of this post: https://github.com/flatpak/flatpak/issues/994#issuecomment-1464841258
alias_flatpak_exports() {
  # list of overrides id -> name
  declare -A overrides=(
    ["fr.handbrake.ghb"]="handbrake"
    ["cc.arduino.IDE2"]="arduino"
    ["com.obsproject.Studio"]="obs"
    ["org.onlyoffice.desktopeditors"]="onlyoffice"
    ["net.davidotek.pupgui2"]="protonup"
    ["org.gnome.World.PikaBackup"]="pika"
    ["org.bunkus.mkvtoolnix-gui"]="mkvtoolnix"
    ["com.brave.Browser"]="brave"
    ["org.gnome.Snapshot"]="camera"
  )

  local item app_id target_name

  for item in {${XDG_DATA_HOME:-$HOME/.local/share},/var/lib}/flatpak/exports/bin/*; do
    [[ -x "$item" ]] || continue

    # get last portion of id
    app_id="${item##*/}"

    # apply overrides
    target_name="${overrides[$app_id]:-${app_id##*.}}"

    # Force lowercase for all aliases
    target_name="${target_name,,}"

    # Only create the alias if the name isn't already a system command
    if [ ! $(command -v "$target_name") ]; then
      alias "$target_name"="$item"
    fi
  done
}

# only set up if flatpak is installed
if [ $(command -v flatpak) ]; then
  alias_flatpak_exports
fi
