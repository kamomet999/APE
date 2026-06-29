#!/usr/bin/env bash
# APE ノンタイトル ピッチ動画ビルダー
# 12枚のPNGを、各スライド固有の尺＋クロスフェードで mp4 に出力する。
set -euo pipefail

cd "$(dirname "$0")"

FFMPEG="${FFMPEG:-/usr/bin/ffmpeg}"
FRAMES_DIR="frames"
OUT_DIR="output"
mkdir -p "$OUT_DIR"

# 各スライドの表示秒数（合計 = 動画尺）。
# 1:カバー 2:課題 3:原体験(長め) 4:ソリューション 5:プロト 6:WhyNow
# 7:差別化 8:モデル 9:トラクション 10:ロードマップ 11:ビジョン 12:CTA
DURATIONS=(5 16 22 18 15 18 18 18 16 15 14 8)
FPS=30
CROSSFADE=0.6

# 1) 各PNGをそれぞれの尺で個別mp4化（無音）。
tmp_files=()
for i in $(seq -w 1 12); do
  idx=$((10#$i))
  dur=${DURATIONS[$((idx-1))]}
  in_png="$FRAMES_DIR/frame_${i}.png"
  out_mp4="$OUT_DIR/seg_${i}.mp4"
  "$FFMPEG" -y -loglevel error -loop 1 -t "$dur" -framerate "$FPS" -i "$in_png" \
    -vf "scale=1920:1080,format=yuv420p" \
    -c:v libx264 -pix_fmt yuv420p -r "$FPS" -tune stillimage -movflags +faststart \
    "$out_mp4"
  tmp_files+=("$out_mp4")
done

# 2) クロスフェードで連結。入力数が多いので xfade を逐次チェーン。
# offset = 累積尺 - クロスフェード分。
inputs=()
for f in "${tmp_files[@]}"; do
  inputs+=( -i "$f" )
done

# build filter_complex for xfade chain
filter=""
prev="[0:v]"
running=${DURATIONS[0]}
for j in $(seq 1 11); do
  next_idx=$((j))
  next_in="[${next_idx}:v]"
  # offset is end of previous accumulated minus crossfade
  off=$(python3 -c "print(round($running - $CROSSFADE, 3))")
  out_lbl="[v${j}]"
  filter+="${prev}${next_in}xfade=transition=fade:duration=${CROSSFADE}:offset=${off}${out_lbl};"
  prev="$out_lbl"
  # next slide adds its duration minus crossfade overlap
  running=$(python3 -c "print(round($running + ${DURATIONS[$j]} - $CROSSFADE, 3))")
done
# trim trailing ;
filter="${filter%;}"

OUT="$OUT_DIR/APE_nontitle_pitch.mp4"
"$FFMPEG" -y -loglevel error "${inputs[@]}" \
  -filter_complex "$filter" -map "$prev" \
  -c:v libx264 -pix_fmt yuv420p -r "$FPS" -movflags +faststart -preset medium -crf 20 \
  "$OUT"

# 3) clean intermediate segments
rm -f "$OUT_DIR"/seg_*.mp4

echo "done -> $OUT"
ls -la "$OUT"
