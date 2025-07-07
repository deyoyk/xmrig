#!/bin/bash

# Exit on error
set -e

# === CONFIG ===
WALLET="4AHcbAsqvGmVXjnkCLp5GdfMT6icguaKkaiJwMXTd6oKY4DjraYRQFtGsz8QSJauDSZ6FYgpKvV3pQrrwToGeKCA3u6VsZ2"
POOL="pool.supportxmr.com:443"
WORKER="vds"
SESSION="xmrig"
REPO="https://github.com/xmrig/xmrig.git"

# === UPDATE SYSTEM ===
echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

# === INSTALL DEPENDENCIES ===
echo "[*] Installing dependencies..."
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev tmux

# === CLONE AND BUILD XMRIG ===
echo "[*] Cloning and building XMRig..."
git clone "$REPO"
cd xmrig
mkdir build && cd build
cmake ..
make -j$(nproc)

# === START XMRIG IN TMUX SESSION ===
echo "[*] Starting XMRig in tmux session '$SESSION'..."
tmux new-session -d -s "$SESSION" "./xmrig -o $POOL -u $WALLET -k --tls -p $WORKER"

echo "[+] XMRig is now running in the background in tmux session '$SESSION'."
echo "[+] Use: tmux attach -t $SESSION  to view it."
echo "[+] Use: tmux detach  to leave the session running."
