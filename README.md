# Screen Recorder (General)

A configurable screen recording widget for **DankMaterialShell (DMS)**. 

This plugin allows you to capture a selected area or use an advanced portal to record specific windows and monitors (Niri).

## Features

- **Mode Selection**: Choose between instant region selection (uses `slurp`) or advanced portal selection for windows and monitors.
- **Keyboard Shortcuts**: Operation via keyboard hotkeys:
  - **S**: Instant Selection (wf-recorder).
  - **W**: Window/Monitor Previous (reuses last portal choice).
  - **N**: New Selection (opens portal dialog).
- **High Performance**: Uses `gpu-screen-recorder` for window and monitor modes.
- **DMS Notifications**: Optional desktop notification when your recording is saved.
- **Recording Indicator**: A pulsing indicator appears in your DankBar while a recording is active.
- **Custom Configuration**: Change settings from the DMS Settings UI.

## Configuration Options

Settings are available in **DMS Settings -> Plugins** under the **Screen Recorder (General)** item.

- **Save Path**: The directory where your recordings are stored (supports `~/` shorthand).
- **File Prefix**: The first part of the filename. Use `{mode}` as a placeholder to include the recording mode.
- **Show Label**: Toggle the text label in the bar widget on or off.
- **Pill Label Text**: Customize the text shown in the bar (defaults to "REC").
- **Show Notification**: Toggle the save notification on or off.
- **wf-recorder Flags**: Custom flags for `wf-recorder` (used for Selection mode).
- **Window Rec (GSR) Flags**: Custom flags for `gpu-screen-recorder` (used for Window/Monitor modes).
- **Timestamp Format**: Customizable date and time string using `bash` date syntax.

## Installation

1. Copy this folder to `~/.config/DankMaterialShell/plugins/recorder_general/`.
2. Ensure the following packages are installed on your system:
   - `wf-recorder`: Background recording for selection mode.
   - `slurp`: Used for selecting a screen region.
   - `gpu-screen-recorder`: Required for **Window/Monitor** recording modes.
   - `sh`: Standard system shell (POSIX-compliant).
3. Open **DMS Settings -> Plugins** and click **Scan for Plugins**.
4. Enable **Screen Recorder (General)**.
5. Go to **Bar Settings** and add it to your widget list.

## Niri Window/Monitor Recording

When using the advanced portal modes on Niri:
1. **New Selection (N)**: Clears any saved portal choice and opens the selection dialog. **Check "Remember this selection"** in the portal if you want to save it for the "Previous" option. To record a specific window with Niri's smart tracking, select **"niri Dynamic Cast Target"**.
2. **Window/Monitor (Previous) (W or Enter)**: Reuses your last saved portal selection for instant recording without a dialog.
3. The widget uses `niri msg action set-dynamic-cast-window` to ensure the focused window is targeted when using the Dynamic Cast Target.

## Compatibility

This plugin is designed for **Wayland** and works on any compatible compositor, including Niri, Sway, and Hyprland. Advanced window/monitor features currently require **Niri 25.05+**.

### Niri Keybind Example

To enable "One-Key Toggle" behavior (press once to start/open menu, press again to stop either recorder), add the following to your `binds.kdl`:

```kdl
Mod+Shift+O hotkey-overlay-title="Toggle Screen Recording" { 
    spawn "sh" "-c" "(pgrep -x wf-recorder || pgrep -x gpu-screen-reco) && (pkill -INT -x wf-recorder; pkill -INT -x gpu-screen-reco) || dms ipc widget toggle recorder_general"
}
```

## How it Works

- **Starting**: Selecting a mode from the popout menu starts the appropriate background recorder (`wf-recorder` or `gpu-screen-recorder`).
- **Stopping**: To stop and save the recording, click the pulsing pill in your DankBar or use the configured hotkey.
- **Saving**: Once stopped, the file is saved to your chosen path and a notification is sent (if enabled).
