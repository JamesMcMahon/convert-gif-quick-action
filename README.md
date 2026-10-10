# Convert GIF to MP4

Converts GIF files to MP4 with `ffmpeg`. Original GIFs are kept, and existing MP4 files are not overwritten.

## Install

1. Install FFmpeg: `brew install ffmpeg`.
2. Clone this repo and enter its directory.
3. Run `./setup.sh`.

The setup script symlinks `convert-gifs-to-mp4.sh` into `~/bin/` and the Finder Quick Action into `~/Library/Services/`. It adds `~/bin` to the PATH in `~/.zprofile`, for macOS's default zsh shell. Restart Terminal or run `source ~/.zprofile` to use the script by name from a terminal.

Keep the repo in place after setup: both symlinks point back to files in the cloned directory. The workflow adds common Homebrew locations to its PATH so it can find `ffmpeg` when launched from Finder.

## Use

In Finder, right-click a GIF or folder and select **Quick Actions → Convert GIF to MP4**. Folders are searched recursively.
