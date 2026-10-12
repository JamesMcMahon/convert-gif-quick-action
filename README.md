# Convert GIF to MP4

macOS Quick Actions to convert GIF files to MP4 with `ffmpeg`. One keeps original GIFs; the other moves each successfully converted original to the Trash. Existing MP4 files are not overwritten.

## Install

1. Install FFmpeg: `brew install ffmpeg`.
2. Clone this repo and enter its directory.
3. Run `./setup.sh`.
4. In Finder, right-click a file or folder, open **Quick Actions → Customize**, and enable the Quick Actions you want to use: **Convert GIF to MP4** and/or **Convert GIF to MP4 and Trash Original**. Enable each one before it appears in the Quick Actions menu.

The setup script symlinks `convert-gifs-to-mp4.sh` into `~/bin/` and both Finder Quick Actions into `~/Library/Services/`. It does not change your shell configuration. If `~/bin` is not on your PATH, it prints instructions for zsh and fish:

- **zsh:** Add `export PATH="$HOME/bin:$PATH"` to `~/.zprofile`, then run `source ~/.zprofile`.
- **fish:** Run `fish_add_path ~/bin`.

Keep the repo in place after setup: both symlinks point back to files in the cloned directory. The workflow adds common Homebrew locations to its PATH so it can find `ffmpeg` when launched from Finder.

## Use

In Finder, select one or more GIFs and/or folders, then choose **Quick Actions → Convert GIF to MP4** to keep originals, or **Convert GIF to MP4 and Trash Original** to move successfully converted GIFs to the Trash. Each selected GIF is converted to its own MP4 beside the source. Selected folders are searched recursively. Failed conversions and skipped static GIFs are left alone.
