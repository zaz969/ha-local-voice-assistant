# Local Linux Voice Assistant - Configuration Reference

Use [Home Assistant Assist](https://www.home-assistant.io/voice_control/) with a local microphone for voice control without cloud dependencies.

## Quick Start

After installation and startup:

1. **Wait 10 seconds** for the ESPHome API server to initialize
2. Go to **Settings** → **Devices & Services**
3. If prompted, click to add the discovered ESPHome device
4. Or manually add: Settings → Integrations → Create Integration → ESPHome
   - Host: `<YOUR HOME ASSISTANT IP>` (Hostname or `localhost` will not work)
   - Port: `6053` or the port of your choosing

See [ESPHome integration documentation](https://www.home-assistant.io/integrations/esphome/) for details.

## How Configuration Works

This addon extends the official linux-voice-assistant image and reads Home Assistant addon configuration from `/data/options.json`. Here's the flow:

1. You configure settings in Home Assistant addon UI
2. Settings are saved to `/data/options.json`
3. The `run.sh` script reads this file using `jq`
4. Configuration values are exported as environment variables (WAKE_MODEL, STOP_MODEL, AUTO_GAIN, etc.)
5. The linux-voice-assistant service reads these environment variables

This approach is independent of Home Assistant's base image and works with custom base images.

Audio device configuration is handled through Home Assistant's audio system integration (`audio: true`), which provides dropdown selectors on the addon configuration page for easy device selection before the addon starts.

## Audio Device Selection

Audio input (microphone) and output (speaker) devices are configured via dropdown menus on the addon settings page.

**To select audio devices:**
1. Open the addon settings page
2. Look for **Microphone** dropdown - select your desired input device
3. Look for **Speaker** dropdown - select your desired output device  
4. Save the settings
5. Start the addon

These selections will be passed to the linux-voice-assistant and persist across restarts.

## Configuration Options

### Audio Processing

#### `auto_gain`
- **Type**: Integer (0-31)
- **Default**: 0 (disabled)
- **Description**: Microphone auto-gain control level.
  - `0` = Disabled (use physical microphone volume)
  - `1-10` = Light normalization
  - `11-20` = Moderate gain control
  - `21-31` = Aggressive amplification
- **Recommendation**: Start with 0 if your microphone has good volume, try 15-20 for quiet mics

#### `mic_noise_suppression`
- **Type**: Integer (0-4)
- **Default**: 0 (disabled)
- **Description**: Noise suppression level (WebRTC-based).
  - `0` = Disabled
  - `1` = Low (minimal processing)
  - `2` = Moderate (good for background noise)
  - `3` = High (reduces more noise)
  - `4` = Very High (may distort speech if too aggressive)
- **Recommendation**: Try 2-3 for noisy environments, 0-1 for clean audio

### Wake Word Configuration

#### `wake_model`
- **Type**: String
- **Default**: `okay_nabu`
- **Description**: Wake word model to use for local detection.
- **Available Models**:
  - **Standard Models**: `okay_nabu`, `hey_mycroft`, `hey_jarvis`, `alexa`, `choo_choo_homie`, `hey_luna`, `hey_home_assistant`
  - **OpenWakeWord v0.1**: `alexa_v0.1`, `hey_jarvis_v0.1`, `hey_mycroft_v0.1`, `hey_rhasspy_v0.1`, `ok_nabu_v0.1`
- **Notes**: 
  - Each model is a separate ML model with different accuracy/CPU tradeoffs

#### `stop_model`
- **Type**: String
- **Default**: `stop`
- **Description**: Model for stop/silence detection.

### Sound Feedback Configuration

#### `wakeup_sound`
- **Type**: String
- **Default**: Empty (uses default)
- **Description**: Path to audio file that plays when wake word is detected. Supported formats: FLAC, WAV
- **Custom file example**: `/share/my-sounds/wake.wav`

#### `timer_finished_sound`
- **Type**: String
- **Default**: Empty (uses default)
- **Description**: Path to audio file that plays when a timer finishes.

#### `processing_sound`
- **Type**: String
- **Default**: Empty (uses default)
- **Description**: Short audio file that plays while the assistant is thinking/processing.

#### `mute_sound`
- **Type**: String
- **Default**: Empty (uses default)
- **Description**: Audio file that plays when the device is muted.

#### `unmute_sound`
- **Type**: String
- **Default**: Empty (uses default)
- **Description**: Audio file that plays when the device is unmuted.

### Advanced Configuration

#### `port`
- **Type**: Integer (1024-65535)
- **Default**: 6053
- **Description**: Port for the ESPHome API protocol. Must match what you use when adding the ESPHome integration in Home Assistant.
- **Note**: Only change if port 6053 conflicts with another service

#### `enable_debug`
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable verbose debug logging in addon logs. Useful for troubleshooting.



## Wake Word Models

### Pre-loaded Models
All standard wake word models are included. They are located in `/wakewords/`:
- Each model has a `.tflite` file (the ML model) and `.json` file (configuration)
- Models are pre-trained for different phrases and accents

### How Wake Words Work
1. Audio is continuously analyzed locally on the device
2. When the wake word is detected, a notification sound plays (if enabled)
3. Remaining audio is sent to Home Assistant for the voice command
4. This process is entirely local - no audio is sent to cloud services

### Performance
- Wake word detection: < 500ms latency
- CPU usage: ~5-10% during listening
- Minimal memory footprint

## Troubleshooting

### Audio Device Not Working
1. Open the addon settings page
2. Verify the correct microphone is selected in the **Microphone** dropdown
3. Verify the correct speaker is selected in the **Speaker** dropdown
4. Save settings and restart the addon
5. Check that the devices are recognized by your system

### Microphone Too Quiet
1. Check physical microphone volume and audio levels
2. Verify the correct microphone is selected in the addon settings
3. Increase `auto_gain` in the addon configuration (try 15-20)

### Picking Up Background Noise
1. Increase `mic_noise_suppression` (try 2-4)
2. Reposition microphone away from noise sources
3. Reduce `auto_gain` if set too high

### Not Detecting Wake Word
1. Speak clearly and naturally
2. Ensure wake word model matches what you're saying
3. Check microphone input in debug logs
4. Try lowering `mic_noise_suppression` if it's filtering speech

### High CPU Usage
1. Reduce `auto_gain` (lower values = less processing)
2. Reduce `mic_noise_suppression` (lower values = less processing)
3. Use a simpler wake word model if available

## Architecture Notes

**Setup**:
- Extends official linux-voice-assistant v1.1.9 Docker image
- Adds dependencies: `jq` (for JSON parsing), `alsa-utils`, `pulseaudio`, `pipewire-bin`
- Runs with host networking for MAC address consistency
- Home Assistant addon acts as configuration wrapper

**Configuration Flow**:
1. Home Assistant saves addon configuration to `/data/options.json`
2. `run.sh` script uses `jq` to parse the JSON file
3. Configuration values are exported as environment variables:
   - WAKE_MODEL, STOP_MODEL, AUTO_GAIN, MIC_NOISE_SUPPRESSION
   - WAKEUP_SOUND, TIMER_FINISHED_SOUND, PROCESSING_SOUND
   - MUTE_SOUND, UNMUTE_SOUND, PORT, ENABLE_DEBUG
4. linux-voice-assistant reads these environment variables on startup

**Service Stack**:
- **linux-voice-assistant**: Runs on configured port (default 6053), handles ESPHome API
- **PulseAudio**: Manages audio input/output
- **Run Script**: Orchestrates startup and environment configuration

## Performance Characteristics

| Aspect | Value |
|--------|-------|
| Wake word latency | < 500ms |
| Audio sample rate | 16kHz mono |
| Typical CPU usage | 5-15% |
| RAM usage | ~100-200MB |
| Network bandwidth | ~30-60 kbps (for audio stream to Home Assistant) |

## Links

- [linux-voice-assistant GitHub](https://github.com/OHF-Voice/linux-voice-assistant/)
- [Wyoming Integration Docs](https://www.home-assistant.io/integrations/wyoming/)
- [Home Assistant Voice Control](https://www.home-assistant.io/voice_control/)
- [OpenWakeWord Models](https://github.com/dscripka/openWakeWord)

[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
