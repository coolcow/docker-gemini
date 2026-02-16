# Docker Gemini CLI

This repository provides a Docker image to run the [Google Gemini CLI](https://github.com/google/gemini-cli) in an isolated environment.

It supports two modes:
- `cli`: Use Gemini directly in your terminal.
- `ttyd`: Expose Gemini in a browser on `http://localhost:7681`.

## Quick Start (CLI)

### 1) Build the image (optional)

If you want to build locally instead of pulling from GHCR:

```bash
docker build -t ghcr.io/coolcow/gemini:latest ./build
```

### 2) Create a persistent home volume

This stores Gemini settings and npm/npx cache between runs:

```bash
docker volume create gemini-home
```

### 3) Run Gemini in your current project

```bash
docker run -it --rm \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  -v gemini-home:/home/gemini \
  -e GEMINI_UID=$(id -u) \
  -e GEMINI_GID=$(id -g) \
  -e GEMINI_API_KEY="$GEMINI_API_KEY" \
  -e NODE_OPTIONS=--no-deprecation \
  ghcr.io/coolcow/gemini:latest cli
```

## Web Terminal (`ttyd`)

```bash
docker run -it --rm \
  -p 7681:7681 \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  -v gemini-home:/home/gemini \
  -e GEMINI_UID=$(id -u) \
  -e GEMINI_GID=$(id -g) \
  -e GEMINI_API_KEY="$GEMINI_API_KEY" \
  -e NODE_OPTIONS=--no-deprecation \
  ghcr.io/coolcow/gemini:latest ttyd
```

Then open `http://localhost:7681`.

## Using Docker Compose

The provided `compose.yml` starts `ttyd`.

```bash
docker compose up -d
```

## Optional: Shell Function for Native-like Usage

Add this to your shell config (`~/.bashrc` or `~/.zshrc`) so you can run `gemini` like a local command:

```bash
gemini() {
    docker volume create gemini-home &> /dev/null

    local tty_args=""
    if [ -t 0 ]; then
        tty_args="--tty"
    fi

    docker run -i ${tty_args} --rm \
        -v "$(pwd)":"$(pwd)" \
        -w "$(pwd)" \
        -v gemini-home:/home/gemini \
        -e GEMINI_UID=$(id -u) \
        -e GEMINI_GID=$(id -g) \
        -e GEMINI_API_KEY="YOUR_API_KEY" \
        -e NODE_OPTIONS=--no-deprecation \
        ghcr.io/coolcow/gemini:latest cli "$@"
}
```

Reload your shell afterward, for example:

```bash
source ~/.bashrc
```

## Configuration

- `GEMINI_API_KEY`: Your Google Gemini API key.
- `GEMINI_UID` / `GEMINI_GID`: UID/GID used inside the container (defaults to `1000`/`1000`).
- `NODE_OPTIONS=--no-deprecation`: Optional, suppresses harmless Node.js deprecation warnings.
- `TTYD_PORT`: Port for web terminal mode (default `7681`).

For normal usage, you only need `GEMINI_API_KEY` (and optionally UID/GID).

## Local Testing

Run the built-in smoke tests locally.

1. `docker build -t ghcr.io/coolcow/gemini:local-test-build -f build/Dockerfile build`
2. `docker build --build-arg APP_IMAGE=ghcr.io/coolcow/gemini:local-test-build -f build/Dockerfile.test build`

## Acknowledgments

- Heavily inspired by: https://github.com/tgagor/docker-gemini-cli.
- This project was created with the help of Gemini CLI and reviewed by a human.
