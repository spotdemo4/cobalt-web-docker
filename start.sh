#!/usr/bin/env sh

PORT=${PORT:-8787}
LOG_LEVEL=${LOG_LEVEL:-info}

if [ ! -d ./web/build ]; then
    echo "building cobalt web..."
    pnpm run --filter=./web build
fi

static-web-server --port "${PORT}" --root ./web/build --log-level "${LOG_LEVEL}"
