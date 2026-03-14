# Screen Recorder (General)

A configurable screen recording widget for **DankMaterialShell (DMS)**. 

This plugin allows you to capture your entire monitor, a selected area, or a specific window (Niri only) with just a few clicks or keyboard shortcuts.

## Features

- **Mode Selection**: Choose between full-monitor, region selection (uses `slurp`), or specific window recording (Niri).
- **Keyboard Shortcuts**: Operation via keyboard hotkeys (**S** for selection, **M** for monitor, **W** for previous window selection, **N** for new window selection).
- **Universal Compatibility**: Uses `libx264` software encoding by default for `wf-recorder`.
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
- **wf-recorder Flags**: Custom flags for `wf-recorder` (used for Selection/Monitor modes).
- **Window Rec (GSR) Flags**: Custom flags for `gpu-screen-recorder` (used for Window mode).
- **Timestamp Format**: Customizable date and time string using `bash` date syntax.

## Installation

1. Copy this folder to `~/.config/DankMaterialShell/plugins/recorder_general/`.
2. Ensure the following packages are installed on your system:
   - `wf-recorder`: Background recording for selection/monitor modes.
   - `slurp`: Used for selecting a screen region.
   - `gpu-screen-recorder`: Required for **Window** recording mode (Niri).
   - `sh`: Standard system shell (POSIX-compliant).
3. Open **DMS Settings -> Plugins** and click **Scan for Plugins**.
4. Enable **Screen Recorder (General)**.
5. Go to **Bar Settings** and add it to your widget list.

## Niri Window Recording

When using the Window mode on Niri:
1. **New Window Selection (N)**: Clears any saved portal choice and opens the selection dialog. **Check "Remember this selection"** in the portal if you want to save it for the "Previous" option.
2. **Window (Previous) (W or Enter)**: Reuses your last saved portal selection for instant recording without a dialog.
3. The widget uses `niri msg action set-dynamic-cast-window` to target your currently focused window into the recording stream.

## Compatibility

This plugin is designed for **Wayland** and works on any compatible compositor, including Niri, Sway, and Hyprland. Window-specific recording currently requires **Niri 25.05+**.

### Niri Keybind Example

To enable "One-Key Toggle" behavior (press once to start/open menu, press again to stop either recorder), add the following to your `binds.kdl`:

```kdl
Mod+Shift+O hotkey-overlay-title="Toggle Screen Recording" { 
    spawn "sh" "-c" "(pgrep wf-recorder || pgrep gpu-screen-recorder) && (pkill -INT wf-recorder; pkill -INT gpu-screen-recorder) || dms ipc widget toggle recorder_general"
}
```

## How it Works

- **Starting**: Selecting a mode from the popout menu starts the appropriate background recorder (`wf-recorder` or `gpu-screen-recorder`).
- **Stopping**: To stop and save the recording, click the pulsing pill in your DankBar or use the configured hotkey.
- **Saving**: Once stopped, the file is saved to your chosen path and a notification is sent (if enabled).
