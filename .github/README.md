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
3. Right‑click tray icon → `Audio Devices` to pick your microphone.  
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

### Accuracy vs Latency (Streaming vs Chunk Mode)
If you are unhappy with transcription accuracy in the default streaming mode, try switching to chunk mode:
1. Tray icon → Settings → Transcription tab.
2. Change Mode from `stream` to `chunk`.
3. (Optionally) pick a larger model (e.g. `small` or `medium`) if CPU/GPU resources allow.

Chunk mode processes slightly larger buffered segments, giving the model more surrounding context per inference; this usually improves punctuation and reduces short hallucinated fragments at the cost of a bit more latency. Streaming mode prioritizes immediacy and may emit shorter, occasionally less stable phrases. Pick the mode that best fits your scenario (presentations: streaming; post‑meeting notes / higher fidelity: chunk).

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

## Capturing System / Application Audio (Stereo Mix – Built‑in Loopback)
If you want SubOverlay to transcribe what you (or a video / call) hear through your speakers instead of (or in addition to) your microphone, you can often use Windows' built‑in "Stereo Mix" (sometimes called "What U Hear"). This exposes your current output stream as a recording device.

### 1. Enable Stereo Mix (Windows 10/11)
On many systems (especially with Realtek audio) Stereo Mix is present but disabled by default.
1. Right‑click the speaker icon in the taskbar → choose "Sound settings".
2. Scroll (Win11) and click "More sound settings" (opens classic Sound dialog) OR (Win10) click "Sound Control Panel" on the right.
3. Go to the Recording tab.
4. Right‑click in the empty area → check "Show Disabled Devices" and "Show Disconnected Devices".
5. If you see "Stereo Mix" (or "What U Hear" / "Loopback" depending on manufacturer), right‑click → Enable.
6. (Optional) Right‑click → "Set as Default Device" ONLY if you want all apps to treat it as default input; not required for SubOverlay (you can just select it inside the app).

If Stereo Mix does not appear:
* Ensure you have the latest Realtek (or vendor) audio driver (OEM support site often more complete than Windows Update).
* Laptops sometimes hide the option if the internal codec doesn’t expose it; in that case see Alternatives below.

### 2. Select Stereo Mix in SubOverlay
1. Right‑click the SubOverlay tray icon → Audio Devices.
2. Pick the input device containing "Stereo Mix" (exact name varies).
3. Click "Select Device".
4. Right‑click tray icon → Start Transcription. Subtitles now reflect any audio playing through your speakers/headphones.

### 3. Include Your Microphone Too (Simple Options)
Stereo Mix usually captures only system/output audio. If you also want your live mic words transcribed at the same time, you have to mix them before they reach SubOverlay (it can listen to only one device at once):
Option A (Windows Listen):
1. Sound Control Panel → Recording tab → select your Microphone → Properties.
2. Listen tab → check "Listen to this device" → choose the same playback device you normally use → Apply.
3. Now your mic is played out the speakers and becomes part of the Stereo Mix signal.
4. Select Stereo Mix as input in SubOverlay (as above). Both mic + system audio are transcribed (note: may include remote participants if on a call). 

Option B (External Mix): Use a hardware mixer or third‑party software (VoiceMeeter, etc.) to create a combined output, then select that combined loopback (or still Stereo Mix if it now represents the sum) in SubOverlay.

### 4. Reduce Echo / Feedback
If you hear your own voice doubled after enabling "Listen":
* Lower mic playback level in the Levels tab of the microphone's Properties.
* Use headphones: Stereo Mix will still capture what would go to speakers, but the mic won’t re‑record the speaker output.
* Disable any microphone “enhancements” that add processing delay.

### 5. Adjust Levels
If transcription misses words because output is quiet:
1. Sound Control Panel → Recording → Stereo Mix → Properties.
2. Levels tab → raise the slider (avoid clipping; stay below 100 if it distorts).
3. Optionally reduce other noisy inputs (disable unused mics).

### 6. Temporarily Pause Without Changing Devices
Instead of deselecting Stereo Mix, just Stop Transcription from the tray. You can resume without losing selection.

### 7. Alternatives if Stereo Mix Is Unavailable
If your device truly lacks Stereo Mix:
* WASAPI Loopback (future enhancement): SubOverlay could add native loopback capture; for now use a lightweight virtual device (only if needed).
* USB Audio Split: A cheap USB sound card can serve as a dedicated playback whose loopback is exposed.
* Third‑party tools (last resort): VB-Audio Cable or VoiceMeeter Banana.

### Troubleshooting (Stereo Mix)
| Problem | Try |
|---------|-----|
| Stereo Mix not listed | Show Disabled Devices; install/update OEM Realtek/Conexant driver; reboot |
| Stereo Mix stays silent | Play audio through speakers (not Bluetooth that bypasses codec); check Levels tab |
| Echo / feedback | Use headphones or disable mic "Listen"; lower mic playback level |
| Mic missing from transcription | You’re only capturing output; enable mic "Listen" or mix externally |
| Audio distorted / clipped | Lower application/system volume or reduce Stereo Mix Level |
| Privacy concern | Remember Stereo Mix captures ALL system playback; stop transcription when not needed |

### Reverting
1. If you set Stereo Mix as default device: Recording tab → right‑click your microphone → Set as Default.
2. If you enabled mic "Listen": uncheck it to avoid hearing yourself.
3. (Optional) Disable Stereo Mix again if you prefer a shorter device list.

---

## Updating
Replace the old `SubOverlay.exe` with the new one. Your `config/settings.yaml` and downloaded models remain intact.

## Uninstalling
Delete the application folder. Optional: remove downloaded models (look for the model directory you selected in settings) and `config/settings.yaml`.

## License
Released under the MIT License. See `LICENSE` for details.

## Acknowledgements
Built with faster‑whisper (ctranslate2 backend) for efficient local transcription.

Enjoy faster, clearer captions with SubOverlay.
