#!/usr/bin/env bash
set -euo pipefail

sleep 2

if [[ "${MARISHOKU_NO_GREETING:-0}" == "1" ]]; then
  exit 0
fi

if command -v kdialog >/dev/null 2>&1; then
  kdialog \
    --title 'MARISHOKU/OS システム' \
    --icon marishoku-heart \
    --msgbox '<div style="font-family:monospace;font-size:22pt;line-height:1.5"><b>SYSTEM READY.</b><br/>PROFILE: URA</div>'
fi
