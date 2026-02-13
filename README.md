 cat README.md
# Docker Gemini CLI

This repository provides a Docker image to run the [Google Gemini CLI](https://github.com/google/gemini-cli) in an isolated environment. It also includes the functionality to expose the CLI to the web using `ttyd`.

## Build the Image

You can build the Docker image locally using the following command:

```bash
docker build -t ghcr.io/coolcow/gemini:latest ./build
```

## How to Run

This section describes how to run the container using either `docker run` for direct CLI/ttyd access, or `docker-compose`.

### Using `docker run`

You can run the container directly for different purposes.

#### 1. Command Line Interface (CLI)

This is the recommended way to use the Gemini CLI for development in your current directory.

**First-time setup:** Create a named volume to persist settings and the npx cache.

```bash
docker volume create gemini-home
```

**Run command:** Execute the following to start the Gemini CLI. It mounts your current directory and uses your local user's permissions to avoid file ownership issues.

```bash
docker run -it --rm \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  -v gemini-home:/home/gemini \
  -e GEMINI_UID=$(id -u) \
  -e GEMINI_GID=$(id -g) \
  -e NODE_OPTIONS=--no-deprecation \
  -e GEMINI_API_KEY="YOUR_API_KEY" \
  ghcr.io/coolcow/gemini:latest cli
```

#### 2. ttyd (Web Interface)

This command exposes the Gemini CLI to a web interface on `http://localhost:7681`.

```bash
docker run -it --rm \
  -p 7681:7681 \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  -v gemini-home:/home/gemini \
  -e GEMINI_UID=$(id -u) \
  -e GEMINI_GID=$(id -g) \
  -e NODE_OPTIONS=--no-deprecation \
  -e GEMINI_API_KEY="YOUR_API_KEY" \
  -e WORKSPACE="$(pwd)" \
  ghcr.io/coolcow/gemini:latest ttyd
```

### Using `docker-compose`

The provided `compose.yml` is configured to run the `ttyd` service.

To use it, run:
```bash
docker-compose up -d
```

## Alias for easy access

To make using the Gemini CLI feel like a native command, you can define an alias in your shell's configuration file (e.g., `.bashrc`, `.zshrc`). This allows you to simply type `gemini` in your terminal to run the CLI within the Docker environment, with your current directory automatically mounted.

Add the following line to your shell's configuration file:

```bash
alias gemini="docker volume create gemini-home &> /dev/null && docker run -it --rm -v \"$(pwd)\":\"$(pwd)\" -w \"$(pwd)\" -v gemini-home:/home/gemini -e GEMINI_UID=$(id -u) -e GEMINI_GID=$(id -g) -e NODE_OPTIONS=--no-deprecation -e GEMINI_API_KEY=\"YOUR_API_KEY\" ghcr.io/coolcow/gemini:latest cli"
```

After adding the alias, restart your shell or source the configuration file (e.g., `source ~/.bashrc`) for the changes to take effect. Remember to replace `"YOUR_API_KEY"` with your actual Gemini API key.

## Configuration

-   **`GEMINI_API_KEY`**: Your Google Gemini API key.
-   **`NODE_OPTIONS=--no-deprecation`**: This optional variable is used to suppress Node.js deprecation warnings that may appear during startup. These warnings are generally harmless and can be ignored.
-   **Volumes**:
    -   `"$(pwd)":"$(pwd)"`: The current directory is mounted as the workspace. While the default working directory inside the container is `/workspace`, the provided `docker run` commands override this using the `-w "$(pwd)"` option. This ensures the Gemini CLI operates directly within your host project. If you wish to use a different working directory inside the container, you should adjust both the volume mount (`-v`) and the working directory (`-w`) accordingly.
    - `gemini-home:/home/gemini` (Optional): This named volume is used to persist the user's home directory. This is recommended for regular use to avoid reinstalling `npx` packages on every run and to save your Gemini CLI settings and history. For one-time use, you can omit this volume.
-   **Port**: `7681` is the default port for `ttyd`.

## Acknowledgments

This project was supported by the use of gemini-cli. All changes have been reviewed by me (a human) to ensure they are correct and make sense.
