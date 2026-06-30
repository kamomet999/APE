#!/usr/bin/env python3
"""pyopenjtalk で narration.json の台本をスライド毎の WAV/MP3 に合成する。

オフライン日本語TTS（HTS engine + open_jtalk）。Edge-TTS が使えない環境向け。
"""
import json
import subprocess
import wave
from pathlib import Path

import numpy as np
import pyopenjtalk

ROOT = Path(__file__).parent.resolve()
AUDIO_DIR = ROOT / "audio"
AUDIO_DIR.mkdir(exist_ok=True)
FFMPEG = "/usr/bin/ffmpeg"


def synth_to_wav(text: str, out_wav: Path, speed: float, half_tone: float) -> float:
    """text を WAV に書き出し、秒数を返す。"""
    x, sr = pyopenjtalk.tts(text, speed=speed, half_tone=half_tone)
    peak = max(1.0, float(np.max(np.abs(x))))
    pcm = (x / peak * 32767.0 * 0.92).astype(np.int16)
    with wave.open(str(out_wav), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())
    return len(x) / sr


def wav_to_mp3(wav: Path, mp3: Path) -> None:
    subprocess.run(
        [FFMPEG, "-y", "-loglevel", "error", "-i", str(wav),
         "-c:a", "libmp3lame", "-b:a", "192k", str(mp3)],
        check=True,
    )


def main() -> None:
    data = json.loads((ROOT / "narration.json").read_text(encoding="utf-8"))
    speed = float(data.get("speed", 1.2))
    half_tone = float(data.get("half_tone", -1.0))  # 少し低音で落ち着いた声に
    durations = {}
    for entry in data["scripts"]:
        n = int(entry["slide"])
        wav = AUDIO_DIR / f"audio_{n:02d}.wav"
        mp3 = AUDIO_DIR / f"audio_{n:02d}.mp3"
        dur = synth_to_wav(entry["text"], wav, speed=speed, half_tone=half_tone)
        wav_to_mp3(wav, mp3)
        durations[n] = round(dur, 3)
        print(f"[{n:02d}] {dur:6.2f}s  {len(entry['text']):3d}chars  -> {mp3.name}")
    (ROOT / "audio_durations.json").write_text(
        json.dumps(durations, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    total = sum(durations.values())
    print(f"-- total {total:.2f}s ({total/60:.2f} min)")


if __name__ == "__main__":
    main()
