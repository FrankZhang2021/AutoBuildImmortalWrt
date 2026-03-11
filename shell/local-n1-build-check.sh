#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

LUCI_VERSION="${LUCI_VERSION:-24.10.5}"
PROFILE="${PROFILE:-generic}"
INCLUDE_DOCKER="${INCLUDE_DOCKER:-no}"
ROOTFS_PARTSIZE="${ROOTFS_PARTSIZE:-1024}"
LOG_FILE="${LOG_FILE:-local-n1-build.log}"

DOCKER_BIN="${DOCKER_BIN:-docker}"
if ! command -v "${DOCKER_BIN}" >/dev/null 2>&1; then
  if [[ -x "/Applications/Docker.app/Contents/Resources/bin/docker" ]]; then
    DOCKER_BIN="/Applications/Docker.app/Contents/Resources/bin/docker"
  else
    echo "ERROR: docker command not found. Install Docker or set DOCKER_BIN." >&2
    exit 1
  fi
fi

mkdir -p bin files/etc/uci-defaults

echo "[INFO] Running local N1 build in Docker"
echo "[INFO] Image: immortalwrt/imagebuilder:armsr-armv8-openwrt-${LUCI_VERSION}"
echo "[INFO] Log: ${LOG_FILE}"

"${DOCKER_BIN}" run --rm -i \
  --user root \
  -v "${ROOT_DIR}/bin:/home/build/immortalwrt/bin" \
  -v "${ROOT_DIR}/files/etc/uci-defaults:/home/build/immortalwrt/files/etc/uci-defaults" \
  -v "${ROOT_DIR}/arch/arch.conf:/home/build/immortalwrt/files/etc/opkg/arch.conf" \
  -v "${ROOT_DIR}/shell:/home/build/immortalwrt/shell" \
  -v "${ROOT_DIR}/n1/banner:/home/build/immortalwrt/files/mnt/banner" \
  -v "${ROOT_DIR}/n1/imm.config:/home/build/immortalwrt/.config" \
  -v "${ROOT_DIR}/n1/build.sh:/home/build/immortalwrt/build.sh" \
  -e PROFILE="${PROFILE}" \
  -e INCLUDE_DOCKER="${INCLUDE_DOCKER}" \
  -e ROOTFS_PARTSIZE="${ROOTFS_PARTSIZE}" \
  "immortalwrt/imagebuilder:armsr-armv8-openwrt-${LUCI_VERSION}" \
  /bin/bash /home/build/immortalwrt/build.sh > "${LOG_FILE}" 2>&1

OUT_DIR="${ROOT_DIR}/bin/targets/armsr/armv8"
if [[ ! -d "${OUT_DIR}" ]]; then
  echo "ERROR: output directory not found: ${OUT_DIR}" >&2
  exit 1
fi

if [[ -f "${OUT_DIR}/sha256sums" ]]; then
  echo "[INFO] Verifying checksums"
  (
    cd "${OUT_DIR}"
    shasum -a 256 -c sha256sums
  )
fi

echo "[SUCCESS] Build completed"
echo "[SUCCESS] Artifacts: ${OUT_DIR}"
