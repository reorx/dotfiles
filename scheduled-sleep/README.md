# Scheduled Sleep for Mac mini

Automatically put the Mac to sleep at a scheduled time and wake it up later. Designed for headless Mac mini setups that should stay awake during the day but sleep overnight.

## How It Works

- **Sleep at 01:00** — A LaunchDaemon runs `pmset sleepnow` to force the Mac into sleep mode
- **Wake at 05:30** — `pmset repeat wake` uses the hardware RTC clock to wake the Mac

Why not just use `pmset repeat sleep`? Because the "Prevent automatic sleeping when display is off" setting (required for Mac mini to stay awake during the day) blocks scheduled sleep events. `pmset sleepnow` is a direct command that bypasses this limitation.

## Prerequisites

- **"Prevent automatic sleeping when display is off"** must be **ON** in System Settings → Energy
- This keeps the Mac mini awake during the day (since it has no built-in display)

## Usage

```bash
# Start: install the daemon + set wake schedule
sudo ./scheduled-sleep-ctl.sh start
sudo pmset repeat wake MTWRFSU 05:30:00

# Check status
./scheduled-sleep-ctl.sh status

# Stop: remove the daemon
sudo ./scheduled-sleep-ctl.sh stop
# Optionally cancel the wake schedule too:
sudo pmset repeat cancel
```

## Customizing the Sleep Time

Edit the `Hour` and `Minute` values in `com.local.scheduled-sleep.plist`:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>1</integer>    <!-- 0-23 -->
    <key>Minute</key>
    <integer>0</integer>    <!-- 0-59 -->
</dict>
```

Then re-run `sudo ./scheduled-sleep-ctl.sh stop && sudo ./scheduled-sleep-ctl.sh start`.

## Files

| File | Purpose |
|------|---------|
| `com.local.scheduled-sleep.plist` | LaunchDaemon that triggers `pmset sleepnow` |
| `scheduled-sleep-ctl.sh` | Control script (start/stop/status) |
| `README.md` | This file |
