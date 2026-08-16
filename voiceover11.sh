#!/bin/bash
# Studio voiceover via ElevenLabs, timed to captions, muxed into the demo.
set -e
cd "$(dirname "$0")"
: "${ELEVEN_KEY:?set ELEVEN_KEY}"
VOICE_ID="${VOICE_ID:-JBFqnCBsd6RMkjVDRZzb}"   # George - Warm, Captivating Storyteller
MODEL="eleven_multilingual_v2"
mkdir -p vo11
rm -f vo11/*.mp3 vo11/*.wav

tts () {
  local idx="$1"; local text="$2"
  curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}" \
    -H "xi-api-key: ${ELEVEN_KEY}" -H "Content-Type: application/json" \
    -d "$(python3 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"model_id":sys.argv[2],"voice_settings":{"stability":0.45,"similarity_boost":0.75,"style":0.35,"use_speaker_boost":True}}))' "$text" "$MODEL")" \
    -o "vo11/$idx.mp3"
  # fail fast if API returned JSON error instead of audio
  if head -c 1 "vo11/$idx.mp3" | grep -q '{'; then echo "TTS ERROR seg $idx:"; cat "vo11/$idx.mp3"; exit 1; fi
  ffmpeg -y -i "vo11/$idx.mp3" -ar 44100 -ac 2 "vo11/$idx.wav" 2>/dev/null
  echo "seg $idx ok"
}

tts 01 "Chronic wounds don't heal on a schedule. Cold plasma can speed them up. But there's a catch."
tts 02 "Plasma heats living tissue toward a forty-degree safety limit. So the robotic arm must pause between every pass, and wait to cool."
tts 03 "A naive cloud agent would sit there, burning money, polling a sensor. Ours does something smarter."
tts 04 "It executes a pass. Then it hibernates. The instance is evicted from memory. No polling. No cost."
tts 05 "An alarm wakes it in about one millisecond. The tissue has cooled. The next pass runs. State survived the sleep."
tts 06 "Execute. Hibernate. Wake. Continue. Autonomously, pass after pass, to full coverage."
tts 07 "Ninety-nine point nine percent of idle cost, gone. The same loop maps one-to-one onto Alibaba F-C Sandbox deep hibernation."
tts 08 "Real plasma hardware. A real waiting phase. A real cost model. This is the Plasma Treatment Agent."

# Silent bed.
DUR=82
ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=stereo -t $DUR vo11/bed.wav 2>/dev/null

declare -a STARTS=(0.5 9.5 20.0 29.0 39.0 50.0 60.0 70.0)
INPUTS="-i vo11/bed.wav"; FILTER=""; IDX=1
for n in 01 02 03 04 05 06 07 08; do
  INPUTS="$INPUTS -i vo11/$n.wav"
  ST=${STARTS[$((IDX-1))]}; MS=$(python3 -c "print(int($ST*1000))")
  FILTER="$FILTER[$IDX]adelay=${MS}|${MS}[a$IDX];"
  IDX=$((IDX+1))
done
MIXIN="[0]"; for i in 1 2 3 4 5 6 7 8; do MIXIN="$MIXIN[a$i]"; done
ffmpeg -y $INPUTS -filter_complex "${FILTER}${MIXIN}amix=inputs=9:normalize=0[vraw]; \
  [vraw]loudnorm=I=-16:TP=-1.5:LRA=11[vout]" -map "[vout]" vo11/narration.wav 2>/dev/null

echo "narration:"; ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 vo11/narration.wav
ffmpeg -y -i plasma-agent-demo.mp4 -i vo11/narration.wav \
  -c:v copy -c:a aac -b:a 192k -shortest -movflags +faststart \
  plasma-agent-demo-final.mp4 2>/dev/null
echo "FINAL:"; ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 plasma-agent-demo-final.mp4
ls -la plasma-agent-demo-final.mp4
