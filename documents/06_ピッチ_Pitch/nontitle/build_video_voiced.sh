#!/usr/bin/env bash
# 各スライドの PNG + ナレーション mp3 を結合してスライド単位のセグメントを作り、
# concat で1本の音声付き mp4 にする。
set -euo pipefail
cd "$(dirname "$0")"

FFMPEG="${FFMPEG:-/usr/bin/ffmpeg}"
FRAMES_DIR="frames"
AUDIO_DIR="audio"
OUT_DIR="output"
mkdir -p "$OUT_DIR"

# スライド毎の余白（前後の無音マージン秒）。耳と目をリラックスさせる。
LEAD=0.15
TAIL=0.25
FPS=30
# h264 CRF（数字が大きいほど低ビットレート・小サイズ）と AAC ビットレート。
CRF=26
AAC_BR=96k

concat_list="$(mktemp)"
trap 'rm -f "$concat_list"' EXIT

# 1) スライド毎にセグメントを生成
for i in $(seq -w 1 12); do
  idx=$((10#$i))
  in_png="$FRAMES_DIR/frame_${i}.png"
  in_mp3="$AUDIO_DIR/audio_${i}.mp3"
  seg="$OUT_DIR/seg_${i}.mp4"

  # ナレーションの実尺
  dur=$("$FFMPEG" -hide_banner -loglevel error -i "$in_mp3" 2>&1 \
        | grep -oE "Duration: [0-9:.]+" | head -1 || true)
  # ffprobe で正確に取得
  voice_dur=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$in_mp3")
  total=$(python3 -c "print(round($LEAD + $voice_dur + $TAIL, 3))")

  # 静止画 + (LEAD秒無音 → 音声 → TAIL秒無音) を total 秒のセグメントに
  "$FFMPEG" -y -loglevel error \
    -loop 1 -framerate "$FPS" -t "$total" -i "$in_png" \
    -f lavfi -t "$LEAD" -i "anullsrc=r=48000:cl=stereo" \
    -i "$in_mp3" \
    -f lavfi -t "$TAIL" -i "anullsrc=r=48000:cl=stereo" \
    -filter_complex "[1:a][2:a][3:a]concat=n=3:v=0:a=1[a];[0:v]scale=1920:1080,format=yuv420p[v]" \
    -map "[v]" -map "[a]" \
    -c:v libx264 -pix_fmt yuv420p -r "$FPS" -tune stillimage -preset slow -crf "$CRF" \
    -c:a aac -ar 44100 -b:a "$AAC_BR" -ac 1 \
    -movflags +faststart -shortest \
    "$seg"

  echo "file '$(realpath "$seg")'" >> "$concat_list"
  printf "[%02d] voice=%.2fs  seg=%.2fs\n" "$idx" "$voice_dur" "$total"
done

# 2) concat demuxer で連結（再エンコードなし→劣化なし）
OUT="$OUT_DIR/APE_nontitle_pitch_voiced.mp4"
"$FFMPEG" -y -loglevel error -f concat -safe 0 -i "$concat_list" -c copy "$OUT"

# 3) 中間ファイル掃除
rm -f "$OUT_DIR"/seg_*.mp4

echo "done -> $OUT"
ffprobe -v error -show_entries format=duration,size -of default=nw=1 "$OUT"
