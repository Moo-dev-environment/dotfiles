# Linux only. `return` at the top level of a sourced file just stops sourcing
# this module — the loader moves on to the next one.
[[ $_os == linux || $_os == wsl ]] || return 0

alias localip='hostname -I | awk "{print \$1}"'

# Generic opener (Omarchy) — macOS has a real `open`.
if command -v xdg-open &>/dev/null; then
  open() ( xdg-open "$@" >/dev/null 2>&1 & )
fi

if [[ $_os == linux ]] \
  && command -v lsblk &>/dev/null \
  && command -v omarchy-drive-select &>/dev/null \
  && command -v wipefs &>/dev/null \
  && command -v parted &>/dev/null \
  && command -v partprobe &>/dev/null \
  && command -v udevadm &>/dev/null \
  && command -v mkfs.exfat &>/dev/null
then
  iso2sd() {
    if (( $# < 1 )); then
      echo 'Usage: iso2sd <input_file> [output_device]'; return 1
    fi
    local iso="$1" drive="$2"
    if [[ -z $drive ]]; then
      local available_sds
      available_sds=$(lsblk -dpno NAME | grep -E '/dev/sd')
      [[ -z $available_sds ]] && { echo "No SD drives found"; return 1; }
      drive=$(omarchy-drive-select "$available_sds")
      [[ -z $drive ]] && { echo "No drive selected"; return 1; }
    fi
    sudo dd bs=4M status=progress oflag=sync if="$iso" of="$drive"
    sudo eject "$drive"
  }

  format-drive() {
    if (( $# != 2 )); then
      echo 'Usage: format-drive <device> <name>'; return 1
    fi
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -rq "confirm?Are you sure? (y/N): "; echo
    [[ $confirm =~ ^[Yy]$ ]] || return 1
    sudo wipefs -a "$1"
    sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
    sudo parted -s "$1" mklabel gpt
    sudo parted -s "$1" mkpart primary 1MiB 100%
    sudo parted -s "$1" set 1 msftdata on
    local partition="$([[ $1 == *nvme* ]] && echo "${1}p1" || echo "${1}1")"
    sudo partprobe "$1" || true
    sudo udevadm settle || true
    sudo mkfs.exfat -n "$2" "$partition"
    echo "Drive $1 formatted as exFAT and labeled '$2'."
  }
fi
