# APE × ノンタイトル ピッチ資料

起業家リアリティショー「ノンタイトル」エントリー／ピッチ用のスライドと動画を格納しています。

## 成果物

| ファイル | 内容 |
|---|---|
| `index.html` | 12枚のHTMLスライド（1920×1080）。ブラウザでそのまま閲覧可。 |
| `output/APE_nontitle_pitch.mp4` | 動画版（h264 / 1920×1080 / 30fps / 約2分56秒）。 |
| `frames/frame_NN.png` | 各スライドのPNG静止画。サムネ・SNS切り出し用。 |
| `build_frames.py` | `index.html` を1枚ずつ Chromium で PNG 化するスクリプト。 |
| `build_video.sh` | PNG をクロスフェードで連結し mp4 に書き出すスクリプト。 |
| `slides_split/` | スライド単独 HTML（再レンダリング時に再生成される中間ファイル）。 |

## 構成（12枚）

1. **COVER** — 「農業は、博打じゃない。」
2. **PROBLEM** — 3つの博打（何を/いくらで/どこに売る）
3. **FOUNDER'S STORY** — 「儲かる作物は何ですか？」誰も答えられなかった。
4. **SOLUTION** — APE = 3つの科学的エンジン
5. **PROTOTYPE** — 30秒デモ（土壌診断→収益→販路）
6. **WHY NOW** — 気候変動／大量離農／データ解放
7. **DIFFERENTIATION** — 既存アグリテック vs APE
8. **BUSINESS MODEL** — ToB / ToG / マッチング
9. **TRACTION** — プロダクト＋顧客の状況
10. **ROADMAP** — 2026〜2028
11. **VISION** — 博打から経営へ
12. **CTA** — タイトルはいらない。結果で農業を変える。

## 再ビルド手順

```bash
cd documents/06_ピッチ_Pitch/nontitle
python3 build_frames.py   # index.html → frames/*.png
bash    build_video.sh    # frames → output/APE_nontitle_pitch.mp4
```

依存：Chromium（`/opt/pw-browsers/chromium-1194/...`）と ffmpeg（`/usr/bin/ffmpeg`）。

## 編集の指針

- 文言・色・フォントは `index.html` 内のインライン CSS のみで完結。
- スライドを増減した場合は `build_video.sh` の `DURATIONS` 配列を同じ長さに揃える。
- スライドあたりの尺は、文字数が多い章ほど長めに（目安：薄い章8秒／濃い章18秒）。
