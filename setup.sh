#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")" && pwd)
bin_dir="$HOME/bin"
services_dir="$HOME/Library/Services"
script_link="$bin_dir/convert-gifs-to-mp4.sh"
workflow_link="$services_dir/Convert GIF to MP4.workflow"

mkdir -p "$bin_dir" "$services_dir"

link_into_place() {
  local source=$1
  local destination=$2

  if [[ -e "$destination" && ! -L "$destination" ]]; then
    printf 'Refusing to replace existing non-symlink: %s\n' "$destination" >&2
    exit 1
  fi

  ln -sfn "$source" "$destination"
}

link_into_place "$repo_dir/convert-gifs-to-mp4.sh" "$script_link"
link_into_place "$repo_dir/Convert GIF to MP4.workflow" "$workflow_link"

printf 'Installed script and Finder Quick Action symlinks.\n'
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *)
    printf '\nWarning: ~/bin is not on your PATH. To run the script by name:\n'
    printf '  zsh: add `export PATH="$HOME/bin:$PATH"` to ~/.zprofile, then run `source ~/.zprofile`\n'
    printf '  fish: run `fish_add_path ~/bin`\n'
    ;;
esac
