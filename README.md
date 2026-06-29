# Local Satellite Voice Assistant - Home Assistant Addon

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

A Home Assistant addon that enables local voice control on Linux systems through [Home Assistant Assist](https://www.home-assistant.io/voice_control/) using a connected microphone and speakers on the same machine running Home Assistant.

This addon runs [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant/) which provides:
- **Local wake word detection** - Detects phrases like "Okay Nabu" locally without sending audio to cloud services
- **Audio processing** - Noise suppression and auto-gain control for clearer audio
- **ESPHome integration** - Integrates directly with Home Assistant via the ESPHome protocol
- **Zero configuration** - Automatically detects audio devices and network configuration

Part of the [Year of Voice](https://www.home-assistant.io/blog/2022/12/20/year-of-voice/) initiative.

## Prerequisites

- Home Assistant 2023.12.1 or later with the ability to install apps (formerly addons)
- Connected microphone and speaker (USB or integrated audio)
- Audio support enabled in Home Assistant

## Installation

1. Install the "Assist Microphone" addon from the Addon Store
2. Start the addon and wait ~10 seconds for the ESPHome API to initialize
3. Open Home Assistant and go to Settings → Devices & Services → Integrations
4. Add a new Integration for "ESPHome".
5. Set the IP of the "ESPHome" device to the Home Assistant device's IP (Hostname will not work)
6. Set the port to the port configured in the app or 6053 by default.

## Configuration

All configuration is optional - the addon auto-detects most settings. You can customize via the addon settings UI.

### Audio Device Selection
Audio input (microphone) and output (speaker) devices are selectable via dropdown menus on the addon configuration page before starting the addon.

### Audio Processing
- **Microphone Volume (0-100)**: Sets the microphone capture level; 100 is max volume.
- **Auto Gain (0-31)**: Automatically adjusts microphone volume. 0 = disabled, higher values = more aggressive
- **Noise Suppression (0-4)**: Reduces background noise. 0 = disabled, 4 = maximum
- **Stop Model**: The phrase to stop listening (default: "stop")

### Conversation and Timer Settings
- **Continue Conversation Delay (seconds)**: Delay before the assistant continues listening or accepts follow-up speech after a response.
- **Timer Max Ring Seconds**: Maximum length of the timer ring notification (default: 60)

### Sound Feedback
Customize audio feedback sounds (leave blank to use defaults):
- **Wake Sound**: Plays when the wake word is detected
- **Timer Finished Sound**: Notification when a timer completes
- **Processing Sound**: Audio while the assistant is thinking
- **Mute/Unmute Sounds**: Feedback when toggling mute

You can customize these with your own audio files (WAV/FLAC format).

### Advanced Options
- **Preferences File**: Location to store persistent user preferences (default: `/share/linux-voice-assistant/preferences.json`)
- **ESPHome Port**: Port for the ESPHome protocol (default: 6053, usually no need to change)
- **Debug Logging**: Enable verbose logging for troubleshooting

Note: Audio input and output devices are auto-detected. To see available devices, enable debug logging and check the addon logs.

## Usage

Once the addon is running and added to Home Assistant:

1. **Say the wake word** (default: "Okay Nabu")
2. **Speak your command** (e.g., "Turn on the lights")
3. **Wait for the response** - The assistant will respond through the configured speaker

The device integrates directly via Home Assistant's native ESPHome integration.

## Wake Word Detection

The following wake word models are available:

**microWakeWord:**
- `okay_nabu` - Default wake word
- `alexa` - Alexa wake word
- `hey_jarvis` - Jarvis wake word
- `hey_mycroft` - Mycroft wake word
- `hey_morgan` - Morgan wake word
- `hey_luna` - Luna wake word
- `hey_home_assistant` - Home Assistant wake word
- `stop` - Stop wake word
- `okay_computer` - Okay Computer wake word
- `choo_choo_homie` - Choo Choo Homie wake word

**openWakeWord:**
- `ok_nabu` - Default wake word
- `alexa` - Alexa wake word
- `hey_jarvis` - Jarvis wake word
- `hey_mycroft` - Mycroft wake word
- `hey_rhasspy` - Rhasspy wake word

## Troubleshooting

### Addon won't start
- Check the logs for audio device errors
- Verify audio is enabled in Home Assistant
- Check that PulseAudio/audio system is working

### Microphone not detected
- Verify your microphone is plugged in and recognized by the system

## Performance Notes

- **Resource usage**: Minimal - runs efficiently on Raspberry Pi and similar devices
- **Latency**: Local wake word detection typically < 500ms
- **Network**: Only communicates with Home Assistant on the same network
- **Audio**: 16kHz mono audio for wake word detection

## Architecture

- **Base Image**: Extends official linux-voice-assistant v1.1.9 Docker image with additional dependencies (jq for JSON parsing)
- **Configuration Method**: Reads `/data/options.json` using `jq` and exports as environment variables
- **Integration**: Direct ESPHome API on port 6053 (or configured port), exposed via host network
- **Networking**: Uses host network mode for consistent MAC address recognition
- **Audio**: PulseAudio/Pipewire for audio input/output with ALSA support
- **Wake Words**: Local on-device detection with pre-trained ML models

## Links

- [linux-voice-assistant GitHub](https://github.com/OHF-Voice/linux-voice-assistant/)
- [Home Assistant ESPHome Integration](https://www.home-assistant.io/integrations/esphome/)
- [Home Assistant Voice Control](https://www.home-assistant.io/voice_control/)
- [Home Assistant Assist Documentation](https://www.home-assistant.io/integrations/assist_pipeline/)