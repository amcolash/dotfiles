OPENWRT_SRC_DIR="${OPENWRT_SRC_DIR:-${HOME}/Dev/openwrt-flint3}" # <-- Update this to your OpenWrt build folder path

if [[ -d "${OPENWRT_SRC_DIR}" ]]; then
  update-router() {
    # ==============================================================================
    # CONFIGURATION
    # ==============================================================================
    local ROUTER_USER="root"
    local ROUTER_IP="192.168.1.1"
    local BACKUP_BASE_DIR="${HOME}/Documents/Backups/openwrt_backups"

    local CORES
    CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

    # 1. Directory and Path Validation
    if [[ ! -d "${OPENWRT_SRC_DIR}" ]]; then
      echo "❌ ERROR: OpenWrt build directory not found at: ${OPENWRT_SRC_DIR}" >&2
      return 1
    fi

    # Subshell ensures working directory in the main terminal remains unchanged
    (
      set -euo pipefail
      cd "${OPENWRT_SRC_DIR}"

      # 2. Check Internet Connectivity
      local ONLINE=0
      echo "==> [1/6] Checking internet connectivity..."
      if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1 || ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        ONLINE=1
      fi

      if [[ ${ONLINE} -eq 1 ]]; then
        echo "✔ Internet connection detected. Checking for upstream repository updates..."
        git fetch origin

        local LOCAL_HASH REMOTE_HASH BEHIND_COUNT
        LOCAL_HASH=$(git rev-parse HEAD)
        REMOTE_HASH=$(git rev-parse "@{u}" 2>/dev/null || echo "${LOCAL_HASH}")
        BEHIND_COUNT=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

        if [[ "${LOCAL_HASH}" == "${REMOTE_HASH}" ]]; then
          echo "✔ Repository is already up to date (${LOCAL_HASH:0:7})."
          read -rp "No new commits detected. Rebuild and flash anyway? [y/N] " force_build
          if [[ ! "${force_build}" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
          fi
        else
          echo "=============================================================================="
          echo " Detected ${BEHIND_COUNT} new commit(s) upstream!"
          echo "=============================================================================="
          git log --oneline HEAD..@{u}
          echo "=============================================================================="
          read -rp "Proceed with pulling updates, build, and flash? [y/N] " proceed
          if [[ ! "${proceed}" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
          fi
        fi
      else
        echo "⚠️  No internet connection detected."
        read -rp "Build offline with current local Git commit and cached packages? [y/N] " offline_build
        if [[ ! "${offline_build}" =~ ^[Yy]$ ]]; then
          echo "Aborted."
          exit 0
        fi
      fi

      # 3. Check Router Reachability
      echo "==> [2/6] Checking router reachability at ${ROUTER_IP}..."
      if ! ping -c 1 -W 2 "${ROUTER_IP}" >/dev/null 2>&1; then
        echo "❌ ERROR: Router at ${ROUTER_IP} is unreachable." >&2
        exit 1
      fi

      # Setup Timestamped Backup Folder
      local TIMESTAMP CURRENT_BACKUP_DIR ROUTER_BACKUP_FILE
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      CURRENT_BACKUP_DIR="${BACKUP_BASE_DIR}/${TIMESTAMP}"
      mkdir -p "${CURRENT_BACKUP_DIR}"
      ROUTER_BACKUP_FILE="${CURRENT_BACKUP_DIR}/openwrt_router_backup.tar.gz"

      # 4. Backup Router Configuration (Streams via SSH directly)
      echo "==> [3/6] Backing up active router configuration..."
      ssh "${ROUTER_USER}@${ROUTER_IP}" "sysupgrade -b /tmp/backup.tar.gz && cat /tmp/backup.tar.gz && rm -f /tmp/backup.tar.gz" >"${ROUTER_BACKUP_FILE}"

      if [[ -s "${ROUTER_BACKUP_FILE}" ]]; then
        echo "    Router settings saved to: ${ROUTER_BACKUP_FILE}"
      else
        echo "❌ ERROR: Router backup creation failed or file is empty." >&2
        exit 1
      fi

      # 5. Update Git Repo & Feeds (If Online), Refresh Dependencies
      if [[ ${ONLINE} -eq 1 ]]; then
        echo "==> [4/6] Updating source tree and package feeds..."
        git pull
        ./scripts/feeds update -a
        ./scripts/feeds install -a
      else
        echo "==> [4/6] Skipping git pull and feed updates (offline mode)..."
      fi

      make defconfig

      # Archive local .config
      if [[ -f ".config" ]]; then
        cp .config "${CURRENT_BACKUP_DIR}/build_dot_config"
        echo "    Build .config saved to:   ${CURRENT_BACKUP_DIR}/build_dot_config"
      fi

      # 6. Build Firmware (Verbose V=s) & Archive Binaries
      if [[ ${ONLINE} -eq 1 ]]; then
        #echo "==> [5/6] Downloading missing sources and compiling firmware (${CORES} threads, verbose)..."
        echo "==> [5/6] Downloading missing sources and compiling firmware (${CORES} threads)..."
        make download -j"${CORES}"
      else
        #echo "==> [5/6] Compiling firmware from cached sources (${CORES} threads, verbose)..."
        echo "==> [5/6] Compiling firmware from cached sources (${CORES} threads)..."
      fi
      #make -j"${CORES}" V=s
      make -j"${CORES}"

      local SYSUPGRADE_IMG
      SYSUPGRADE_IMG=$(find bin/targets/ -type f \( -name "*sysupgrade.bin" -o -name "*sysupgrade.tar" \) | head -n 1)

      if [[ -z "${SYSUPGRADE_IMG}" || ! -f "${SYSUPGRADE_IMG}" ]]; then
        echo "❌ ERROR: No sysupgrade image found in bin/targets/" >&2
        exit 1
      fi

      echo "    Archiving generated binaries..."
      find bin/targets/ -type f \( -name "*.bin" -o -name "*.tar" \) -exec cp {} "${CURRENT_BACKUP_DIR}/" \;
      echo "    All firmware images copied to: ${CURRENT_BACKUP_DIR}/"

      # 7. Upload and Flash (SSH stream fallback: works with or without scp/sftp-server)
      echo "==> [6/6] Uploading image and flashing router..."
      cat "${SYSUPGRADE_IMG}" | ssh "${ROUTER_USER}@${ROUTER_IP}" "cat > /tmp/firmware.bin"

      echo "    Triggering sysupgrade (keeping settings)..."
      ssh "${ROUTER_USER}@${ROUTER_IP}" "sysupgrade -v /tmp/firmware.bin" || true

      echo ""
      echo "=============================================================================="
      echo " Upgrade initiated! The router will flash and reboot."
      echo " Full backup folder created at: ${CURRENT_BACKUP_DIR}"
      echo "=============================================================================="
    )
  }
else
  unset OPENWRT_SRC_DIR
fi
