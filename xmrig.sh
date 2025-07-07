


set -e


WALLET="4AHcbAsqvGmVXjnkCLp5GdfMT6icguaKkaiJwMXTd6oKY4DjraYRQFtGsz8QSJauDSZ6FYgpKvV3pQrrwToGeKCA3u6VsZ2"
POOL="pool.supportxmr.com:443"
WORKER="vds"
SESSION="xmrig"
REPO="https://github.com/xmrig/xmrig.git"
LOG_FILE="xmrig.log"


if [[ "$EUID" -ne 0 ]]; then
  echo "[!] Please run this script as root (sudo ./xmrig.sh)"
  exit 1
fi


echo "[*] Updating system..."
apt update && apt upgrade -y


echo "[*] Installing dependencies..."
apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev tmux


echo "[*] Enabling MSR module..."
modprobe msr
echo "msr" | tee /etc/modules-load.d/msr.conf


echo "[*] Setting up hugepages..."
sysctl -w vm.nr_hugepages=128
echo 'vm.nr_hugepages=128' >> /etc/sysctl.conf


echo "[*] Cloning and building XMRig..."
git clone "$REPO"
cd xmrig
mkdir build && cd build
cmake ..
make -j$(nproc)


echo "[*] Starting XMRig in tmux session '$SESSION'..."
tmux new-session -d -s "$SESSION" "./xmrig -o $POOL -u $WALLET -k --tls -p $WORKER | tee $LOG_FILE"

echo
echo "[✔] XMRig is now running in tmux session '$SESSION'."
echo "[📜] Logs: ./xmrig/build/$LOG_FILE"
echo "[🔍] View with: tmux attach -t $SESSION"
echo "[↩️] Detach with: Ctrl+B, then D"
