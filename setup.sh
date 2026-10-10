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

zprofile="$HOME/.zprofile"
path_line='export PATH="$HOME/bin:$PATH"'
if ! [[ -f "$zprofile" ]] || ! grep -Fqx "$path_line" "$zprofile"; then
  printf '\n# Added by gif-script setup\n%s\n' "$path_line" >> "$zprofile"
fi

printf 'Installed script and Finder Quick Action symlinks.\n'
printf 'Added ~/bin to PATH in ~/.zprofile; restart Terminal or run: source ~/.zprofile\n'
