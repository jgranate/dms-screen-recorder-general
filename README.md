# Screen Recorder (General)

A configurable screen recording widget for **DankMaterialShell (DMS)**. 

This plugin allows you to capture your entire monitor or a selected area with just a few clicks or keyboard shortcuts.

## Features

- **Mode Selection**: Choose between full-monitor or region selection (uses `slurp`).
- **Keyboard Shortcuts**: Operation via keyboard hotkeys (**S** for selection, **M** for monitor).
- **Universal Compatibility**: Uses `libx264` software encoding by default.
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
- **wf-recorder Flags**: Custom flags for `wf-recorder` (e.g., hardware acceleration).
- **Timestamp Format**: Customizable date and time string using `bash` date syntax.

## Installation

1. Copy this folder to `~/.config/DankMaterialShell/plugins/recorder_general/`.
2. Ensure the following packages are installed on your system:
   - `wf-recorder`: The background recording utility.
   - `slurp`: Used for selecting a screen region.
   - `sh`: Standard system shell (POSIX-compliant).
3. Open **DMS Settings -> Plugins** and click **Scan for Plugins**.
4. Enable **Screen Recorder (General)**.
5. Go to **Bar Settings** and add it to your widget list.

## Compatibility

This plugin is designed for **Wayland** and works on any compatible compositor, including Niri, Sway, and Hyprland.

### Niri Keybind Example

To enable "One-Key Toggle" behavior (press once to start/open menu, press again to stop), add the following to your `binds.kdl`:

```kdl
Mod+Shift+O hotkey-overlay-title="Toggle Screen Recording" { 
    spawn "sh" "-c" "pgrep wf-recorder && pkill -INT wf-recorder || dms ipc widget toggle recorder_general"
}
```

## How it Works

- **Starting**: Selecting a mode from the popout menu starts `wf-recorder` in the background.
- **Stopping**: To stop and save the recording, click the pulsing pill in your DankBar or use the configured hotkey.
- **Saving**: Once stopped, the file is saved to your chosen path and a notification is sent (if enabled).
