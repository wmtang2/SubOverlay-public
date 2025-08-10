git clone https://github.com/wmtang2/SubOverlay.git
# SubOverlay

Real‑time speech-to-text subtitles for Windows. SubOverlay listens to your chosen audio input and places a clean, customizable subtitle overlay on your screen while you speak.

## What You Get
* Live transcription (streaming + chunk modes)
* On‑screen overlay: movable, resizable, configurable font & transparency
* Language auto‑detect or fixed language + optional translate-to-English
* Voice Activity Detection (VAD) tuning (advanced users)
* System tray control (start / stop / settings / audio devices / exit)
* Optional NVIDIA GPU acceleration (CUDA 12.x) for faster processing
* Works offline after first model download

## Quick Start (Packaged EXE)
1. Double‑click `SubOverlay.exe` (or use the provided `run_SubOverlay.bat`).  
2. Wait for the tray icon to appear (may take a few seconds first run).  
3. Right‑click tray icon → `Audio Devices` to pick "Stereo Mixer" (enable it in Sound Settings if it is disabled).  
4. Right‑click tray icon → `Start Transcription`.  
5. Speak. Subtitles appear in the overlay window.  
6. Drag the overlay or adjust its position via `Settings → Overlay`.  

To stop: tray icon → `Stop Transcription`.  
To exit completely: tray icon → `Exit` (the icon and process both close).

## First Run Notes
* The first model you choose downloads automatically; this can take a minute depending on size and connection.  
* You can change model later in `Settings → Transcription`. Smaller models start faster; larger ones improve accuracy.  
* If you enable GPU (CUDA tab) but don’t have CUDA 12.x properly installed, the app will fall back to CPU.

## Settings Overview
Open via tray → `Settings`. Tabs:
* Audio: Sample rate, chunk size.  
* Transcription: Model, language (or auto), mode (stream / chunk), optional auto‑start.  
* Overlay: Font family, size, transparency, on‑screen position & offsets.  
* CUDA (Optional): Point to CUDA Toolkit + cuDNN (only if non‑standard install).  
* Advanced: VAD thresholds & streaming text limits (cap lines to keep overlay tidy).  
* About: Version info & project credits.

## Choosing a Model
Typical guidance:
* Tiny / Base: Fast on most CPUs, good for live notes.  
* Small: Better accuracy, moderate speed.  
* Medium / Large: Highest accuracy; best with GPU.  

If unsure, start with `base` then adjust upward if accuracy is insufficient.

## Overlay Tips
* If subtitles disappear off‑screen, reset offsets in Overlay settings.  
* Increase font size for readability when sharing a screen.  
* Lower transparency (higher opacity) in bright backgrounds.  

## Language & Translation
* Leave language on `auto` for mixed or unknown speech.  
* Set a specific language for faster, slightly more accurate recognition.  
* Switch task to `translate` to always output English.  

## Voice Activity (Advanced)
Adjust only if you see either: (a) too many false starts, lower threshold; (b) missed words, also lower threshold slightly; or (c) merging sentences, raise `Min Silence` to separate less, lower to separate more.

## Troubleshooting
| Issue | Try |
|-------|-----|
| No text appears | Ensure correct microphone selected (Audio Devices) and transcription started |
| Model download slow | Pick a smaller model first, verify network connectivity |
| High CPU usage | Use a smaller model or enable GPU (CUDA 12.x) |
| Overlay hidden | Check it’s not behind other always‑on‑top windows; adjust position settings |
| Inaccurate transcription | Specify source language or switch to a larger model |
| App won’t exit | Use tray → Exit (updated to fully terminate) |

If settings become unstable, delete `config/settings.yaml` (a fresh one regenerates next run).

## Privacy
Audio is processed locally. After the initial model download, no audio or text is sent to remote services.

## Optional GPU Acceleration (Summary)
You only need this if you want faster processing:
1. Install NVIDIA driver + CUDA Toolkit 12.x.  
2. (Optional) Install matching cuDNN.  
3. Open `Settings → CUDA` and point to the install directory if auto‑detection fails.  
4. Click `Check CUDA Status`. If devices are listed, GPU is active.  

If unsure, you can ignore this entirely—the app works on CPU.

## Capturing Video / System Audio via a Virtual Audio Cable
Instead of Windows Sound Mixer, you can also route sound through a virtual audio cable and select the cable as the input device.

### Overview
1. Install a virtual cable (e.g. VB‑Audio Virtual Cable).
2. Set the video player's (or system) output to the virtual cable.
3. (Optional) Play the cable back to your real speakers/headphones using a replicator so you can still hear it.
4. In SubOverlay select the virtual cable as the input device.
5. Start transcription.

### Step 1: Install Virtual Cable
Download (free) VB‑Audio Virtual Cable: https://vb-audio.com/Cable/  
Run the installer as Administrator, finish, then reboot if prompted.

After install you get (names may vary):
* Playback device: `CABLE Input (VB-Audio Virtual Cable)`
* Recording device: `CABLE Output (VB-Audio Virtual Cable)`

### Step 2: Route Video / App Audio Into the Cable
Option A (Per‑Application): In the app (e.g. VLC / Zoom / media player) choose audio output = `CABLE Input`.

Option B (Whole System): Windows Settings → System → Sound → Choose where to play sound → set default output to `CABLE Input` (remember to change back later).

Now whatever plays to `CABLE Input` appears as a recording stream on `CABLE Output` (SubOverlay can listen to that).

### Step 3: (Optional) Hear the Audio While Routing
You need to monitor the cable so you can still listen:
1. Open Windows Sound Control Panel → Recording tab.
2. Select `CABLE Output` → Properties → Listen tab.
3. Check `Listen to this device`, pick your real speakers/headset, Apply.
   *This is the simplest no‑code option.*

OR use the Python replicator script below if you prefer explicit control / low latency tweak.

### Step 4: Select Cable in SubOverlay
Tray icon → `Audio Devices` → pick the device whose name includes `CABLE Output` → Select Device.

### Step 5: Start Transcription
Tray icon → `Start Transcription`. Subtitles now reflect the video/system audio.

### Optional: Python Sound Replicator (Loopback)
If you want a lightweight passthrough with adjustable latency instead of Windows "Listen" feature, create a file `replicator.py` (outside the frozen EXE, or run in your Python env):

```python
import sounddevice as sd

SOURCE_NAME_FRAGMENT = "CABLE Output"   # recording side (what SubOverlay also listens to)
OUTPUT_NAME_FRAGMENT = "Speakers"       # change to a unique part of your real output device name
BLOCK_SIZE = 1024                        # smaller = lower latency, higher CPU

def pick_device(kind_fragment, kind="input"):
	for idx, dev in enumerate(sd.query_devices()):
		if kind == "input" and dev["max_input_channels"] > 0 and kind_fragment.lower() in dev["name"].lower():
			return idx
		if kind == "output" and dev["max_output_channels"] > 0 and kind_fragment.lower() in dev["name"].lower():
			return idx
	raise RuntimeError(f"Device fragment '{kind_fragment}' not found")

in_dev = pick_device(SOURCE_NAME_FRAGMENT, "input")
out_dev = pick_device(OUTPUT_NAME_FRAGMENT, "output")

print(f"Using input #{in_dev}, output #{out_dev}")

def audio_cb(indata, frames, time, status):  # noqa: D401, ANN001
	if status:
		print("Status:", status)
	sd.play(indata.copy(), samplerate=STREAM.sample_rate, device=out_dev, blocking=False)

STREAM = sd.InputStream(device=in_dev, callback=audio_cb, blocksize=BLOCK_SIZE)
with STREAM:
	print("Replicating... Ctrl+C to stop")
	while True:
		sd.sleep(1000)
```

Run with:
```powershell
python replicator.py
```
Tune latency by lowering `BLOCK_SIZE` (e.g. 512 or 256) if your system handles it without glitches.

### Tips / Troubleshooting
| Problem | Fix |
|---------|-----|
| Echo / Feedback | Ensure your microphone isn’t also capturing speaker output; mute mic if only transcribing video |
| No audio level in SubOverlay | Verify the app really outputs to `CABLE Input`; try per‑app volume mixer (Win+X → Volume Mixer) |
| Distorted sound | Increase BLOCK_SIZE or disable other enhancement software |
| Delay too high | Use smaller BLOCK_SIZE or Windows "Listen to this device" (often has acceptable latency) |
| Need both mic + video | Use a mixer tool (e.g. VoiceMeeter) and select its combined virtual output in SubOverlay |

To revert: set your default playback device back to speakers/headphones and (if used) uncheck "Listen to this device".

---

## Updating
Replace the old `SubOverlay.exe` with the new one. Your `config/settings.yaml` and downloaded models remain intact.

## Uninstalling
Delete the application folder. Optional: remove downloaded models (look for the model directory you selected in settings) and `config/settings.yaml`.

## License
See `LICENSE.txt` for details.

## Acknowledgements
Built with faster‑whisper (ctranslate2 backend) for efficient local transcription.

Enjoy faster, clearer captions with SubOverlay.


