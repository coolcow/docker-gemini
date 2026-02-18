# Docker Gemini CLI

A Docker image for running the [Google Gemini CLI](https://github.com/google/gemini-cli) in an isolated and reproducible environment, with native-like terminal usage as default and an optional browser mode via `ttyd` (for example at `http://localhost:7681`).

## Versions Used

Current image/runtime versions in this repository:

- `ENTRYPOINTS_VERSION=2.1.0` (base helper image: `ghcr.io/coolcow/entrypoints`)
- `NODE_VERSION=22` (base image: `node:22`)
- `DOCKER_CLI_VERSION=27.5.1` (Docker CLI binary inside container)
- `TTYD_VERSION=1.7.7` (`ttyd` web terminal binary)
- Gemini CLI: started via `npx -y @google/gemini-cli` (latest available package at runtime, not pinned in this image)

## Set Up Native-like Usage (Recommended)

Add this function to your shell config (`~/.bashrc` or `~/.zshrc`) so you can use `gemini` like a local command:

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
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e GEMINI_UID=$(id -u) \
        -e GEMINI_GID=$(id -g) \
        -e GEMINI_API_KEY="YOUR_API_KEY" \
        -e NODE_OPTIONS=--no-deprecation \
        ghcr.io/coolcow/gemini:latest "$@"
}
```

Reload your shell:

```bash
source ~/.bashrc
```

### Quick Usage Examples

```bash
gemini
gemini --help
gemini -p "summarize this repository"
```

## Use as a `ttyd` Service with Docker Compose

The included `compose.yml` starts the `ttyd` service.

```bash
docker compose up -d
```

Then open in your browser: `http://localhost:7681`

Key parts of `compose.yml`:
- `RUN_MODE=ttyd` starts web terminal mode.
- `volumes`:
  - `./workspace:/workspace` is your working directory.
  - `home:/home/gemini` persists settings and caches.
- `environment` includes `GEMINI_API_KEY`, `GEMINI_UID`, `GEMINI_GID`, `NODE_OPTIONS`, etc.
- `ports: 7681:7681` publishes web access.

## Usage with Plain Docker Commands

### 1) Optional: Build Locally

```bash
docker build -t ghcr.io/coolcow/gemini:local-build ./build
```

### 2) Create a Persistent Home Volume

```bash
docker volume create gemini-home
```

### 3) Start in `cli` Mode

```bash
docker run -it --rm \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  -v gemini-home:/home/gemini \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GEMINI_UID=$(id -u) \
  -e GEMINI_GID=$(id -g) \
  -e GEMINI_API_KEY="$GEMINI_API_KEY" \
  -e NODE_OPTIONS=--no-deprecation \
  ghcr.io/coolcow/gemini:local-build
```

### 4) Start in `ttyd` Mode via `docker run`

```bash
docker run -it --rm \
  -p 7681:7681 \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  -v gemini-home:/home/gemini \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e RUN_MODE=ttyd \
  -e GEMINI_UID=$(id -u) \
  -e GEMINI_GID=$(id -g) \
  -e GEMINI_API_KEY="$GEMINI_API_KEY" \
  -e NODE_OPTIONS=--no-deprecation \
  ghcr.io/coolcow/gemini:local-build
```

Then open in your browser: `http://localhost:7681`

### Explanation of Parameters, Variables, and Volumes

- `-v "$(pwd)":"$(pwd)"`: bind-mounts the current project so Gemini can work directly on your files.
- `-w "$(pwd)"`: sets the container working directory to your current project.
- `-v gemini-home:/home/gemini`: persistent home directory (config, caches, and potentially credentials).
- `-v /var/run/docker.sock:/var/run/docker.sock`: allows using Docker commands inside the container (talks to the host's Docker daemon). On startup, the runtime user is automatically added to the group that matches the socket GID.
- `-e GEMINI_API_KEY=...`: Gemini API key (required).
- `-e GEMINI_UID` / `-e GEMINI_GID`: ensures proper file ownership when writing to mounted project files.
- `-e RUN_MODE=ttyd`: optional, starts browser-based `ttyd` mode (default without `RUN_MODE` is CLI).
- `-e NODE_OPTIONS=--no-deprecation`: optional, suppresses non-critical Node warnings.
- `-e DOCKER_SOCK_PATH` / `-e DOCKER_GROUP_NAME`: optional overrides for socket path and preferred docker group name.
- `-p 7681:7681`: for `ttyd` only, maps the web port to the host.

Note: The image includes a recent Docker CLI binary, so Docker API version negotiation works with modern host daemons when `/var/run/docker.sock` is mounted.

## Local Image Smoke Test (for Developers)

The smoke tests verify, among other things, required binaries (`ttyd`, `gosu`), entrypoint syntax, and expected startup options.

1. Build the app image locally:

   ```bash
   docker build -t ghcr.io/coolcow/gemini:local-test-build -f build/Dockerfile build
   ```

2. Run smoke tests via the test Dockerfile:

   ```bash
   docker build --build-arg APP_IMAGE=ghcr.io/coolcow/gemini:local-test-build -f build/Dockerfile.test build
   ```

If the second build completes successfully, the smoke test passes.

## Acknowledgments

- Heavily inspired by: https://github.com/tgagor/docker-gemini-cli
- This project was created with the help of Gemini CLI and reviewed by a human.
