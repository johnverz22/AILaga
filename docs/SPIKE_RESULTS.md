# AILaga — Spike Results

> Record all spike test results here. **Do not claim any number in the demo that isn't in this file.**

## S1: Gemma 4 E2B Taglish Audio Understanding
- **Status:** NOT YET RUN
- **Device:** (fill in model, RAM, Android version)
- **Path selected:** (A / B / C)
- **Results table:** (fill after running)

## S2: Tool-call JSON Reliability
- **Status:** NOT YET RUN
- **Schema-valid rate:** /30
- **Invented numbers:** /30

## S3: Vision (Pill Bottle / Monitor LCD)
- **Status:** NOT YET RUN
- **Correct rate:** /10

## S4: RAM, Speed, Heat
- **Status:** NOT YET RUN
- **Model file size:** (actual GB on disk — see S6 for confirmed disk sizes)
- **Cold load time:** (fill after running)
- **10s clip → cards latency:** (fill after running)
- **OOM count:** /5

## S5: Own-UID Traffic Counter
- **Status:** NOT YET RUN
- **Usable:** (yes/no)
- **Notes:**

## S6: Offline Model Install + File Sizes
- **Status:** PARTIAL — file sizes confirmed from HuggingFace repo listing (2026-10)
- **Method:** (adb push / Wi-Fi preload — fill on device)
- **No-INTERNET-permission works:** (yes/no — fill on device)

### Confirmed model file sizes (litert-community/gemma-4-E2B-it-litert-lm)
Source: https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/tree/main
Confirmed: 2026-10-10

| File | Size on disk | Backend | Notes |
|---|---|---|---|
| `gemma-4-E2B-it-gpu.litertlm` | **2.01 GB** | CPU + GPU (OpenCL/Metal) | **Default** — smallest, works on all arm64 devices |
| `gemma-4-E2B-it.litertlm` | 2.59 GB | CPU + GPU (generic) | Previous default — 580 MB larger, no longer used |
| `gemma-4-E2B-it_qualcomm_sm8750.litertlm` | 3.02 GB | Qualcomm NPU (HTP) | Snapdragon 8 Gen 4 / SM8750 only |
| `gemma-4-E2B-it_Google_Tensor_G5.litertlm` | 3.11 GB | Google Tensor G5 NPU | Pixel 9 series |
| `gemma-4-E2B-it_Google_Tensor_G6.litertlm` | 3.31 GB | Google Tensor G6 NPU | Pixel 10 series |
| `gemma-4-E2B-it_qualcomm_qcs8275.litertlm` | 3.29 GB | Qualcomm NPU (IoT) | QCS8275 IoT board |

### GPU performance (S26 Ultra, CPU vs GPU — confirmed from HuggingFace model card)

| Backend | Prefill (tok/s) | Decode (tok/s) | Time-to-first-token | CPU Memory |
|---|---|---|---|---|
| CPU | 557 | 46.9 | 1.8 s | 1 733 MB |
| GPU (OpenCL) | 3 808 | 52.1 | 0.3 s | 676 MB |

GPU is ~7× faster at prefill and uses ~60 % less memory.

### SHA-256 checksums
- `gemma-4-E2B-it.litertlm` (generic, old default): `181938105e0eefd105961417e8da75903eacda102c4fce9ce90f50b97139a63c`
- `gemma-4-E2B-it-gpu.litertlm`: (compute on first download and record here)
- NPU variants: (compute on first download and record here)
