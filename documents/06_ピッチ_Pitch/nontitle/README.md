# APE × ノンタイトル ピッチ資料

起業家リアリティショー「ノンタイトル」エントリー／ピッチ用のスライドと動画を格納しています。

## 成果物

| ファイル | 内容 |
|---|---|
| `index.html` | 12枚のHTMLスライド（1920×1080）。ブラウザでそのまま閲覧可。 |
| `output/APE_nontitle_pitch_voiced.mp4` | **ナレーション付きプレゼン動画**（h264+AAC / 1920×1080 / 30fps / **約1分58秒 / 4.0MB**）。 |
| `output/APE_nontitle_pitch.mp4` | 無音版（h264 / 1920×1080 / 30fps / 約2分56秒, クロスフェード付き）。 |
| `frames/frame_NN.png` | 各スライドのPNG静止画。サムネ・SNS切り出し用。 |
| `audio/audio_NN.mp3` | スライド毎の日本語ナレーション音声（pyopenjtalk 合成）。 |
| `narration.json` | 各スライドの読み原稿（編集してから再合成可能）。 |
| `audio_durations.json` | 合成後の各音声の実尺（秒）。 |
| `build_frames.py` | `index.html` を1枚ずつ Chromium で PNG 化するスクリプト。 |
| `build_audio.py` | `narration.json` を pyopenjtalk で MP3 化するスクリプト。 |
| `build_video.sh` | PNG をクロスフェードで連結し無音 mp4 を作る（旧版）。 |
| `build_video_voiced.sh` | PNG＋ナレーション音声を結合し、最終プレゼン動画を作る。 |
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

# 1. スライドPNG
python3 build_frames.py          # index.html → frames/*.png

# 2. ナレーション音声（オフラインTTS, pyopenjtalk）
python3 build_audio.py           # narration.json → audio/*.mp3

# 3a. ナレーション付きプレゼン動画（メインの成果物）
bash    build_video_voiced.sh    # → output/APE_nontitle_pitch_voiced.mp4

# 3b. 無音クロスフェード版（旧 / SNS差し込み用）
bash    build_video.sh           # → output/APE_nontitle_pitch.mp4
```

依存：Chromium（`/opt/pw-browsers/chromium-1194/...`）、ffmpeg（`/usr/bin/ffmpeg`）、
pyopenjtalk + open_jtalk_dic_utf_8-1.11（pip経由でインストール、辞書は GitHub r9y9/open_jtalk リリースから取得）。

## 編集の指針

- スライド文言・色・フォントは `index.html` 内のインライン CSS のみで完結。
- ナレーション原稿は `narration.json` を編集 → `python3 build_audio.py` で差分のみ再合成。
- スライドを増減した場合は `build_video.sh` の `DURATIONS` 配列も同じ長さに揃える
  （`build_video_voiced.sh` は音声尺を自動取得するので調整不要）。
