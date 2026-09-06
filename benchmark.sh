#!/bin/bash

MODEL="$HOME/dev/ai/models/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
SERVER="$HOME/dev/ai/llama.cpp/build/bin/llama-server"

PROMPT="Implement a Python function parse_csv that parses a simple CSV string into a list of dictionari>

# Defaults
THREADS="${1:-6}"
CONTEXT="${2:-4096}"
CPU_MASK="${3:-0-7}"
PORT=8080

LOGFILE="/tmp/llama-bench-$(date +%s).log"

echo "========================================"
echo "Benchmark: -t $THREADS | -c $CONTEXT | taskset -c $CPU_MASK"
echo "========================================"

# Start server in background, capture all output
taskset -c "$CPU_MASK" "$SERVER" \
  -m "$MODEL" \
  -c "$CONTEXT" \
  --host 127.0.0.1 \
  --port "$PORT" \
  -t "$THREADS" \
  --n-predict 512 > "$LOGFILE" 2>&1 &

SERVER_PID=$!

# Wait for server to be ready (up to 30 seconds)
READY=0
for i in $(seq 1 30); do
  if curl -s "http://127.0.0.1:$PORT/health" > /dev/null 2>&1; then
    READY=1
    break
  fi
  sleep 1
done

if [ "$READY" -eq 0 ]; then
  echo "Server failed to start. Log:"
  cat "$LOGFILE"
  kill "$SERVER_PID" 2>/dev/null
  
  exit 1
fi

# Send the benchmark request
echo "Sending prompt..."
curl -s "http://127.0.0.1:$PORT/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}],\"max_tokens\":400}" > /dev/null

# Give the server a moment to finish logging
sleep 2

# Stop server
kill "$SERVER_PID" 2>/dev/null
wait "$SERVER_PID" 2>/dev/null

# Extract timing
echo ""
echo "=== Timing Results for -t $THREADS, -c $CONTEXT ==="
grep -E "prompt eval time|eval time|prompt eval rate|eval rate|tokens per second" "$LOGFILE" || echo "N>

echo ""
echo "=== Full relevant log excerpt ==="
grep -E "prompt eval|eval time|slot.*released|error|tokens per second" "$LOGFILE"

rm -f "$LOGFILE"
echo ""
echo "========================================"
