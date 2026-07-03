# OS detection — every later `[[ $_os == ... ]]` branch depends on this
# running first.

case "$OSTYPE" in
  darwin*)  _os=macos ;;
  linux*)
    if [[ -n "$WSL_DISTRO_NAME" || -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
      _os=wsl
    else
      _os=linux
    fi
    ;;
  *)        _os=other ;;
esac
export _os
