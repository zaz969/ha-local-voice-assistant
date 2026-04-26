# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-04-26

### Added

- Initial release of Local Satellite Voice Assistant addon
- Wake word and stop word detection with configurable models
- Microphone audio input with automatic gain control and noise suppression
- Customizable audio feedback sounds (wakeup, timer, processing, mute/unmute)
- Configuration script that reads addon options and exports as environment variables
- Optional debug logging and output of configured settings
- Full English translation for all configuration options
- Support for multiple architectures (amd64, aarch64)

### Changed

- Configuration method uses jq-based JSON parsing from `/data/options.json` for independence from Home Assistant base image
- Host networking mode enabled for MAC address consistency with ESPHome device recognition

### Technical Details

- Requires Home Assistant 2023.12.1 or later
- Uses PulseAudio for audio handling
- Requires privileged access for SYS_ADMIN and SYS_NICE capabilities
- Direct access to `/dev/snd` for audio device control
- Persistent storage via `/share` directory for preferences
- Uses ESPHome API on port 6053 for Home Assistant integration
- Configuration parsing uses `jq` to extract values from `/data/options.json`
- Environment variables set: WAKE_MODEL, STOP_MODEL, AUTO_GAIN, MIC_NOISE_SUPPRESSION, WAKEUP_SOUND, TIMER_FINISHED_SOUND, PROCESSING_SOUND, MUTE_SOUND, UNMUTE_SOUND, PORT, ENABLE_DEBUG
- Host network mode ensures constant MAC address for ESPHome device recognition
