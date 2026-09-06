#!/bin/bash
MODEL="$HOME/dev/ai/models/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
SERVER="$HOME/dev/ai/llama.cpp/build/bin/llama-server"

taskset -c 0-7 "$SERVER" \
  -m "$MODEL" \
  -c 8192 \
  --host 127.0.0.1 \
  --port 7070 \
  -t 6 \
  --n-predict -1 \
  --api-key "api-key"
