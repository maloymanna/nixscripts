#!/bin/bash

MODEL="$HOME/dev/ai/models/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
SERVER="$HOME/dev/ai/llama.cpp/build/bin/llama-server"

PROMPT="Implement a Python function parse_csv that parses a simple CSV string into a list of dictionaries. Handle quoted fields, escaped quotes, and newlines within fields. Do not use the csv module. Include docstrings, type hints, and a few unit tests using assert."

# Defaults
THREADS="${1:-6}"
CONTEXT="${2:-4096}"
CPU_MASK="${3:-0-7}"
PORT=8080
LOGFILE="/tmp/llama-bench-$(date +%s).log"

echo "========================================"
echo "Config: -t $THREADS | -c $CONTEXT | taskset -c $CPU_MASK"
echo "Log: $LOGFILE"
echo "========================================"

# Start server in background, capture all output
taskset -c "$CPU_MASK" "$SERVER" \
  -m "$MODEL" \
  -c "$CONTEXT" \
  --host 127.0.0.1 \
  --port "$PORT" \
  -t "$THREADS" \
  --n-predict 300 > "$LOGFILE" 2>&1 &

SERVER_PID=$!

# Wait for server to be ready and start listening
echo "Waiting for server to become ready..."
READY=0
for i in $(seq 1 60); do
  if grep -qE "listening on http://|model loaded" "$LOGFILE" 2>/dev/null; then
    READY=1
    echo "Server ready after $i seconds."
    break
  fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "ERROR: Server process died during startup."
    cat "$LOGFILE"
    exit 1
  fi
  sleep 1
done

if [ "$READY" -eq 0 ]; then
  echo "Server failed to become ready within 60 seconds."
  cat "$LOGFILE"
  kill "$SERVER_PID" 2>/dev/null
  exit 1
fi

# Give it a moment to fully settle
sleep 1

# Send request
echo "Sending benchmark request..."
HTTP_CODE=$(curl -s -o /tmp/llama-bench-response.json -w "%{http_code}" \
  "http://127.0.0.1:$PORT/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}],\"max_tokens\":300}")

echo "HTTP response code: $HTTP_CODE"
if [ "$HTTP_CODE" != "200" ]; then
  echo "ERROR: Request failed. Response:"
  cat /tmp/llama-bench-response.json 2>/dev/null || true
  kill -INT "$SERVER_PID" 2>/dev/null
  wait "$SERVER_PID" 2>/dev/null
  exit 1
fi

# Wait for generation to finish and timing lines to appear
echo "Waiting for generation to complete..."
for i in $(seq 1 30); do
  if grep -qE "eval time|slot.*released|print_timings|timings:" "$LOGFILE" 2>/dev/null; then
    echo "Generation complete."
    break
  fi
  sleep 1
done

# Graceful shutdown
echo "Shutting down server..."
kill -INT "$SERVER_PID" 2>/dev/null
wait "$SERVER_PID" 2>/dev/null

echo ""
echo "=== Timing Results for -t $THREADS, -c $CONTEXT ==="
grep -iE "PREFILL prompt eval time|eval time|prompt eval rate|eval rate|tokens per second|timings:" "$LOGFILE" || echo "No timing lines matched."

echo ""
echo "=== Full relevant log excerpt ==="
grep -iE "DECODE eval time|eval rate|timings:|slot.*released|error|warning:" "$LOGFILE"

echo ""
echo "Log preserved at: $LOGFILE"
rm -f /tmp/llama-bench-response.json
echo "========================================"
