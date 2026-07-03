# ~/.zprofile — login-shell setup.

# Toolchain env shim: rustup / uv / mise installers write ~/.local/bin/env to
# put their bins on PATH (the Omarchy bash loader sources this too). Idempotent.
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
