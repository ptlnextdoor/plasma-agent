#!/bin/bash
# Build a theatrical AI voiceover timed to plasma-agent-demo.mp4 (~81s) and mux it in.
set -e
cd "$(dirname "$0")"
VOICE=${1:-Samantha}
RATE=${2:-180}
mkdir -p vo
rm -f vo/*.aiff vo/*.wav

# segment: <index> <start_seconds> "text"
seg () { say -v "$VOICE" -r "$RATE" -o "vo/$1.aiff" "$3"; echo "$1 $2"; }

seg 01 0.5  "Chronic wounds don't heal on a schedule. Cold plasma can speed them up. But there's a catch."
seg 02 9.5  "Plasma heats living tissue toward a forty degree safety limit. So the robotic arm must pause between every pass, and wait to cool."
seg 03 20.0 "A naive cloud agent would sit there, burning money, polling a sensor. Ours does something smarter."
seg 04 29.0 "It executes a pass. Then it hibernates. The instance is evicted from memory. No polling, no cost."
seg 05 39.0 "An alarm wakes it in about one millisecond. The tissue has cooled. The next pass runs. State survived the sleep."
seg 06 50.0 "Execute. Hibernate. Wake. Continue. Autonomously, pass after pass, to full coverage."
seg 07 60.0 "Ninety nine point nine percent of idle cost, gone. The same loop maps one to one onto Alibaba F C Sandbox deep hibernation."
seg 08 70.0 "Real plasma hardware. A real waiting phase. A real cost model. This is the Plasma Treatment Agent."

# Convert each to wav and place on a silent 82s bed at its start time.
DUR=82
ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=stereo -t $DUR vo/bed.wav 2>/dev/null

FILTER=""
INPUTS="-i vo/bed.wav"
IDX=1
declare -a STARTS=(0.5 9.5 20.0 29.0 39.0 50.0 60.0 70.0)
for n in 01 02 03 04 05 06 07 08; do
  ffmpeg -y -i "vo/$n.aiff" -ar 44100 -ac 2 "vo/$n.wav" 2>/dev/null
  INPUTS="$INPUTS -i vo/$n.wav"
  ST=${STARTS[$((IDX-1))]}
  MS=$(python3 -c "print(int($ST*1000))")
  FILTER="$FILTER[$IDX]adelay=${MS}|${MS}[a$IDX];"
  IDX=$((IDX+1))
done

# Mix all delayed voice tracks + bed.
MIXIN="[0]"
for i in 1 2 3 4 5 6 7 8; do MIXIN="$MIXIN[a$i]"; done
ffmpeg -y $INPUTS -filter_complex "${FILTER}${MIXIN}amix=inputs=9:normalize=0[vraw]; \
  [vraw]highpass=f=90,lowpass=f=9000,aecho=0.8:0.85:40:0.18,loudnorm=I=-16:TP=-1.5:LRA=11[vout]" \
  -map "[vout]" vo/narration.wav 2>/dev/null

echo "narration built:"; ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 vo/narration.wav

# Mux narration onto the video (replace/append audio).
ffmpeg -y -i plasma-agent-demo.mp4 -i vo/narration.wav \
  -c:v copy -c:a aac -b:a 160k -shortest -movflags +faststart \
  plasma-agent-demo-voiced.mp4 2>/dev/null

echo "FINAL:"; ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 plasma-agent-demo-voiced.mp4
ls -la plasma-agent-demo-voiced.mp4
