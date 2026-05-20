#!/bin/bash

echo "Starting Local Satellite Voice Assistant..."

# Ensure runtime dirs exist
export PULSE_COOKIE=/data/tmp_pulse_cookie
CONFIG_PATH=/data/options.json

mkdir -p /run/pulse
mkdir -p /data
mkdir -p /tmp/pulse
ln -s /data /app/configuration

export XDG_RUNTIME_DIR=/tmp/pulse

pulseaudio \
  --daemonize=yes \
  --system \
  --exit-idle-time=-1 \
  --disallow-exit \
  --log-target=stderr \
  --load="module-alsa-sink device=default" \
  --load="module-alsa-source device=default"

echo "Testing PulseAudio connection..."
pactl info || echo "PulseAudio not available (check host socket mapping)"

echo "Configuring application with environment variables..."
# Read all config options from options.json using jq
export WAKE_MODEL="$(jq -r '.wake_model // empty' /data/options.json)"
export STOP_MODEL="$(jq -r '.stop_model // empty' /data/options.json)"
export AUTO_GAIN="$(jq -r '.auto_gain // empty' /data/options.json)"
export MIC_NOISE_SUPPRESSION="$(jq -r '.mic_noise_suppression // empty' /data/options.json)"
export WAKEUP_SOUND="$(jq -r '.wakeup_sound // empty' /data/options.json)"
export TIMER_FINISHED_SOUND="$(jq -r '.timer_finished_sound // empty' /data/options.json)"
export PROCESSING_SOUND="$(jq -r '.processing_sound // empty' /data/options.json)"
export MUTE_SOUND="$(jq -r '.mute_sound // empty' /data/options.json)"
export UNMUTE_SOUND="$(jq -r '.unmute_sound // empty' /data/options.json)"
export PORT="$(jq -r '.port // empty' /data/options.json)"
export ENABLE_DEBUG="$(jq -r '.enable_debug // false' /data/options.json)"
export CLIENT_NAME="Local Satellite"

# Convert enable_debug boolean string to 1 or 0
if [ "$ENABLE_DEBUG" = "true" ]; then
  export ENABLE_DEBUG=1
else
  export ENABLE_DEBUG=0
fi

# Print environment variables if set
[ -n "$WAKE_MODEL" ] && echo "  WAKE_MODEL=$WAKE_MODEL"
[ -n "$STOP_MODEL" ] && echo "  STOP_MODEL=$STOP_MODEL"
[ -n "$AUTO_GAIN" ] && echo "  AUTO_GAIN=$AUTO_GAIN"
[ -n "$MIC_NOISE_SUPPRESSION" ] && echo "  MIC_NOISE_SUPPRESSION=$MIC_NOISE_SUPPRESSION"
[ -n "$WAKEUP_SOUND" ] && echo "  WAKEUP_SOUND=$WAKEUP_SOUND"
[ -n "$TIMER_FINISHED_SOUND" ] && echo "  TIMER_FINISHED_SOUND=$TIMER_FINISHED_SOUND"
[ -n "$PROCESSING_SOUND" ] && echo "  PROCESSING_SOUND=$PROCESSING_SOUND"
[ -n "$MUTE_SOUND" ] && echo "  MUTE_SOUND=$MUTE_SOUND"
[ -n "$UNMUTE_SOUND" ] && echo "  UNMUTE_SOUND=$UNMUTE_SOUND"
[ -n "$PORT" ] && echo "  PORT=$PORT"
[ -n "$CLIENT_NAME" ] && echo "  CLIENT_NAME=$CLIENT_NAME"
echo "  ENABLE_DEBUG=$ENABLE_DEBUG"

# Inject override directory into PYTHONPATH for custom components
export PYTHONPATH="/app/override:$PYTHONPATH"

echo "Launching application..."
exec /app/docker-entrypoint.sh